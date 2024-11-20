#include mqtt.h 

WiFiClient wifiClient;

MqttClient mqttClient(wifiClient);

int connect_to_broker();
{
    Serial.print("Attempting to connect to the MQTT broker: ");
    Serial.println(broker);

    if (!mqttClient.connect(broker, port)) {
        return 0;
        Serial.print("MQTT connection failed! Error code = ");
        Serial.println(mqttClient.connectError());

        while (1);
    }

    Serial.println("You're connected to the MQTT broker!");
    Serial.println();

    return 1;
}