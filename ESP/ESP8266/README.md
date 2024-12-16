# ESP8266 Whisper Project

## Overview

This project involves using an ESP8266 to communicate with patches via the RuBee protocol over I2C and send the collected data to an MQTT broker. The process involves three main steps:
1. Requesting addresses from the MQTT broker.
2. Interrogating each patch via I2C to collect data.
3. Sending the collected data to the MQTT broker.

## Exchange Sequence

1. **Initialization**:
   - Connect to the WiFi network.
   - Configure the I2C handler.
   - Connect to the MQTT broker.

2. **Request Addresses**:
   - Send a request to the MQTT broker to get the list of patch addresses.
   - Process the received addresses and store them.

3. **Interrogate Patches**:
   - For each address, send a request via I2C using the RuBee protocol.
   - Wait for the complete data reception for each patch before moving to the next.

4. **Send Data**:
   - Serialize the collected data into a string format.
   - Send the serialized data to the MQTT broker.

5. **Repeat**:
   - The process repeats indefinitely, updating the list of addresses and interrogating patches in a loop.

## Configuration

### WiFi Configuration

Update the WiFi credentials in `wifi.h`:

```cpp
// filepath: /c:/Users/noelj/Documents/GitHub/WhisperProject/ESP/ESP8266/include/wifi.h
#ifndef _WIFI_WHISPER_PROJECT_H_
#define _WIFI_WHISPER_PROJECT_H_

#include <Arduino.h>
#include <ESP8266WiFi.h>

// WiFi credentials
#define SECRET_SSID "Your_SSID"
#define SECRET_PASS "Your_PASSWORD"

class WifiClient {
public:
    int connect_to_wifi(void); // Connect to WiFi
};

#endif
```

### MQTT Configuration

Update the MQTT broker address and port in `main.cpp` (you can also change the Hub address):

```cpp
// filepath: /c:/Users/noelj/Documents/GitHub/WhisperProject/ESP/ESP8266/src/main.cpp
#include "hub_controller.h"
#include "wifi.h"
#include <Wire.h>
#include "test_I2C.h"

// Global configuration
String deviceID = "1";
const char broker[] = "Your_Broker_Address";
uint16_t port = Your_Broker_Port;

// Controller instance
HubController hubController(broker, port, deviceID);
WifiClient wifiClient;

// I2C handler function
void i2c_handler(int num_bytes) {
    hubController.rubeeProtocol.get_data(num_bytes);
}

void setup() {
    Serial.begin(9600);
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
```

### Running the Project

1. **Upload the Code**:
   - Use the Arduino IDE or PlatformIO to upload the code to the ESP8266.

2. **Monitor the Serial Output**:
   - Open the Serial Monitor to view the debug output and ensure the device is connecting to WiFi, MQTT broker, and collecting/sending data correctly.

3. **Verify MQTT Messages**:
   - Use an MQTT client to subscribe to the relevant topics and verify that the data is being sent correctly.

## Files

- `src/main.cpp`: Main entry point of the program.
- `src/wifi.cpp`: Handles WiFi connection.
- `src/my_mqtt.cpp`: Handles MQTT communication.
- `src/rubee_protocol.cpp`: Implements the RuBee protocol.
- `src/hub_controller.cpp`: Orchestrates the hub processes.
- `include/wifi.h`: WiFi configuration.
- `include/my_mqtt.h`: MQTT configuration.
- `include/rubee_protocol.h`: RuBee protocol configuration.
- `include/hub_controller.h`: Hub controller configuration.
- `include/data_field.h`: Data field structure.

