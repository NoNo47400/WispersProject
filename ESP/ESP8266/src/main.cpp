#include <ArduinoMqttClient.h>
#include "wifi.h"
#include <list>

// Classe pour représenter les champs des données
class DataField {
public:
    String address;
    String data;
    bool isFinished;

    DataField(String addr, String d, bool finished)
        : address(addr), data(d), isFinished(finished) {}
};

// Classe pour gérer les interactions MQTT
class MqttHandler {
private:
    WiFiClient wifiClient;
    MqttClient mqttClient;
    String broker;
    int port;

public:
    MqttHandler(const char* broker, int port)
        : broker(broker), port(port), mqttClient(wifiClient) {}

    bool connect() {
        if (!mqttClient.connect(broker.c_str(), port)) {
            Serial.print("MQTT connection failed! Error code = ");
            Serial.println(mqttClient.connectError());
            return false;
        }
        return true;
    }

    void subscribe(const char* topic) {
        mqttClient.subscribe(topic);
    }

    void publish(const String& topic, const String& message) {
        mqttClient.beginMessage(topic);
        mqttClient.print(message);
        mqttClient.endMessage();
    }

    bool parseMessage(String& topic, String& payload_to_parse) {
        if (mqttClient.parseMessage()) {
            topic = mqttClient.messageTopic();
            payload_to_parse = "";
            while (mqttClient.available()) {
                payload_to_parse += (char)mqttClient.read();
            }
            return true;
        }
        return false;
    }

    void poll() {
        mqttClient.poll();
    }
};

// Classe principale pour orchestrer le processus
class HubController {
private:
    MqttHandler mqttHandler;
    String deviceID;
    String addresses;
    int currentAddressIndex;
    std::vector<String> addressList;

    bool addressesReceived;
    enum State {
      GetAddresses,
      GetData,
      SendData
    };
    State currentState = GetAddresses;
    DataField data;

public:
    HubController(const char* broker, int port, const String& deviceID)
        : mqttHandler(broker, port), deviceID(deviceID), currentAddressIndex(0),
          addressesReceived(false), data("", "", false) {}

    void setup() {
        if (!connect_to_wifi()) {
            Serial.println("Failed to connect to WiFi");
            while (1);
        }

        if (!mqttHandler.connect()) {
            Serial.println("Failed to connect to MQTT broker");
            while (1);
        }
        mqttHandler.subscribe("addresses");
    }

    void requestAddresses() {
        Serial.println("Request addresses");
        mqttHandler.publish("get_addresses", deviceID);
    }

    void processAddresses(const String& message) {
        addresses = message;
        addressList = splitAddresses(message);
        if (addressList.empty()) {
            Serial.println("Error: Address list is empty.");
            addressesReceived = false;
        } else {
            addressesReceived = true;
        }
    }

    String getData(String& address) {
        //TODO avec Rubee
        return "1;" + address + ";2000;1";// 1 pour l'adresse du hub, 10 pour l'adresse du patch, 2000 pour la valeur, 1 pour dire que c'est la dernière valeur
    }

    void sendData(const String& address, const String& data) {
        String payload_to_send = deviceID + ";" + address + ";" + data;
        mqttHandler.publish("data", payload_to_send);
    }

    void loop() {
        mqttHandler.poll();
        handleIncomingMessages();
        handleState();
    }

    void handleIncomingMessages() {
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

    void handleState() {
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

    void handleGetAddressesState() {
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

    void handleGetDataState(std::list<String>& get_payload) {
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

    void handleSendDataState(std::list<String>& payload_to_send) {
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

    void processData(std::list<String>& payload_to_process) {
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

    std::vector<String> splitAddresses(const String& message) {
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

    DataField parseData(const String& payload_to_parse) {
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
};

// Configuration globale
const char broker[] = "172.20.10.2";
int port = 1234;
String deviceID = "1";

// Instance du contrôleur
HubController hubController(broker, port, deviceID);

void setup() {
    Serial.begin(9600);
    hubController.setup();
}

void loop() {
    hubController.loop();
}