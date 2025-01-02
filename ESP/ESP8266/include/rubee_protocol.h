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
// Polynomial for FCS calculation
#define FCS_POLYNOMIAL 0x07

// On the Hub side, no need to respond, we are the master, we only make requests

// Structure of the request frame (Request PDU)
struct RequestPDU {
    std::vector<nibble> sync;  // Synchronization sequence
    nibble protocol_selector;  // Protocol selector
    std::vector<nibble> address;  // Address
    DataField data;  // Data
    std::vector<nibble> fcs;  // FCS
    std::vector<nibble> end;  // End sequence

    RequestPDU();
};

class RubeeProtocol {
private:
    std::vector<DataField> dataFields;
    bool simulation_mode = false;
public:
    RequestPDU requestPDU;
    RubeeProtocol(bool simulate) : simulation_mode(simulate) {}
    RequestPDU create_request_pdu(nibble protocol_selector, const std::vector<nibble>& address, const DataField& data);
    void send_request_pdu(const RequestPDU& pdu);
    bool read_data(DataField *dataField);
    void get_data(int num_bytes);
    DataField get_data_field(const std::vector<nibble>& data);

    // debug methods
    void print_nibble_vector(const std::vector<nibble>& data, const char* label);
    
    // simulation method
    std::vector<nibble> simulate_i2c_response();
    void set_simulation_mode(bool simulate) { simulation_mode = simulate; }

private:
    uint16_t serialize_request_pdu(const RequestPDU& pdu, std::vector<nibble>& buffer);
    uint8_t calculate_fcs(const std::vector<nibble>& data);
    bool validate_pdu(const std::vector<nibble>& data);
};

#endif // RUBEE_PROTOCOL_H
