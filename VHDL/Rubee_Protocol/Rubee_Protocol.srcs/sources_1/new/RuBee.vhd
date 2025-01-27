----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 12/04/2024 10:35:58 AM
-- Design Name: Rubee_v0.1
-- Module Name: RuBee - Behavioral
-- Project Name: Wisper
-- Target Devices: Basys3
-- Tool Versions: 
-- Description :
--      This module interfaces and uses the create_request_pdu module to create
--      Protocol Data Units (PDU) for the Rubee Protocol.
--
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RuBee is
    Port (
        clk     : in std_logic;    -- Clock signal
        reset   : in std_logic;    -- Reset signal
        start   : in std_logic;     -- Start signal
        pdu_out : out std_logic_vector(127 downto 0)
    );
end RuBee;

architecture Behavioral of RuBee is


    -- Signals
    signal start_signal      : std_logic := '0'; --Internal start signal
    signal pdu_type          : std_logic := '0'; -- Internal PDU type signal
    signal protocol_selector : std_logic_vector(3 downto 0) := "0000"; -- Default protocol selector
    signal address_signal    : std_logic_vector(8*4-1 downto 0) := (others => '0'); -- Default address
    signal data_in_signal    : std_logic_vector(31 downto 0) := (others => '0'); -- Data input
    signal data_len_signal         : std_logic_vector(7 downto 0):= (others => '0'); -- Length of the data (in nibbles)
    signal pdu_len_signal          : std_logic_vector(7 downto 0); --PDU length
    signal pdu_internal      : std_logic_vector(127 downto 0); -- Internal PDU signal
    signal pdu_internal_reversed   : std_logic_vector(127 downto 0); -- Internal PDU signal reversed
    signal done_signal       : std_logic; -- Internal done signal

begin

    -- Instantiate create_request_pdu
    CREATE_PDU: entity work.create_pdu
        generic map (
            SYNC_LEN_REQUEST      => 3,
            SYNC_LEN_RESPONSE      => 2,
            ADDR_LEN      => 8,
            MAX_DATA_LEN  => 8,
            FCS_LEN       => 2,
            END_LEN       => 2,
            PDU_MAX_LEN   => 32
        )
        port map (
            clk             => clk,
            reset           => reset,
            start           => start_signal,
            pdu_type        => pdu_type,
            protocol_selector => protocol_selector,
            address         => address_signal,
            data_in         => data_in_signal,
            data_len        => data_len_signal,
            pdu_out         => pdu_internal,
            pdu_out_reversed => pdu_internal_reversed,
            pdu_len         => pdu_len_signal, -- Length is not used externally in this case
            done            => done_signal
        );
     process(clk)
     begin
        if rising_edge(clk) then
            if reset = '1' then
                start_signal        <= '0';
                protocol_selector   <= (others =>'0');
                address_signal      <= (others =>'0');
                data_in_signal      <= (others =>'0');
                data_len_signal     <= (others =>'0');
            elsif start = '1' then
                start_signal <= '1';
                protocol_selector <= "0001";
                address_signal <= "10101010101010101010101010101010";
                data_in_signal(31 downto 0) <= "00010010001101000101011001111000";
                data_len_signal <= "00001000";
            else
                start_signal <= '0';
            end if;
        end if;
     end process;
     pdu_out <= pdu_internal;
end Behavioral;