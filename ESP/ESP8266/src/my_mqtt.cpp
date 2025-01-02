#include "my_mqtt.h"

// Constructor
MqttHandler::MqttHandler(const char* broker, uint16_t port)
    : broker(broker), port(port), mqttClient(wifiClient) {}

// Connect to the MQTT broker
bool MqttHandler::connect() {
    if (!mqttClient.connect(broker.c_str(), port)) {
        Serial.print("MQTT connection failed! Error code = ");
        Serial.println(mqttClient.connectError());
        return false;
    }
    return true;
}

// Subscribe to a topic
void MqttHandler::subscribe(const char* topic) {
    mqttClient.subscribe(topic);
}

// Publish a message to a topic
void MqttHandler::publish(const String& topic, const String& message) {
    mqttClient.beginMessage(topic);
    mqttClient.print(message);
    mqttClient.endMessage();
}

// Parse incoming MQTT messages
bool MqttHandler::parseMessage(String& topic, String& payload_to_parse) {
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

// Keep the MQTT connection alive
void MqttHandler::poll() {
    mqttClient.poll();
}
