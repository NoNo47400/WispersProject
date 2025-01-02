#ifndef MY_MQTT_H
#define MY_MQTT_H

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ArduinoMqttClient.h>
#include "wifi.h"

// Class to handle MQTT interactions
class MqttHandler {
private:
    WiFiClient wifiClient;          // WiFi client for network communication
    MqttClient mqttClient;          // MQTT client for broker interactions
    String broker;                  // MQTT broker address
    uint16_t port;                  // MQTT broker port

public:
    // Constructor
    MqttHandler(const char* broker, uint16_t port);

    // Connect to the MQTT broker
    bool connect();

    // Subscribe to a topic
    void subscribe(const char* topic);

    // Publish a message to a topic
    void publish(const String& topic, const String& message);

    // Parse incoming MQTT messages
    bool parseMessage(String& topic, String& payload_to_parse);

    // Keep the MQTT connection alive
    void poll();
};

#endif // MY_MQTT_H