#ifndef MY_DATA_FIELD_H
#define MY_DATA_FIELD_H

#include <Arduino.h>
#include <bitset>
#include <vector>

using nibble = std::bitset<4>;

class DataField {
public:
    std::vector<nibble> data_length;  // Changed to vector
    nibble patch_address;
    std::vector<nibble> data;         // Changed to vector
    nibble isFinished;

    // Constructor
    DataField() : data_length(2), patch_address(0), isFinished(0) {
        data_length[0] = 0;
        data_length[1] = 0;
    }

    // Copy constructor
    DataField(const DataField& other) : 
        data_length(other.data_length),
        patch_address(other.patch_address),
        data(other.data),
        isFinished(other.isFinished) {}
};

#endif