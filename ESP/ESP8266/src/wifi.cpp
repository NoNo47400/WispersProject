#include "wifi.h"

// Function to connect to WiFi
int WifiClient::connect_to_wifi() {
    int cpt = 0;
    
    // Afficher les informations de connexion
    Serial.println("\n=== WiFi Connection Debug ===");
    Serial.print("SSID: ");
    Serial.println(SECRET_SSID);
    Serial.print("Password length: ");
    Serial.println(strlen(SECRET_PASS));
    
    // Déconnexion préalable et configuration
    WiFi.disconnect(true);
    delay(1000);
    WiFi.mode(WIFI_STA);
    WiFi.begin(SECRET_SSID, SECRET_PASS);
    
    Serial.println("Attempting to connect...");
    
    while (WiFi.status() != WL_CONNECTED) {
        if (cpt > 20) { // Réduit à 20 tentatives (100 secondes)
            Serial.println("\nFailed to connect. Status code: " + String(WiFi.status()));
            Serial.println("Status codes: ");
            Serial.println("WL_IDLE_STATUS=0");
            Serial.println("WL_NO_SSID_AVAIL=1");
            Serial.println("WL_SCAN_COMPLETED=2");
            Serial.println("WL_CONNECTED=3");
            Serial.println("WL_CONNECT_FAILED=4");
            Serial.println("WL_CONNECTION_LOST=5");
            Serial.println("WL_DISCONNECTED=6");
            return 0;
        }
        delay(5000);
        Serial.print(".");
        Serial.print("(Status: ");
        Serial.print(WiFi.status());
        Serial.print(") ");
        cpt++;
    }

    // Connexion réussie, afficher les détails
    Serial.println("\nConnection successful!");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    Serial.print("Signal strength (RSSI): ");
    Serial.print(WiFi.RSSI());
    Serial.println(" dBm");
    Serial.println("===========================");

    return 1;
}


