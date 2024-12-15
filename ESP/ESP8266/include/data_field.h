#ifndef MY_DATA_FIELD_H
#define MY_DATA_FIELD_H

#include <Arduino.h> // Nécessaire pour utiliser String dans les environnements Arduino
#include <bitset>

using nibble = std::bitset<4>; // Création du type nibble sur 4bits

// Classe pour représenter les champs des données
class DataField {
public:
    nibble data_length[2]; // Longueur des données
    nibble patch_address;   // Adresse associée aux données
    nibble* data;      // Contenu des données
    nibble isFinished;  // Indique si le traitement des données est terminé

    // Constructeur
    DataField() {
        data_length[0] = 0;
        data_length[1] = 0;
        patch_address = 0;
        data = nullptr;
        isFinished = 0;
    }

    DataField(nibble len[2], nibble addr, nibble* d, nibble finished)
        : patch_address(addr), data(d), isFinished(finished) {
        data_length[0] = len[0];
        data_length[1] = len[1];
    }
};

#endif