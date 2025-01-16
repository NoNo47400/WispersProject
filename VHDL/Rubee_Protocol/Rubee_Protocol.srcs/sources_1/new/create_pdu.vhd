----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 11/20/2024 03:39:00 PM
-- Design Name: Rubee_v0.1
-- Module Name: create_pdu - Behavioral
-- Project Name: Wispers
-- Target Devices: Basys3
-- Description:
--      This module creates Protocol Data Units (PDU) for the Rubee Protocol.
--
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity create_pdu is
    generic (
        SYNC_LEN_REQUEST      : integer := 3;       -- Length (number of nibble) of sync field
        SYNC_LEN_RESPONSE     : integer := 2;
        PROTOCOL_LEN  : integer := 1;       -- Length (number of nibble) of protocol selector field
        ADDR_LEN      : integer := 8;       -- Length (number of nibble) of address field
        MAX_DATA_LEN  : integer := 128;     -- Maximum length of data field
        FCS_LEN       : integer := 2;       -- Length (number of nibble) of FCS field
        END_LEN       : integer := 2;       -- Length (number of nibble) of end field
        PDU_MAX_LEN   : integer := 256      -- Maximum (number of nibble) PDU length -> impacte le NIBBLE_COUNT de nibble_crc
    );
    port (
        clk             : in std_logic;                      -- Clock input
        reset           : in std_logic;                      -- Synchronous reset
        start           : in std_logic;                      -- Start signal to begin PDU creation
        pdu_type        : in std_logic;                      -- PDU Type (request or receive) selection
        protocol_selector : in std_logic_vector(3 downto 0); -- Protocol selector byte
        address         : in std_logic_vector(ADDR_LEN*4-1 downto 0); -- Address field
        data_in         : in std_logic_vector(MAX_DATA_LEN*4-1 downto 0); -- Input data
        data_len        : in integer range 0 to MAX_DATA_LEN; -- Length of input data
        
        pdu_out         : out std_logic_vector(PDU_MAX_LEN*4-1 downto 0); -- Output PDU
        pdu_len         : out integer range 0 to PDU_MAX_LEN; -- Length of the created PDU
        done            : out std_logic                      -- Done signal
    );
end create_pdu;

architecture Behavioral of create_pdu is
    -- Constants
    constant SYNC_REQUEST : std_logic_vector(SYNC_LEN_REQUEST*4-1 downto 0) := "000000000101"; -- Sync field
    constant SYNC_RESPONSE : std_logic_vector(SYNC_LEN_RESPONSE*4-1 downto 0) := "00000101"; -- Sync field
    constant END_FIELD : std_logic_vector(END_LEN*4-1 downto 0) := (others => '0');   -- End field

    -- Internal signals
    signal buffer_sig  : std_logic_vector(PDU_MAX_LEN*4-1 downto 0) := (others => '0');  -- PDU buffer
    signal index       : integer range 0 to PDU_MAX_LEN*4 := PDU_MAX_LEN*4;              -- Buffer index
    signal active      : std_logic := '0';                                               -- Active flag
    signal nibble_index  : integer range 0 to PDU_MAX_LEN := 0;                          -- Byte index for FCS
    signal pdu_len_sig : integer range 0 to PDU_MAX_LEN := 0;                          -- PDU length (number of nibble)
    signal done_sig    : std_logic := '0';                                             -- PDU creation completion flag
    signal fcs_done    : std_logic := '0';                                             -- FCS completion flag
    signal fcs_out     : std_logic_vector(7 downto 0);                                 -- FCS output

    -- Signals for calculate_fcs instance
    signal fcs_start   : std_logic := '0';                   -- Start signal for FCS calculation
    signal fcs_reset   : std_logic := '0';                   -- Reset signal for FCS calculation
    signal fcs_data_in : std_logic_vector(3 downto 0);       -- Input data for FCS calculation

begin
    -- Instantiate the nibble_crc module
    fcs_calc: entity work.nibble_crc
        port map (
            clk => clk,
            reset => fcs_reset,
            start => fcs_start,
            nibble_in => fcs_data_in,
            crc_out => fcs_out,
            done => fcs_done
        );

    -- Main process for PDU creation
    process(clk)
    begin
        if reset = '1' then
                -- Reset all internal signals
                buffer_sig <= (others => '0');
                pdu_len_sig <= 0;
                done_sig <= '0';
                active <= '0';
                fcs_reset <= '1';
                fcs_start <= '0';
                nibble_index <= 0;
                index <= PDU_MAX_LEN*4;
        end if;
        if rising_edge(clk) then
            if start = '1' and active = '0' then
                buffer_sig<=(others => '0');
                
                -- Start PDU creation
                active <= '1';
                fcs_reset <= '0';
                
                -- Initialize buffer index depending on the PDU type
                if(pdu_type = '0') then
                    -- Compute total PDU_Request length
                    pdu_len_sig <= (SYNC_LEN_REQUEST) + (PROTOCOL_LEN) + (ADDR_LEN) + (data_len) + (FCS_LEN) + (END_LEN);
                    -- Add sync field, protocol selector, address field, data field, placeholder for FCS, and end field
                   buffer_sig(index - 1 downto (index - (SYNC_LEN_REQUEST*4) - (PROTOCOL_LEN*4) - (ADDR_LEN*4) - (data_len*4) - (FCS_LEN*4) - (END_LEN*4) )) <= SYNC_REQUEST & protocol_selector & address & data_in((MAX_DATA_LEN*4)-1 downto (MAX_DATA_LEN*4)-(data_len*4)) & "00000000" & END_FIELD; 
                else
                    -- Compute total PDU_Response length
                    pdu_len_sig <= (SYNC_LEN_RESPONSE) + (data_len) + (FCS_LEN) + (END_LEN);
                   -- Add sync field, address field, data field, placeholder for FCS, and end field
                    buffer_sig(index - 1 downto (index - (SYNC_LEN_RESPONSE*4) - (data_len*4) - (FCS_LEN*4) - (END_LEN*4) )) <= SYNC_RESPONSE & data_in((MAX_DATA_LEN*4)-1 downto (MAX_DATA_LEN*4)-(data_len*4)) & "00000000" & END_FIELD;
                end if;
                
                -- Initialize FCS calculation
                fcs_start <= '1';
                nibble_index <= 0; -- Start processing the first byte
                
        
            elsif active = '1' then               
                -- Proceed to the next byte for FCS calculation
                if nibble_index < (pdu_len_sig - FCS_LEN - END_LEN) then
                    -- Feed the next byte into FCS
                    fcs_data_in <= buffer_sig(index-(nibble_index*4)-1 downto index-(nibble_index*4)-4);
                    nibble_index <= nibble_index + 1;
                elsif nibble_index = (pdu_len_sig - FCS_LEN - END_LEN) and fcs_start /= '0' then
                    -- Assign output
                    fcs_start <= '0';
                else
                    -- Finalize FCS insertion once all bytes are processed
                     if(pdu_type = '0') then
                        buffer_sig(index - (SYNC_LEN_REQUEST*4) - (PROTOCOL_LEN*4) - (ADDR_LEN*4) - (data_len*4) - 1 downto index - (SYNC_LEN_REQUEST*4) - (PROTOCOL_LEN*4) - (ADDR_LEN*4) - (data_len*4) - FCS_LEN*4) <= fcs_out;
                     else
                        buffer_sig(index - (SYNC_LEN_RESPONSE*4) - (data_len*4) - 1 downto index - (SYNC_LEN_RESPONSE*4) - (data_len*4) - FCS_LEN*4) <= fcs_out;
                     end if;
                    -- Assign output
                    active <= '0';
                    done_sig <= '1';
                end if;
            end if;
        end if;
        if pdu_len_sig < FCS_LEN + END_LEN then
            pdu_len <= 0;
        else
            pdu_len <= pdu_len_sig - FCS_LEN - END_LEN;
        end if;
    end process;
    done <= done_sig;
    pdu_out <= buffer_sig;
end Behavioral;