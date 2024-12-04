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
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RuBee is
    Port (
        clk     : in std_logic;    -- Clock signal
        reset   : in std_logic;    -- Reset signal
        start   : in std_logic     -- Start signal
    );
end RuBee;

architecture Behavioral of RuBee is

    -- Component Declaration
    component create_request_pdu is
        generic (
            SYNC_LEN      : integer := 3;
            ADDR_LEN      : integer := 8;
            MAX_DATA_LEN  : integer := 128;
            FCS_LEN       : integer := 2;
            END_LEN       : integer := 2;
            PDU_MAX_LEN   : integer := 256
        );
        port (
            clk             : in std_logic;
            reset           : in std_logic;
            start           : in std_logic;
            protocol_selector : in std_logic_vector(7 downto 0);
            address         : in std_logic_vector(ADDR_LEN*4-1 downto 0);
            data_in         : in std_logic_vector(MAX_DATA_LEN*4-1 downto 0);
            data_len        : in integer range 0 to MAX_DATA_LEN;
            pdu_out         : out std_logic_vector(PDU_MAX_LEN*4-1 downto 0);
            pdu_len         : out integer range 0 to PDU_MAX_LEN;
            done            : out std_logic
        );
    end component;

    -- Signals
    signal start_signal      : std_logic := '0'; --Internal start signal
    signal protocol_selector : std_logic_vector(7 downto 0) := "00000000"; -- Default protocol selector
    signal address_signal    : std_logic_vector(8*4-1 downto 0) := (others => '0'); -- Default address
    signal data_in_signal    : std_logic_vector(511 downto 0) := (others => '0'); -- Data input
    signal data_len_signal   : integer := 8; -- Length of the data (in nibbles)
    signal pdu_len_signal    : integer := 0; --PDU length
    signal pdu_internal      : std_logic_vector(1023 downto 0); -- Internal PDU signal
    signal done_signal       : std_logic; -- Internal done signal

begin

    -- Instantiate create_request_pdu
    PDU_GENERATOR: create_request_pdu
        generic map (
            SYNC_LEN      => 3,
            ADDR_LEN      => 8,
            MAX_DATA_LEN  => 128,
            FCS_LEN       => 2,
            END_LEN       => 2,
            PDU_MAX_LEN   => 256
        )
        port map (
            clk             => clk,
            reset           => reset,
            start           => start_signal,
            protocol_selector => protocol_selector,
            address         => address_signal,
            data_in         => data_in_signal,
            data_len        => data_len_signal,
            pdu_out         => pdu_internal,
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
                data_len_signal     <= 0;
            elsif start = '1' then
                start_signal <= '1';
                protocol_selector <= "00010001";
                address_signal <= "10101010101010101010101010101010";
                data_in_signal(511 downto 480) <= "00010010001101000101011001111000";
                data_len_signal <= 8;
            else
                start_signal <= '0';
            end if;
        end if;
     end process;

end Behavioral;