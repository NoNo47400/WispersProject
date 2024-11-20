#include <Arduino.h>
#include "wifi.h"
#include "mqtt.h"





void setup() {
  // put your setup code here, to run once:
  //Initialize serial and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  if (!connect_to_wifi()) {
    Serial.println("Failed to connect to WiFi");
    while (1);
  }

  if (!mqttClient.connect(broker, port)) {  // Faire avec mon mqtt connect avec une classe, comme ça un client pour ecouter adresses et un autre pour envoyer données

        Serial.print("MQTT connection failed! Error code = ");
        Serial.println(mqttClient.connectError());

        while (1);
    }

  Serial.print("Subscribing to topic: ");
  Serial.println(topic);
  Serial.println();

  // subscribe to a topic
  mqttClient.beginMessage(topic);
  mqttClient.print("Hello, world!");
  mqttClient.endMessage();
  mqttClient.subscribe(topic);
  

  // topics can be unsubscribed using:
  // mqttClient.unsubscribe(topic);

  Serial.print("Waiting for messages on topic: ");
  Serial.println(topic);
  Serial.println();
  
}

void loop() {
  int messageSize = mqttClient.parseMessage();
  if (messageSize) {
    // we received a message, print out the topic and contents
    Serial.print("Received a message with topic '");
    Serial.print(mqttClient.messageTopic());
    Serial.print("', length ");
    Serial.print(messageSize);
    Serial.println(" bytes:");

    // use the Stream interface to print the contents
    while (mqttClient.available()) {
      Serial.print((char)mqttClient.read());
    }
    Serial.println();

    Serial.println();
  }
}
