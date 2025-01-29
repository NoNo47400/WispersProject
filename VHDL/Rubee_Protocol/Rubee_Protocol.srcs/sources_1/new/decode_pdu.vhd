----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 01/03/2025 11:51:49 AM
-- Design Name: Rubee_v0.1
-- Module Name: decode_pdu - Behavioral
-- Project Name: Wispers
-- Target Devices: Basys3
-- Revision 0.01 - File Updated
-- Additional Comments: Decode incoming PDU frames
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decode_request_pdu is
    Port (
        clk             : in  STD_LOGIC;
        rst             : in  STD_LOGIC;
        bit_in          : in  STD_LOGIC;
        header_validity : in  STD_LOGIC;
        
        pdu_out         : out STD_LOGIC_VECTOR(127 downto 0);
        pdu_validity    : out STD_LOGIC
    );
end decode_request_pdu;

architecture Behavioral of decode_request_pdu is
    constant HEADER_SIZE : integer := 3;
    constant PROTOCOLE_SIZE : integer := 1;
    constant ADDRESS_SIZE : integer := 8;
    
    constant FCS_SIZE : integer := 2;
    
    signal fcs_reg        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal pdu_internal   : STD_LOGIC_VECTOR(127 downto 0) := (others => '0');
    signal bit_count      : integer := 0;
    signal data_length     : STD_LOGIC_VECTOR(0 to 3) := (others => '0');
    signal header_detected : std_logic := '0';
    signal crc_valid      : std_logic := '0';
    
    -- Signals for nibble_fcs
    signal fcs_start      : std_logic := '0';
    signal clk_fcs        : std_logic := '0';
    signal fcs_reset      : std_logic := '0';
    signal fcs_data_in    : std_logic_vector(3 downto 0);
    signal fcs_done       : std_logic := '0';
    signal fcs_out        : std_logic_vector(7 downto 0);

begin
    -- Instantiate the nibble_fcs module
    fcs_calc: entity work.nibble_fcs
        port map (
            clk => clk_fcs,
            reset => fcs_reset,
            start => fcs_start,
            nibble_in => fcs_data_in,
            crc_out => fcs_out,
            done => fcs_done
        );

    process(clk, rst)
    begin
        if rst = '1' then
            fcs_reg <= (others => '0');
            pdu_internal <= (others => '0');
            bit_count <= 0;
            data_length <= (others => '0');
            pdu_out <= (others => '0');
            header_detected <= '0';
            pdu_validity <= '0';
            fcs_reset <= '1';
            fcs_start <= '0';
        elsif rising_edge(clk) then
            if header_validity = '1' then
                -- Header detected, start receiving PDU
                header_detected <= '1';
                bit_count <= 0;
                fcs_reset <= '0';
                fcs_start <= '1';
            elsif header_detected = '1' then
                -- Shift bit into PDU
                pdu_internal(bit_count) <= bit_in;
                bit_count <= bit_count + 1;
                -- Extract data length
                data_length(0) <= pdu_internal(12);
                data_length(1) <= pdu_internal(13);
                data_length(2) <= pdu_internal(14);
                data_length(3) <= pdu_internal(15);

                -- Check if PDU is complete
                if bit_count <= (HEADER_SIZE*4 + PROTOCOLE_SIZE*4 + ADDRESS_SIZE*4 + (to_integer(unsigned(data_length)) * 4 *8)) then
                    -- Provide nibbles to the CRC calculator
                    if ((bit_count-1) mod 4 = 3) then
                        --fcs_data_in <= pdu_internal(bit_count downto bit_count-3);
                        clk_fcs <= '1';
                    else
                        clk_fcs <= '0';
                    end if;
                else
                    -- We need to have received the fcs value before comparing it to the computed one
                    
                    if bit_count = (HEADER_SIZE*4 + PROTOCOLE_SIZE*4 + ADDRESS_SIZE*4 + (to_integer(unsigned(data_length))* 4 * 8) + FCS_SIZE*4) then
                        -- Verify FCS
                        if fcs_out = pdu_internal(bit_count - 8) & pdu_internal(bit_count - 7) & pdu_internal(bit_count-6) & pdu_internal(bit_count-5) & pdu_internal(bit_count-4) & pdu_internal(bit_count-3) & pdu_internal(bit_count-2) & pdu_internal(bit_count-1) then
                            pdu_validity <= '1';
                            pdu_out <= pdu_internal; -- Example output
                        else
                            pdu_validity <= '0';
                        end if;
                        header_detected <= '0'; -- Reset for next frame
                    end if;
                end if;
            end if;
        end if;
    end process;
    fcs_data_in <= pdu_internal(bit_count-4) & pdu_internal(bit_count-3) & pdu_internal(bit_count-2) & pdu_internal(bit_count-1) when bit_count >= 4 else
                   "0000";
end Behavioral;