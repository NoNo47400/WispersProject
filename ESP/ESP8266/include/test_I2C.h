#ifndef TEST_I2C_H
#define TEST_I2C_H

#include <Wire.h>

//Marche pas en suivant ce tuto https://www.electronicwings.com/nodemcu/nodemcu-i2c-with-arduino-ide
// A tester directement entre esp8266 et arduino Uno

void receiveEvent(int howMany) {
Serial.println("Received: ");
 while (0 <Wire.available()) {
    char c = Wire.read();      /* receive byte as a character */
    Serial.print(c);           /* print the character */
  }
 Serial.println();             /* to newline */
}

// function that executes whenever data is requested from master
void requestEvent() {
 Wire.write("Hello Master");  /*send string on request */
}

void test_I2C_Master() {
    Wire.begin();
    pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, LOW);
    Serial.println("I2C Master");
    while(1) {
        Wire.beginTransmission(8); /* begin with device address 8 */
        Wire.write("Hello Slave");  /* sends hello string */
        Wire.endTransmission();    /* stop transmitting */
        Serial.println("Requesting Data");
        Wire.requestFrom(8, 13); /* request & read data of size 13 from slave */
        while(Wire.available()){
            char c = Wire.read();
        Serial.print(c);
        }
        Serial.println();
        delay(1000);
    }
}

void test_I2C_Slave() {
    pinMode(LED_BUILTIN, OUTPUT);
    digitalWrite(LED_BUILTIN, LOW);
    Wire.begin(8);                /* join i2c bus with address 8 */
    Serial.println("I2C Slave");
    Wire.onReceive(receiveEvent); /* register receive event */
    Wire.onRequest(requestEvent); /* register request event */
    while(1); //{
        //delay(100);
    //}
}

#endif


// #include <Arduino.h>
// #include <rubee_protocol.h>

// void setup() {
//     // Initialisation du port série
//     Serial.begin(9600);
//     while (!Serial) {
//         ; // Attente que le port série soit prêt
//     }
//     Serial.println("");

//     // Données de test
//     uint8_t test_address[8] = {0xFE, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04};
//     uint8_t test_data[MAX_DATA_LEN] = "Hello, RuBee! Ceci est une requete";
//     uint16_t data_len = strlen((char *)test_data);

//     //print_hex((uint8_t *)&test_data, data_len);

//     // Création d'une trame de requête
//     uint8_t request_pdu[MAX_PDU_LEN];
//     for(int i = 0; i < MAX_PDU_LEN; i++) {
//         request_pdu[i] = 0;
//     }
//     create_request_pdu(&request_pdu[0], 0x01, test_address, test_data, data_len);
//     Serial.println("Trame de requête créée :");
//     print_hex((uint8_t *)&request_pdu, MAX_PDU_LEN);

//     // Vérification du type d'adresse
//     uint32_t address_int = ((uint32_t)test_address[0] << 24) | ((uint32_t)test_address[1] << 16) |
//                            ((uint32_t)test_address[2] << 8) | (uint32_t)test_address[3];
    
//     if (is_broadcast_address(address_int)) {
//         Serial.println("L'adresse est une adresse de diffusion (broadcast).");
//     } else if (is_multicast_address(address_int)) {
//         Serial.println("L'adresse est une adresse de multidiffusion (multicast).");
//     } else {
//         Serial.println("L'adresse est une adresse unicast.");
//     }

//     // Décodage de la trame de requête
//     char decoded_message[MAX_DATA_LEN];
//     if (decode_pdu((uint8_t *)&request_pdu, decoded_message, MAX_PDU_LEN)) {
//         Serial.print("Message décodé de la requête : ");
//         Serial.println(decoded_message);
//     } else {
//         Serial.println("Échec du décodage de la trame de requête.");
//     }

//     // Création d'une trame de réponse
//     uint8_t response_pdu[MAX_PDU_LEN]={0};
//     uint8_t test_data_response[MAX_DATA_LEN] = "Hello back, bibou!";
//     uint16_t data_response_len = strlen((char *)test_data_response);
//     create_response_pdu(response_pdu, test_data_response, data_response_len);
//     Serial.println("\nTrame de réponse créée :");
//     print_hex((uint8_t *)&response_pdu, sizeof(ResponsePDU));

//     // Décodage de la trame de réponse
//     if (decode_pdu((uint8_t *)&response_pdu, decoded_message, MAX_PDU_LEN)) {
//         Serial.print("Message décodé de la réponse : ");
//         Serial.println(decoded_message);
//     } else {
//         Serial.println("Échec du décodage de la trame de réponse.");
//     }
// }

// void loop() {
//     // Rien à faire dans la boucle principale pour ce test
// }