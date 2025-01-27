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
        PDU_MAX_LEN   : integer := 256      -- Maximum (number of nibble) PDU length -> impacte le NIBBLE_COUNT de nibble_fcs
    );
    port (
        clk             : in std_logic;                      -- Clock input
        reset           : in std_logic;                      -- Synchronous reset
        start           : in std_logic;                      -- Start signal to begin PDU creation
        pdu_type        : in std_logic;                      -- PDU Type (request or receive) selection
        protocol_selector : in std_logic_vector(3 downto 0); -- Protocol selector byte
        address         : in std_logic_vector(ADDR_LEN*4-1 downto 0); -- Address field
        data_in         : in std_logic_vector(MAX_DATA_LEN*4-1 downto 0); -- Input data
        data_len        : in std_logic_vector(7 downto 0); -- Length of input data
        
        pdu_out         : out std_logic_vector(PDU_MAX_LEN*4-1 downto 0); -- Output PDU
        pdu_out_reversed : out std_logic_vector(0 to PDU_MAX_LEN*4-1); -- Output PDU
        pdu_len         : out std_logic_vector(7 downto 0); -- Length of the created PDU
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
    signal index       : unsigned(16-1 downto 0);                               -- Buffer index
    signal active      : std_logic := '0';                                               -- Active flag
    signal nibble_index  : unsigned(16-1 downto 0);                             -- Byte index for FCS
    signal pdu_len_sig : unsigned(16-1 downto 0);                            -- PDU length (number of nibble)
    signal data_len_sig : unsigned(8-1 downto 0);                          -- Data length (number of nibble)
    signal done_sig    : std_logic := '0';                                               -- PDU creation completion flag
    signal fcs_done    : std_logic := '0';                                               -- FCS completion flag
    signal fcs_out     : std_logic_vector(7 downto 0);                                   -- FCS output
    -- Signals for calculate_fcs instance
    signal fcs_start   : std_logic := '0';                   -- Start signal for FCS calculation
    signal fcs_reset   : std_logic := '0';                   -- Reset signal for FCS calculation
    signal fcs_data_in : std_logic_vector(3 downto 0);       -- Input data for FCS calculation
    -- Signal for reverse process
    signal reverse_process_done : std_logic := '0';          -- Reverse process flag

begin
    -- Instantiate the nibble_fcs module
    fcs_calc: entity work.nibble_fcs
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
                pdu_len_sig <= (others => '0');
                done_sig <= '0';
                active <= '0';
                fcs_reset <= '1';
                fcs_start <= '0';
                nibble_index <= (others => '0');
                index <= to_unsigned((PDU_MAX_LEN*4), 16);
        end if;
        if rising_edge(clk) then
            if start = '1' and active    = '0' then
                buffer_sig<=(others => '0');
                
                -- Start PDU creation
                active <= '1';
                fcs_reset <= '0';
                
                -- Initialize buffer index depending on the PDU type
                if(pdu_type = '0') then
                    -- Compute total PDU_Request length
                    pdu_len_sig <= to_unsigned((SYNC_LEN_REQUEST) + (PROTOCOL_LEN) + (ADDR_LEN) + (to_integer(unsigned(data_len))) + (FCS_LEN) + (END_LEN), 16);
                    -- Add sync field, protocol selector, address field, data field, placeholder for FCS, and end field
                   buffer_sig(to_integer(index) - 1 downto (to_integer(index) - (SYNC_LEN_REQUEST*4) - (PROTOCOL_LEN*4) - (ADDR_LEN*4) - (to_integer(unsigned(data_len))*4) - (FCS_LEN*4) - (END_LEN*4) )) <= SYNC_REQUEST & protocol_selector & address & data_in((MAX_DATA_LEN*4)-1 downto (MAX_DATA_LEN*4)-(to_integer(unsigned(data_len))*4)) & "00000000" & END_FIELD; 
                else
                    -- Compute total PDU_Response length
                    pdu_len_sig <= to_unsigned((SYNC_LEN_RESPONSE) + (to_integer(unsigned(data_len))) + (FCS_LEN) + (END_LEN), 16);
                   -- Add sync field, address field, data field, placeholder for FCS, and end field
                    buffer_sig(to_integer(index) - 1 downto (to_integer(index) - (SYNC_LEN_RESPONSE*4) - (to_integer(unsigned(data_len))*4) - (FCS_LEN*4) - (END_LEN*4) )) <= SYNC_RESPONSE & data_in((MAX_DATA_LEN*4)-1 downto (MAX_DATA_LEN*4)-(to_integer(unsigned(data_len))*4)) & "00000000" & END_FIELD;
                end if;
                
                data_len_sig <= unsigned(data_len);
                
                -- Initialize FCS calculation
                fcs_start <= '1';
                nibble_index <= (others => '0'); -- Start processing the first byte
                
        
            elsif active = '1' then               
                -- Proceed to the next byte for FCS calculation
                if nibble_index < (pdu_len_sig - FCS_LEN - END_LEN) then
                    -- Feed the next byte into FCS
                    fcs_data_in <= buffer_sig(to_integer(index)-(to_integer(nibble_index)*4)-1 downto to_integer(index)-(to_integer(nibble_index)*4)-4);
                    nibble_index <= nibble_index + 1;
                elsif nibble_index = (pdu_len_sig - FCS_LEN - END_LEN) and fcs_start /= '0' then
                    -- Assign output
                    fcs_start <= '0';
                else
                    -- Finalize FCS insertion once all bytes are processed
                     if(pdu_type = '0') then
                        buffer_sig(to_integer(index) - (SYNC_LEN_REQUEST*4) - (PROTOCOL_LEN*4) - (ADDR_LEN*4) - (to_integer(data_len_sig)*4) - 1 downto to_integer(index) - (SYNC_LEN_REQUEST*4) - (PROTOCOL_LEN*4) - (ADDR_LEN*4) - (to_integer(data_len_sig)*4) - FCS_LEN*4) <= fcs_out;
                     else
                        buffer_sig(to_integer(index) - (SYNC_LEN_RESPONSE*4) - (to_integer(data_len_sig)*4) - 1 downto to_integer(index) - (SYNC_LEN_RESPONSE*4) - (to_integer(data_len_sig)*4) - FCS_LEN*4) <= fcs_out;
                     end if;
                    -- Assign output
                    active <= '0';
                    done_sig <= '1';
                end if;
            end if;
        end if;
        if pdu_len_sig < FCS_LEN + END_LEN then
            pdu_len <= (others => '0');
        else
            pdu_len <= std_logic_vector(to_unsigned(to_integer(pdu_len_sig) - FCS_LEN - END_LEN, 8));
        end if;
    end process;
    
    process(reset, done_sig)
    begin
        if reset = '1' then
            pdu_out_reversed <= (others => '0');
            reverse_process_done <= '0';
        elsif done_sig = '1' then
           for i in buffer_sig'range loop
               pdu_out_reversed(i) <= buffer_sig(i);
               --when i is 0, you assign buffer_sig's right-most bit to pdu_out_reversed's left-most bit
           end loop;
           reverse_process_done <= '1';
        end if;
    end process;
    
    done <= '1' when reverse_process_done = '1' and done_sig = '1' else
            '0';
    pdu_out <= buffer_sig;
end Behavioral;