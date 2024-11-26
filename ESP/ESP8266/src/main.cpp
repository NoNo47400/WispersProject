#include "hub_controller.h"
#include "wifi.h"

// Configuration globale
String deviceID = "1";
const char broker[] = "172.20.10.2";
int port = 1234;

// Instance du contrôleur
HubController hubController(broker, port, deviceID);
WifiClient wifiClient;

void setup() {
    Serial.begin(9600);
    if (!wifiClient.connect_to_wifi()) {
        Serial.println("Failed to connect to WiFi");
        while (1);
    }
    hubController.setup();
}

void loop() {
    hubController.handleState();
}