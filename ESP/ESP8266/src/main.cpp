#include "hub_controller.h"
#include "wifi.h"
#include <Wire.h>
#include "test_I2C.h"

// Configuration globale
String deviceID = "1";
const char broker[] = "172.20.10.2";
uint16_t port = 1234;

// Instance du contrôleur
HubController hubController(broker, port, deviceID);
WifiClient wifiClient;

void i2c_handler(int num_bytes) {
    hubController.rubeeProtocol.get_data(num_bytes);
}

void setup() {
    Serial.begin(9600);
    //test_I2C_Master();
    Wire.begin(I2C_ADDRESS);
    Wire.onReceive(i2c_handler);
    if (!wifiClient.connect_to_wifi()) {
        Serial.println("Failed to connect to WiFi");
        while (1);
    }
    hubController.setup();
}

void loop() {
    hubController.handleState();
}