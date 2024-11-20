#include "wifi.h"

int connect_to_wifi() {
    int cpt = 0;
    // attempt to connect to WiFi network:
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(SECRET_SSID);
    while (WiFi.begin(SECRET_SSID, SECRET_PASS) != WL_CONNECTED) {
        // failed, retry
        if (cpt>50){
            return -1;
        }
        Serial.print(".");
        delay(5000);
        cpt++;
    }

    Serial.println("You're connected to the network");
    Serial.println();

    return 0;
}