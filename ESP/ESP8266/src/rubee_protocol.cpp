#include "rubee_protocol.h"

// Constructor definition
RequestPDU::RequestPDU() : sync(SYNC_REQUEST_LEN), address(ADDR_LEN), fcs(FCS_LEN), end(END_LEN) {}

void RubeeProtocol::cpy_nibble(std::vector<nibble>& dest, const std::vector<nibble>& src) {
    dest = src;
}

size_t RubeeProtocol::count_nibbles(const std::vector<nibble>& data) {
    return data.size();
}

void RubeeProtocol::cpy_datafileds(DataField *dest, const DataField& src) {
    uint8_t length = src.data_length[0].to_ulong() + (src.data_length[1].to_ulong() << 4);
    dest->data_length[0] = src.data_length[0];
    dest->data_length[1] = src.data_length[1];
    dest->patch_address = src.patch_address;
    for (uint16_t i = 0; i < length - 2; i++) {
        dest->data[i] = src.data[i];
    }
    dest->isFinished = src.isFinished;
}

RubeeProtocol::RubeeProtocol() {
    // Constructor implementation
}

// A surveiller avec les nibbles si ca produit le resultat voulu
// Fonction pour calculer la FCS en utilisant un polynôme standard (x^8 + x^2 + x + 1)
uint8_t RubeeProtocol::calculate_fcs(const std::vector<nibble>& data) {
    uint8_t fcs = 0x00;
    for (const auto& n : data) {
        fcs ^= n.to_ulong();
        for (uint8_t j = 0; j < 8; j++) {
            if (fcs & 0x80) {
                fcs = (fcs << 1) ^ FCS_POLYNOMIAL;
            } else {
                fcs <<= 1;
            }
        }
    }
    return fcs;
}

// Fonction pour créer une trame de requête (Request PDU)
RequestPDU RubeeProtocol::create_request_pdu(nibble protocol_selector, const std::vector<nibble>& address, const DataField& data) {
    RequestPDU pdu;
    pdu.sync = {0x0, 0x0, 0x5};
    pdu.end = {0x0, 0x0};
    pdu.protocol_selector = protocol_selector;
    cpy_nibble(pdu.address, address);
    cpy_datafileds(&pdu.data, data);

    std::vector<nibble> buffer_to_send;
    serialize_request_pdu(pdu, buffer_to_send);
    uint8_t fcs_result = calculate_fcs(buffer_to_send);
    pdu.fcs = {nibble(fcs_result & 0x0F), nibble(fcs_result >> 4)};

    return pdu;
}

// Fonction pour valider une trame PDU
bool RubeeProtocol::validate_pdu(const std::vector<nibble>& data) {
    if (data.size() < (SYNC_REQUEST_LEN + PROTO_LEN + ADDR_LEN + FCS_LEN + END_LEN)) {
        return false;
    }
    uint16_t fcs_calculation_len = data.size() - FCS_LEN - END_LEN;
    uint8_t fcs_calculated = calculate_fcs(data);
    return fcs_calculated == ((data[fcs_calculation_len + 1].to_ulong() << 4) + data[fcs_calculation_len].to_ulong());
}

// Fonction pour sérialiser une trame request PDU dans un buffer
uint16_t RubeeProtocol::serialize_request_pdu(const RequestPDU& pdu, std::vector<nibble>& buffer) {
    uint16_t total_len = SYNC_REQUEST_LEN + PROTO_LEN + ADDR_LEN + (pdu.data.data_length[0].to_ulong() + (pdu.data.data_length[1].to_ulong() << 4)) + FCS_LEN + END_LEN;
    if (total_len > MAX_PDU_LEN) {
        return 0;
    }

    buffer.clear();
    buffer.insert(buffer.end(), pdu.sync.begin(), pdu.sync.end());
    buffer.push_back(pdu.protocol_selector);
    buffer.insert(buffer.end(), pdu.address.begin(), pdu.address.end());
    buffer.push_back(pdu.data.data_length[0]);
    buffer.push_back(pdu.data.data_length[1]);
    buffer.push_back(pdu.data.patch_address);
    buffer.insert(buffer.end(), pdu.data.data, pdu.data.data + (pdu.data.data_length[0].to_ulong() + (pdu.data.data_length[1].to_ulong() << 4) - 2));
    buffer.insert(buffer.end(), pdu.fcs.begin(), pdu.fcs.end());
    buffer.insert(buffer.end(), pdu.end.begin(), pdu.end.end());

    return total_len;
}

void RubeeProtocol::send_request_pdu(const RequestPDU& pdu) {
    std::vector<nibble> buffer;
    serialize_request_pdu(pdu, buffer);
    Wire.beginTransmission(I2C_ADDRESS);
    for (const auto& n : buffer) {
        Wire.write(n.to_ulong());
    }
    Wire.endTransmission();
}

DataField RubeeProtocol::get_data_field(const std::vector<nibble>& data) {
    uint16_t index = SYNC_REQUEST_LEN + PROTO_LEN + ADDR_LEN;
    DataField dataField_local;
    dataField_local.data_length[0] = data[index];
    dataField_local.data_length[1] = data[index + 1];
    uint8_t length = dataField_local.data_length[0].to_ulong() + (dataField_local.data_length[1].to_ulong() << 4);
    dataField_local.patch_address = data[index + 2];
    for (uint16_t i = index + 3, y = 0; i < index + length - 2; i++, y++) {
        dataField_local.data[y] = data[i];
    }
    dataField_local.isFinished = data[index + length - 1];
    return dataField_local;
}

void RubeeProtocol::get_data(int num_bytes) {
    if (num_bytes > 0) {
        std::vector<nibble> buffer(num_bytes);
        for (int i = 0; i < num_bytes; i++) {
            buffer[i] = Wire.read();
        }
        dataFields.push_back(get_data_field(buffer));
    }
}

bool RubeeProtocol::read_data(DataField *dataField) {
    if (!dataFields.empty()) {
        *dataField = dataFields.front();
        dataFields.erase(dataFields.begin());
        return true;
    }
    return false;
}