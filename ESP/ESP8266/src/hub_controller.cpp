#include "hub_controller.h"

// Constructor
HubController::HubController(const char* broker, uint16_t port, const String& deviceID)
    : mqttHandler(broker, port), 
      deviceID(deviceID), 
      currentAddressIndex(0),
      addressesReceived(false),
      rubeeProtocol(true)  // To simulate without i2c
{}

// Setup function
void HubController::setup() {
    if (!mqttHandler.connect()) {
        Serial.println("Failed to connect to MQTT broker");
        while (1);
    }
    mqttHandler.subscribe("addresses");
}

// Request addresses from the MQTT broker
void HubController::requestAddresses() {
    Serial.println("Request addresses");
    mqttHandler.publish("get_addresses", deviceID);
}

// Process received addresses
void HubController::processAddresses(const String& message) {
    addresses = message;
    addressList = splitAddresses(message);
    Serial.println("Addresses received:");
    for (const auto& address : addressList) {
        Serial.println(address);
    }
    if (addressList.empty()) {
        Serial.println("Error: Address list is empty.");
        addressesReceived = false;
    } else {
        addressesReceived = true;
    }
}

// Request data from a specific address
void HubController::requestData(String& address) {
    nibble protocol_selector = 0x1;
    std::vector<nibble> address_nibbles(deviceID.begin(), deviceID.end());

    DataField dataField;
    dataField.patch_address = std::bitset<4>(address.toInt());

    // Initialize data with a single zero nibble
    dataField.data.push_back(nibble(0));

    // Calculate the data length
    uint16_t data_length = 2 + 1 + dataField.data.size() + 1;
    dataField.data_length[0] = std::bitset<4>((data_length & 0xF0) >> 4);
    dataField.data_length[1] = std::bitset<4>(data_length & 0x0F);

    dataField.isFinished = std::bitset<4>(1);

    RequestPDU pdu = rubeeProtocol.create_request_pdu(protocol_selector, address_nibbles, dataField);
    Serial.print("Data Length: ");
    for (const auto& nib : pdu.data.data_length) {
        Serial.print(nib.to_ulong(), HEX);
        Serial.print(" ");
    }
    Serial.println();

    rubeeProtocol.send_request_pdu(pdu);
}

// Get data from RubeeProtocol
bool HubController::getData(DataField* dataField) {
    unsigned long startTime = millis();
    const unsigned long timeout = 5000; // 5 seconds timeout

    while (millis() - startTime < timeout) {
        if (rubeeProtocol.read_data(dataField)) {
            // Debug prints to check the state of dataField after reading
            Serial.print("Read patch_address: ");
            Serial.println(dataField->patch_address.to_ulong());
            Serial.print("Read data_length: ");
            Serial.println((dataField->data_length[0].to_ulong()>>4)+dataField->data_length[1].to_ulong());
            Serial.print("Read data: ");
            for (const auto& nib : dataField->data) {
                Serial.print(nib.to_ulong(), HEX);
            }
            Serial.println();
            Serial.print("Read isFinished: ");
            Serial.println(dataField->isFinished.to_ulong());

            return true;
        }
        delay(100); // Small delay to avoid busy waiting
    }
    return false;
}

// Send data to the MQTT broker
void HubController::sendData(const String& address, const String& data) {
    String payload_to_send = deviceID + ";" + address + ";" + data;
    mqttHandler.publish("data", payload_to_send);
}

// Handle incoming MQTT messages
void HubController::handleIncomingMessages() {
    String topic;
    String mqttpayload;
    delay(10); // Small delay to avoid reading issues
    if (mqttHandler.parseMessage(topic, mqttpayload)) {
        Serial.print("Received message on topic: ");
        Serial.print(topic);
        Serial.print(" with payload: ");
        Serial.println(mqttpayload);
        if (topic == "addresses") {
            processAddresses(mqttpayload);
        }
    }
}

// Handle the state machine
void HubController::handleState() {
    mqttHandler.poll();
    handleIncomingMessages();
    static std::list<String> payload;
    switch (currentState) {
        case GetAddresses:
            handleGetAddressesState();
            break;

        case GetData:
            handleGetDataState(payload);
            break;

        case SendData:
            handleSendDataState(payload);
            break;
    }
}

// Handle the GetAddresses state
void HubController::handleGetAddressesState() {
    if (!addressesReceived) {
        static unsigned long lastRequestTime = 0;
        const unsigned long requestInterval = 1000; // 1 second
        
        unsigned long currentTime = millis();
        if (currentTime - lastRequestTime >= requestInterval) {
            requestAddresses();
            lastRequestTime = currentTime;
        }
    } else {
        addressesReceived = false;
        currentState = GetData;
    }
}

// Handle the GetData state
void HubController::handleGetDataState(std::list<String>& get_payload) {
    int is_finished_local = 0;
    while (!is_finished_local) {  // TO TEST avec finished à 0 car peur que ça casse le truc
        if (currentAddressIndex >= static_cast<int>(addressList.size())) {
            Serial.println("Error: currentAddressIndex out of bounds");
            return;
            //break;
        }
        String currentAddress = addressList[currentAddressIndex];
        Serial.print("Requesting data for address: ");
        Serial.println(currentAddress);
        
        requestData(currentAddress);

        DataField dataField;
        if (getData(&dataField)) {
            is_finished_local = dataField.isFinished.to_ulong();
            String dataString = deviceID + ";";
            
            // Convertir patch_address en décimal
            dataString += String(dataField.patch_address.to_ulong());
            dataString += ";";
        
            // Convertir les données en hexadécimal de manière concise
            String dataContent;
            for (const auto& nib : dataField.data) {
                // Utiliser un seul caractère hexadécimal par nibble
                dataContent += String(nib.to_ulong(), HEX);
            }
            dataString += dataContent;
            dataString += ";";
            
            // Ajouter isFinished
            dataString += String(dataField.isFinished.to_ulong());
            
            get_payload.push_back(dataString);
        } else {
            Serial.println("Error: Timeout waiting for data");
        }
    }
    currentState = SendData;
}

// Handle the SendData state
void HubController::handleSendDataState(std::list<String>& payload_to_send) {
    processData(payload_to_send);
    currentAddressIndex++;
    if (currentAddressIndex >= static_cast<int>(addressList.size())) {
        // Loop back to the first step
        addressesReceived = false;
        currentAddressIndex = 0;
        currentState = GetAddresses;
    } else {
        currentState = GetData;
    }
}

// Process the data and send it to the MQTT broker
void HubController::processData(std::list<String>& payload_to_process) {
    Serial.print("Payload that will be sent to mqtt server: ");
    while (!payload_to_process.empty()) {
        String message = *payload_to_process.begin();
        payload_to_process.pop_front();
        Serial.println(message);
        
        // Parse the message which should be in format "deviceID;address;data;isFinished"
        int firstSep = message.indexOf(';');
        int secondSep = message.indexOf(';', firstSep + 1);
        int thirdSep = message.indexOf(';', secondSep + 1);
        
        if (firstSep > 0 && secondSep > 0 && thirdSep > 0) {
            String address = message.substring(firstSep + 1, secondSep);
            String data = message.substring(secondSep + 1, thirdSep);
            
            // Envoi des données sans traitement supplémentaire
            sendData(address, data);
        }
    }
}

// Split the addresses from the received message
std::vector<String> HubController::splitAddresses(const String& message) {
    std::vector<String> addresses;
    
    Serial.println("\n=== Processing Address Message ===");
    Serial.print("Raw message: ");
    Serial.println(message);
    
    // Vérification message vide
    if (message.length() == 0) {
        Serial.println("Error: Empty message");
        return addresses;
    }

    // Premier split pour deviceID
    int firstSep = message.indexOf(';');
    if (firstSep == -1) {
        Serial.println("Error: No separator found");
        return addresses;
    }

    // Vérification du deviceID
    String hubAddress = message.substring(0, firstSep);
    Serial.print("Hub ID in message: ");
    Serial.println(hubAddress);
    Serial.print("Expected Hub ID: ");
    Serial.println(deviceID);
    
    if (hubAddress != deviceID) {
        Serial.println("Error: Message not for this hub");
        return addresses;
    }

    // Extraction des adresses
    size_t start = static_cast<size_t>(message.indexOf(';') + 1);
    if (start >= message.length()) {
        Serial.println("Error: No addresses after hub ID");
        return addresses;
    }

    // Split des adresses
    while (start < message.length()) {
        int end = message.indexOf(';', start);
        String addr;
        
        if (end == -1) {
            addr = message.substring(start);
            start = message.length();
        } else {
            addr = message.substring(start, end);
            start = static_cast<size_t>(end + 1);
        }
        
        // Vérification de l'adresse
        if (addr.length() > 0) {
            Serial.print("Found address: ");
            Serial.println(addr);
            addresses.push_back(addr);
        }
    }

    // Résultat final
    Serial.print("Total addresses found: ");
    Serial.println(addresses.size());
    Serial.println("=== End Processing ===\n");

    return addresses;
}