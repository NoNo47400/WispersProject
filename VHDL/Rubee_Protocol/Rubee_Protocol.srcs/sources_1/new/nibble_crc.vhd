----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 11/20/2024 02:00:00 PM
-- Design Name: Rubee_v0.1
-- Module Name: nibble_crc - Behavioral
-- Project Name: Wisper
-- Target Devices: Basys3
-- Description: 
--   This module computes the CRC for nibbles (4-bit data) as part of the Rubee Protocol.
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nibble_crc is
    generic (
        NIBBLE_COUNT : integer := 8  -- Number of nibbles in the input data
    );
    port (
        clk        : in std_logic;                             -- Clock input
        reset      : in std_logic;                             -- Reset signal
        start      : in std_logic;                             -- Start signal
        nibble_in  : in std_logic_vector(3 downto 0);          -- 4-bit nibble input
        nibble_number : in integer range 0 to NIBBLE_COUNT;       -- Number of nibbles to process
        crc_out    : out std_logic_vector(7 downto 0);         -- 8-bit CRC output
        done       : out std_logic                             -- Done signal
    );
end nibble_crc;

architecture behavioral of nibble_crc is
    -- Lookup table
    type table_type is array(0 to 15) of std_logic_vector(7 downto 0);
    constant table : table_type := (
        "00000000", "00000111", "00001110", "00001001", -- 0x00, 0x07, 0x0e, 0x09
        "00011100", "00011011", "00010010", "00010101", -- 0x1c, 0x1b, 0x12, 0x15
        "00111000", "00111111", "00110110", "00110001", -- 0x38, 0x3f, 0x36, 0x31
        "00100100", "00100011", "00101010", "00101101"  -- 0x24, 0x23, 0x2a, 0x2d
    );

    -- Internal signals
    signal crc        : std_logic_vector(7 downto 0) := (others => '0'); -- CRC register
    signal nibble_idx : integer range 0 to NIBBLE_COUNT - 1 := 0;         -- Nibble index
    signal active     : std_logic := '0';                                -- Active flag

begin
    -- Main process for CRC calculation
    process(clk)
        variable index : integer range 0 to 15; -- Index for table lookup
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Reset all internal signals
                crc <= (others => '0');
                nibble_idx <= 0;
                active <= '0';
                done <= '0';
            elsif start = '1' and active = '0' then
                -- Start CRC calculation
                active <= '1';
                done <= '0';
                nibble_idx <= 0;
                crc <= (others => '0'); -- Initialize CRC
            elsif active = '1' then
                if nibble_idx < nibble_number then
                -- Calculate table index
                index := to_integer(unsigned((crc(7 downto 4)) xor nibble_in));
                -- Update CRC using table and left-shifted CRC
                crc <= table(index) xor (crc(3 downto 0) & "0000");

                -- Increment nibble index
                nibble_idx <= nibble_idx + 1;
                else
                    -- Complete CRC calculation
                    active <= '0';
                    done <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Assign CRC output
    crc_out <= crc;

end behavioral;
