----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 11/27/2024 12:47:19 PM
-- Design Name: Rubee_v0.1
-- Module Name: create_pdu - Behavioral
-- Project Name: Wisper
-- Target Devices: Basys3
-- Description:
--    This module simulates the create_pdu module to verify its functionality.
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity create_pdu_sim is
end create_pdu_sim;

architecture sim of create_pdu_sim is
    -- Component declaration for create_pdu
    component create_pdu
        generic (
            SYNC_LEN_REQUEST      : integer := 3;       -- Length (number of nibble) of sync field of request pdu
            SYNC_LEN_RESPONSE     : integer := 2;       -- Length (number of nibble) of sync field of response pdu
            PROTOCOL_LEN  : integer := 1;       -- Length (number of nibble) of protocol selector field
            ADDR_LEN      : integer := 8;       -- Length (number of nibble) of address field
            MAX_DATA_LEN  : integer := 128;     -- Maximum length of data field
            FCS_LEN       : integer := 2;       -- Length (number of nibble) of FCS field
            END_LEN       : integer := 2;       -- Length (number of nibble) of end field
            PDU_MAX_LEN   : integer := 256      -- Maximum (number of nibble) PDU length
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
            pdu_out_reversed : out std_logic_vector(0 to PDU_MAX_LEN*4-1); -- Output PDU reversed
            pdu_len         : out std_logic_vector(7 downto 0); -- Length of the created PDU
            done            : out std_logic                      -- Done signal
        );
    end component;

    -- Signals
    signal clk              : std_logic := '0';
    signal reset            : std_logic := '0';
    signal start            : std_logic := '0';
    signal pdu_type         : std_logic := '0';
    signal protocol_selector: std_logic_vector(3 downto 0) := (others => '0');
    signal address          : std_logic_vector(31 downto 0) := (others => '0');
    signal data_in          : std_logic_vector(511 downto 0) := (others => '0');
    signal data_len         : std_logic_vector(7 downto 0):= (others => '0');
    signal pdu_out          : std_logic_vector(1023 downto 0); -- Match PDU_MAX_LEN * 8
    signal pdu_out_reversed : std_logic_vector(0 to 1023); -- Match PDU_MAX_LEN * 8
    signal pdu_len          : std_logic_vector(7 downto 0);
    signal done             : std_logic;

    -- Clock period
    constant clk_period : time := 10 ns;

    -- Test data
    constant test_address : std_logic_vector(31 downto 0) := "10101010101010101010101010101010"; -- Example address
    constant test_data    : std_logic_vector(511 downto 0) := "00010010001101000101011001111000" & (511-32 downto 0 => '0'); -- Extend to 1024 bits

begin
    -- Instantiate the create_pdu component
    uut: create_pdu
        generic map (
            SYNC_LEN_REQUEST => 3,
            SYNC_LEN_RESPONSE => 2,
            ADDR_LEN => 8,
            MAX_DATA_LEN => 128,
            FCS_LEN => 2,
            END_LEN => 2,
            PDU_MAX_LEN => 256
        )
        port map (
            clk => clk,
            reset => reset,
            start => start,
            pdu_type => pdu_type,
            protocol_selector => protocol_selector,
            address => address,
            data_in => data_in,
            data_len => data_len,
            pdu_out => pdu_out,
            pdu_out_reversed => pdu_out_reversed,
            pdu_len => pdu_len,
            done => done
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus : process
    begin
        -- Reset the design
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        -- Test case 1: Create PDU with 8 bytes of data
        protocol_selector <= "0001"; -- Example protocol selector
        address <= test_address;
        data_in <= test_data;
        data_len <= "00001000"; -- 8 bytes of data
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Wait for PDU creation to complete
        wait until done = '1';
        wait for 10*clk_period;
        -- Verify output
        --assert pdu_len = 17  -- 3 sync + 1 protocol + 4 address + 8 data + 1 FCS + 1 end
        --report "Test 1 passed: Correct PDU length."
        --severity note;

        -- Check the output PDU
        --report "PDU Output: " & std_logic_vector'(pdu_out);

        -- Reset and test with a different data length
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        -- Test case 2: Create PDU with 4 bytes of data
        data_len <= "00000100"; -- 4 bytes of data
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Wait for PDU creation to complete
        wait until done = '1';

        -- Verify output
        --assert pdu_len = 13  -- 3 sync + 1 protocol + 4 address + 4 data + 1 FCS + 1 end
        --report "Test 2 passed: Correct PDU length."
        --severity note;

        -- End the simulation
        wait for 10 * clk_period;
        report "Simulation complete.";
        wait;
    end process;

end sim;
