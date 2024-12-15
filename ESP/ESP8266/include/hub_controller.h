#ifndef MY_HUB_CONTROLLER_H
#define MY_HUB_CONTROLLER_H

#include <Arduino.h> 
#include "my_mqtt.h"
#include <list>
#include "rubee_protocol.h"

// Enumération des états possibles
enum State {
    GetAddresses,   // Obtenir les adresses
    GetData,       // Récupérer les données
    SendData       // Envoyer les données
};

// Classe principale pour orchestrer les processus du hub
class HubController {
private:
    MqttHandler mqttHandler;                   // Gestionnaire MQTT
    String deviceID;                           // ID unique du hub
    String addresses;                          // Liste brute des adresses reçues
    int currentAddressIndex;                   // Index de l'adresse en cours
    std::vector<String> addressList;           // Liste des adresses individuelles
    bool addressesReceived;                    // Indicateur de réception des adresses
    State currentState; // État actuel de la machine d'états

public:
    RubeeProtocol rubeeProtocol;    
    // Constructeur
    HubController(const char* broker, uint16_t port, const String& deviceID);

    // Méthodes principales
    void setup();
    void handleState();
    void handleIncomingMessages();

private:
    // Gestion des états
    void handleGetAddressesState();
    void handleGetDataState(std::list<String>& get_payload);
    void handleSendDataState(std::list<String>& payload_to_send);

    // Méthodes auxiliaires
    void requestAddresses();
    void processAddresses(const String& message);
    std::vector<String> splitAddresses(const String& message);
    String getData(String& address);
    void sendData(const String& address, const String& data);
    void processData(std::list<String>& payload_to_process);
};

#endif