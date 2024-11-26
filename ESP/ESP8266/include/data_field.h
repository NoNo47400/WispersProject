#ifndef MY_DATA_FIELD_H
#define MY_DATA_FIELD_H

#include <Arduino.h> // Nécessaire pour utiliser String dans les environnements Arduino

// Classe pour représenter les champs des données
class DataField {
public:
    String address;   // Adresse associée aux données
    String data;      // Contenu des données
    bool isFinished;  // Indique si le traitement des données est terminé

    // Constructeur
    DataField(String addr, String d, bool finished)
        : address(addr), data(d), isFinished(finished) {}
};

#endif