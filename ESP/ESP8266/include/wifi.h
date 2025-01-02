#ifndef _WIFI_WHISPER_PROJECT_H_
#define _WIFI_WHISPER_PROJECT_H_

#include <Arduino.h>
#include <ESP8266WiFi.h>

// WiFi credentials
//#define SECRET_SSID "Box_de_bibou"
//#define SECRET_PASS "NoelEstSuperieur"
#define SECRET_SSID "iPhone de Noel"
#define SECRET_PASS "1234567890"

// WiFi client class
class WifiClient {
public:
    int connect_to_wifi(void); // Connect to WiFi
};

#endif