#include "hub_controller.h"
#include "wifi.h"
#include <Wire.h>

// Global configuration
String deviceID = "1";
const char broker[] = "172.20.10.2";
uint16_t port = 1234;

// Controller instance
HubController hubController(broker, port, deviceID);
WifiClient wifiClient;

// I2C handler function
void i2c_handler(int num_bytes) {
    hubController.rubeeProtocol.get_data(num_bytes);
}

void setup() {
    Serial.begin(9600);
    delay(2000); // Attendre que le port série soit prêt
    
    Serial.println("\nStarting ESP8266...");
    
    Wire.begin(I2C_ADDRESS);
    Wire.onReceive(i2c_handler);
    
    int wifi_attempts = 0;
    while (!wifiClient.connect_to_wifi()) {
        Serial.println("Retrying WiFi connection...");
        delay(5000);
        wifi_attempts++;
        if (wifi_attempts >= 3) {
            Serial.println("Failed to connect to WiFi after 3 attempts. Resetting...");
            ESP.restart();
        }
    }
    
    hubController.setup();
}

void loop() {
    hubController.handleState();
}