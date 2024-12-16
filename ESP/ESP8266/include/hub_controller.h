#ifndef MY_HUB_CONTROLLER_H
#define MY_HUB_CONTROLLER_H

#include <Arduino.h> 
#include "my_mqtt.h"
#include <list>
#include "rubee_protocol.h"

// Enumeration of possible states
enum State {
    GetAddresses,   // Get addresses
    GetData,       // Retrieve data
    SendData       // Send data
};

// Main class to orchestrate the hub processes
class HubController {
private:
    MqttHandler mqttHandler;                   // MQTT handler
    String deviceID;                           // Unique ID of the hub
    String addresses;                          // Raw list of received addresses
    int currentAddressIndex;                   // Index of the current address
    std::vector<String> addressList;           // List of individual addresses
    bool addressesReceived;                    // Indicator of address reception
    State currentState; // Current state of the state machine

public:
    RubeeProtocol rubeeProtocol;  

    // Constructor
    HubController(const char* broker, uint16_t port, const String& deviceID);

    // Main methods
    void setup();
    void handleState();
    void handleIncomingMessages();

private:
    // State management
    void handleGetAddressesState();
    void handleGetDataState(std::list<String>& get_payload);
    void handleSendDataState(std::list<String>& payload_to_send);

    // Auxiliary methods
    void requestAddresses();
    void processAddresses(const String& message);
    std::vector<String> splitAddresses(const String& message);
    void requestData(String& address);
    bool getData(DataField* dataField);
    void sendData(const String& address, const String& data);
    void processData(std::list<String>& payload_to_process);
};

#endif