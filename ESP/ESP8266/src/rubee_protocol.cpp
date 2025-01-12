#include "rubee_protocol.h"

// Constructor definition
RequestPDU::RequestPDU() : sync(SYNC_REQUEST_LEN), address(ADDR_LEN), fcs(FCS_LEN), end(END_LEN) {}

// Calculate FCS using a standard polynomial (x^8 + x^2 + x + 1)
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

// Create a request PDU frame
RequestPDU RubeeProtocol::create_request_pdu(nibble protocol_selector, const std::vector<nibble>& address, const DataField& data) {
    RequestPDU pdu;
    pdu.sync = {0x0, 0x0, 0x5};
    pdu.end = {0x0, 0x0};
    pdu.protocol_selector = protocol_selector;
    pdu.address = address;
    pdu.data = data;
    std::vector<nibble> buffer_to_send;
    serialize_request_pdu(pdu, buffer_to_send);
    print_nibble_vector(buffer_to_send, "Buffer to Send without fcs");
    uint8_t fcs_result = calculate_fcs(std::vector<nibble>(buffer_to_send.begin(), buffer_to_send.end() - 4));
    Serial.print("Calculated FCS result: 0x");
    Serial.println(fcs_result, HEX);
    pdu.fcs = {nibble(fcs_result >> 4), nibble(fcs_result & 0x0F)};
    serialize_request_pdu(pdu, buffer_to_send);
    print_nibble_vector(buffer_to_send, "Buffer to Send with fcs");
    return pdu;
}

// Validate a PDU frame
bool RubeeProtocol::validate_pdu(const std::vector<nibble>& data) {
    if (data.size() < ((SYNC_REQUEST_LEN-1) + FCS_LEN + END_LEN)) {
        Serial.println("Error: PDU too short");
        return false;
    }
    // Create a temporary vector without FCS and END for FCS calculation
    std::vector<nibble> data_for_fcs(data.begin(), data.end() - 4);
    
    uint8_t fcs_calculated = calculate_fcs(data_for_fcs);
    uint8_t fcs_received = (data[data.size() - 3].to_ulong()) | 
                          (data[data.size() - 4].to_ulong() << 4);
    
    Serial.print("Calculated FCS: 0x");
    Serial.println(fcs_calculated, HEX);
    Serial.print("Received FCS: 0x");
    Serial.println(fcs_received, HEX);
    
    return fcs_calculated == fcs_received;
}

// Serialize a request PDU frame into a buffer
uint16_t RubeeProtocol::serialize_request_pdu(const RequestPDU& pdu, std::vector<nibble>& buffer) {
    // Calculate total length:
    // sync(2) + protocol(1) + address(8) + data_length(2) + patch_address(1) + actual_data(n) + isFinished(1) + fcs(2) + end(2)
    uint16_t data_size = pdu.data.data_length[1].to_ulong() + (pdu.data.data_length[0].to_ulong() << 4);
    uint16_t total_len = SYNC_REQUEST_LEN + PROTO_LEN + ADDR_LEN + 2 + 1 + data_size + 1 + FCS_LEN + END_LEN;
    
    if (total_len > MAX_PDU_LEN) {
        Serial.println("Error: PDU too long");
        return 0;
    }

    buffer.clear();
    buffer.insert(buffer.end(), pdu.sync.begin(), pdu.sync.end());
    buffer.push_back(pdu.protocol_selector);
    // Ensure the address field is 8 nibbles long, fill with 0 if necessary
    std::vector<nibble> address_filled = pdu.address;
    while (address_filled.size() < 8) {
        address_filled.insert(address_filled.begin(), 0x0);
    }
    buffer.insert(buffer.end(), address_filled.begin(), address_filled.end());
    buffer.insert(buffer.end(), pdu.data.data_length.begin(), pdu.data.data_length.end());
    buffer.push_back(pdu.data.patch_address);
    buffer.insert(buffer.end(), pdu.data.data.begin(), pdu.data.data.end());
    buffer.push_back(pdu.data.isFinished);
    // Ensure the FCS field is 2 nibbles long, fill with 0 if necessary
    std::vector<nibble> fcs_filled = pdu.fcs;
    while (fcs_filled.size() < 2) {
        fcs_filled.push_back(0x0);
    }
    buffer.insert(buffer.end(), fcs_filled.begin(), fcs_filled.end());
    buffer.insert(buffer.end(), pdu.end.begin(), pdu.end.end());

    Serial.print("Data size in serialize_request_pdu: ");
    Serial.println(data_size);
    Serial.print("Total PDU length: ");
    Serial.println(total_len);

    return total_len;
}

// Send a request PDU frame
void RubeeProtocol::send_request_pdu(const RequestPDU& pdu) {
    if (simulation_mode) {
        Serial.println("Running in simulation mode - no actual I2C transmission");
        return;
    }
    
    // Original I2C sending code...
    std::vector<nibble> buffer;
    serialize_request_pdu(pdu, buffer);
    Wire.beginTransmission(I2C_ADDRESS);
    for (const auto& n : buffer) {
        Wire.write(n.to_ulong());
    }
    Wire.endTransmission();
}

// Extract data fields from a received buffer
DataField RubeeProtocol::get_data_field(const std::vector<nibble>& data) {
    uint16_t index = (SYNC_REQUEST_LEN-1);
    DataField dataField_local;
    
    dataField_local.data_length[0] = data[index];
    dataField_local.data_length[1] = data[index + 1];
    
    uint8_t length = dataField_local.data_length[1].to_ulong() + 
                    (dataField_local.data_length[0].to_ulong() << 4);
    
    dataField_local.patch_address = data[index + 2];
    
    // Copy data
    for (uint16_t i = index + 3; i < index + length - 1; i++) {
        dataField_local.data.push_back(data[i]);
    }
    
    dataField_local.isFinished = data[index + length];
    return dataField_local;
}

// TO TEST
// Handle received data from I2C
void RubeeProtocol::get_data(int num_bytes) {
    if (num_bytes > 0) {
        std::vector<nibble> buffer(num_bytes);
        for (int i = 0; i < num_bytes; i++) {
            buffer[i] = Wire.read();
        }
        DataField dataField = get_data_field(buffer);
        // Check if the data corresponds to the address field
        bool address_match = true;
        for (size_t i = 0; i < requestPDU.address.size(); i++) {
            if (requestPDU.address[i] != buffer[SYNC_REQUEST_LEN + PROTO_LEN + i]) {
                address_match = false;
                break;
            }
        }
        if (address_match) {
            dataFields.push_back(dataField);
        }
    }
}

// Read data from the data fields
bool RubeeProtocol::read_data(DataField *dataField) {
    if (simulation_mode) {
        std::vector<nibble> simulated_response = simulate_i2c_response();
        Serial.println("Simulated I2C response:");
        print_nibble_vector(simulated_response, "RESPONSE");
        
        if (validate_pdu(simulated_response)) {
            *dataField = get_data_field(simulated_response);
            return true;
        }
        return false;
    }
    
    // Original I2C reading code...
    if (!dataFields.empty()) {
        *dataField = dataFields.front();
        dataFields.erase(dataFields.begin());
        return true;
    }
    return false;
}

void RubeeProtocol::print_nibble_vector(const std::vector<nibble>& data, const char* label) {
    Serial.print(label);
    Serial.print(": ");
    for(const auto& n : data) {
        Serial.print(n.to_ulong(), HEX); // Convertir le nibble en unsigned long avant l'affichage
        Serial.print(" ");
    }
    Serial.println();
}

std::vector<nibble> RubeeProtocol::simulate_i2c_response() {
    std::vector<nibble> response;
    
    // Sync sequence (0x05) - 2 nibbles
    response.push_back(0x0);
    response.push_back(0x5);
    
    // Récupérer l'adresse demandée depuis le requestPDU
    uint8_t requested_address = 0;
    if (!requestPDU.address.empty()) {
        requested_address = requestPDU.address.back().to_ulong();
    }
    
    // Incrémenter le compteur pour faire varier les données
    simulation_counter++;
    
    // Générer des données simulées selon l'adresse avec variation
    std::vector<nibble> data_content;
    uint8_t variation = simulation_counter % 4; // Variation entre 0 et 3
    
    switch(requested_address) {
        case 2:
            data_content = {
                nibble((0x1 + variation) & 0x0F), 
                nibble((0x5 + variation) & 0x0F)
            };
            break;
        case 4:
            data_content = {
                nibble((0x3 + variation) & 0x0F), 
                nibble((0x0 + variation) & 0x0F)
            };
            break;
        case 6:
            data_content = {
                nibble((0x2 + variation) & 0x0F), 
                nibble((0x5 + variation) & 0x0F)
            };
            break;
        default:
            data_content = {
                nibble(variation & 0x0F), 
                nibble((variation + 1) & 0x0F)
            };
    }
    
    // ...rest of the existing simulation code...

    Serial.print("Variation counter: ");
    Serial.println(variation);
    
    return response;
}