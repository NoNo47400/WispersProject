#ifndef MY_MQTT_H
#define MY_MQTT_H

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ArduinoMqttClient.h>
#include "wifi.h"

// Classe pour gérer les interactions MQTT
class MqttHandler {
private:
    WiFiClient wifiClient;          // Client WiFi pour la communication réseau
    MqttClient mqttClient;          // Client MQTT pour les interactions avec le broker
    String broker;                  // Adresse du broker MQTT
    int port;                       // Port du broker MQTT

public:
    // Constructeur
    MqttHandler(const char* broker, int port);

    // Méthode pour se connecter au broker MQTT
    bool connect();

    // Méthode pour s'abonner à un topic
    void subscribe(const char* topic);

    // Méthode pour publier un message sur un topic
    void publish(const String& topic, const String& message);

    // Méthode pour lire et analyser les messages MQTT
    bool parseMessage(String& topic, String& payload_to_parse);

    // Méthode pour garder la connexion MQTT active
    void poll();
};

#endif // MY_MQTT_H