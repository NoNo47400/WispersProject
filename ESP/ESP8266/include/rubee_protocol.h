#ifndef RUBEE_PROTOCOL_H
#define RUBEE_PROTOCOL_H

#include "data_field.h"
#include <string.h>
#include <Wire.h>
#include <Arduino.h>
#include <vector>

#define SYNC_REQUEST_LEN 3
#define PROTO_LEN 1
#define ADDR_LEN 8
#define MAX_DATA_LEN 100
#define FCS_LEN 2
#define END_LEN 2
#define MAX_PDU_LEN (SYNC_REQUEST_LEN + PROTO_LEN + ADDR_LEN + MAX_DATA_LEN + FCS_LEN + END_LEN)
#define I2C_ADDRESS 0x08
// antes pour le calcul de la FCS
#define FCS_POLYNOMIAL 0x07

// Du côté du Hub pas besoin de repondre, on est le master, on fait uniquement des requetes

// Structure de la trame de requête (Request PDU)
struct RequestPDU {
    std::vector<nibble> sync;  // Séquence de synchronisation
    nibble protocol_selector;  // Sélecteur de protocole
    std::vector<nibble> address;  // Adresse
    DataField data;  // Données
    std::vector<nibble> fcs;  // FCS
    std::vector<nibble> end;  // Séquence de fin

    RequestPDU();
};

class RubeeProtocol {
private:
    std::vector<DataField> dataFields;
public:
    RequestPDU requestPDU;
    RubeeProtocol();
    RequestPDU create_request_pdu(nibble protocol_selector, const std::vector<nibble>& address, const DataField& data);
    void send_request_pdu(const RequestPDU& pdu);
    bool read_data(DataField *dataField);
    void get_data(int num_bytes);
    DataField get_data_field(const std::vector<nibble>& data);

private:
    uint16_t serialize_request_pdu(const RequestPDU& pdu, std::vector<nibble>& buffer);
    uint8_t calculate_fcs(const std::vector<nibble>& data);
    bool validate_pdu(const std::vector<nibble>& data);
    void cpy_datafileds(DataField *dest, const DataField& src);
    void cpy_nibble(std::vector<nibble>& dest, const std::vector<nibble>& src);
    size_t count_nibbles(const std::vector<nibble>& data);
};

#endif // RUBEE_PROTOCOL_H
