#include "hub_controller.h"

HubController::HubController(const char* broker, int port, const String& deviceID)
    : mqttHandler(broker, port), deviceID(deviceID), currentAddressIndex(0),
        addressesReceived(false), data("", "", false) {}

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
    //TODO avec Rubee
    return "1;" + address + ";2000;1";// 1 pour l'adresse du hub, 10 pour l'adresse du patch, 2000 pour la valeur, 1 pour dire que c'est la dernière valeur
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
        if (currentAddressIndex >= addressList.size()) {
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
    if (currentAddressIndex >= addressList.size()) {
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
        data = parseData(first_data);
        sendData(data.address, data.data);
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
    if (start < message.length()) {
        addresses.push_back(message.substring(start));
    } else {
        // Invalid format
        Serial.println("Error: Invalid message format, trailing semicolon.");
        addresses.clear();
    }
    return addresses;
}

DataField HubController::parseData(const String& payload_to_parse) {
    int firstSep = payload_to_parse.indexOf(';');
    int secondSep = payload_to_parse.indexOf(';', firstSep + 1);
    int thirdSep = payload_to_parse.indexOf(';', secondSep + 1);

    if (firstSep == -1 || secondSep == -1 || thirdSep == -1) {
        // Payload format is incorrect
        return DataField("", "", false);
    }

    String hubAddress = payload_to_parse.substring(0, firstSep);
    String patchAddress = payload_to_parse.substring(firstSep + 1, secondSep);
    String data = payload_to_parse.substring(secondSep + 1, thirdSep);
    bool finished = (payload_to_parse.substring(thirdSep + 1) == "1");

    if (hubAddress != deviceID) {
        // Payload is not for this hub
        return DataField("", "", false);
    }

    return DataField(patchAddress, data, finished);
}