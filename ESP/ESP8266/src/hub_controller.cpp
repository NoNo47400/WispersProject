#include "hub_controller.h"

HubController::HubController(const char* broker, uint16_t port, const String& deviceID)
    : mqttHandler(broker, port), deviceID(deviceID), currentAddressIndex(0),
        addressesReceived(false) {}

void HubController::setup() {
    if (!mqttHandler.connect()) {
        Serial.println("Failed to connect to MQTT broker");
        while (1);
    }
    mqttHandler.subscribe("addresses");
}

void HubController::requestAddresses() {
    Serial.println("Request addresses");
    mqttHandler.publish("get_addresses", deviceID);
}

void HubController::processAddresses(const String& message) {
    addresses = message;
    addressList = splitAddresses(message);
    if (addressList.empty()) {
        Serial.println("Error: Address list is empty.");
        addressesReceived = false;
    } else {
        addressesReceived = true;
    }
}

String HubController::getData(String& address) {
    // Use RubeeProtocol to get data
    // Example implementation
    nibble protocol_selector = 0x1; // Example protocol selector
    std::vector<nibble> address_nibbles(address.begin(), address.end());
    DataField dataField;
    RequestPDU pdu = rubeeProtocol.create_request_pdu(protocol_selector, address_nibbles, dataField);
    rubeeProtocol.send_request_pdu(pdu);
    return "1;" + address + ";2000;1"; // Example return value
}

void HubController::sendData(const String& address, const String& data) {
    String payload_to_send = deviceID + ";" + address + ";" + data;
    mqttHandler.publish("data", payload_to_send);
}

void HubController::handleIncomingMessages() {
    String topic;
    String mqttpayload;
    delay(10); // Ajout d'un petit délai pour éviter les problèmes de lecture (car ça marche s'il y a un print)
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

void HubController::handleGetDataState(std::list<String>& get_payload) {
    int is_finished_local = 0;
    while (!is_finished_local) {
        if (currentAddressIndex >= static_cast<int>(addressList.size())) {
            Serial.println("Error: currentAddressIndex out of bounds");
            break;
        }
        String currentAddress = addressList[currentAddressIndex];
        get_payload.push_back(getData(currentAddress));
        char lastChar = get_payload.back().charAt(get_payload.back().length() - 1);
        is_finished_local = lastChar - '0';
        Serial.printf("There is still data to process %d\n", !is_finished_local);
    }
    currentState = SendData;
}

void HubController::handleSendDataState(std::list<String>& payload_to_send) {
    processData(payload_to_send);
    currentAddressIndex++;
    if (currentAddressIndex >= static_cast<int>(addressList.size())) {
        // Reboucler sur l'étape 1
        addressesReceived = false;
        currentAddressIndex = 0;
        currentState = GetAddresses;
    } else {
        currentState = GetData;
    }
}

void HubController::processData(std::list<String>& payload_to_process) {
    Serial.print("Payload that will be sent to mqtt server: ");
    for (const auto& item : payload_to_process) {
        Serial.print(item);
        Serial.print(" ");
    }
    Serial.println();
    while (!payload_to_process.empty()) {
        String first_data = *payload_to_process.begin();
        payload_to_process.pop_front();
        // Parse data and send using RubeeProtocol
        // Example implementation
        std::vector<nibble> data_nibbles(first_data.begin(), first_data.end());
        DataField dataField = rubeeProtocol.get_data_field(data_nibbles);
        sendData(dataField.patch_address.to_string().c_str(), dataField.data->to_string().c_str());
    }
}

std::vector<String> HubController::splitAddresses(const String& message) {
    std::vector<String> addresses;
    int firstSep = message.indexOf(';');
    if (firstSep == -1) {
        // Invalid format
        Serial.println("Error: Invalid message format, missing semicolons.");
        return addresses;
    }

    String hubAddress = message.substring(0, firstSep);
    if (hubAddress != deviceID) {
        // Message not for this hub
        Serial.println("Error: Message not for this hub.");
        return addresses;
    }

    int start = firstSep + 1;
    int end = message.indexOf(';', start);
    while (end != -1) {
        addresses.push_back(message.substring(start, end));
        start = end + 1;
        end = message.indexOf(';', start);
    }
    if (start < static_cast<int>(message.length())) {
        addresses.push_back(message.substring(start));
    } else {
        // Invalid format
        Serial.println("Error: Invalid message format, trailing semicolon.");
        addresses.clear();
    }
    return addresses;
}