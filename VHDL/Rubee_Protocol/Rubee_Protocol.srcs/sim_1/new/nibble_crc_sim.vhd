----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 11/20/2024 02:30:00 PM
-- Design Name: Rubee_v0.1
-- Module Name: nibble_crc_sim - Behavioral
-- Project Name: Wisper
-- Target Devices: Basys3
-- Description: 
--   This module simulates the nibble_crc module to verify its functionality.
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity nibble_crc_sim is
end nibble_crc_sim;

architecture sim of nibble_crc_sim is
    -- Component declaration for the nibble_crc
    component nibble_crc
        port (
            clk        : in std_logic;
            reset      : in std_logic;
            start      : in std_logic;
            nibble_in  : in std_logic_vector(3 downto 0);
            crc_out    : out std_logic_vector(7 downto 0);
            done       : out std_logic
        );
    end component;

    -- Signals
    signal clk        : std_logic := '0';
    signal reset      : std_logic := '0';
    signal start      : std_logic := '0';
    signal nibble_in  : std_logic_vector(3 downto 0) := (others => '0');
    signal crc_out    : std_logic_vector(7 downto 0);
    signal done       : std_logic;

    -- Input data as a 2D array
    type nibble_array is array(0 to 15) of std_logic_vector(3 downto 0);
    constant input_data : nibble_array := (
        "0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000", "0001", "0010", "0011", "0100", "0101", "0110", "0111", "1000"  -- Nibbles 0x1 to 0x8
    );

    -- Clock period
    constant clk_period : time := 10 ns;

    -- Simulation variables
    signal data_index : integer := 0;
begin
    -- Instantiate the nibble_crc component
    uut: nibble_crc
        port map (
            clk => clk,
            reset => reset,
            start => start,
            nibble_in => nibble_in,
            crc_out => crc_out,
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

        -- Test with 8 nibbles
        -- Apply the input data sequentially
        start <= '1';
        wait for clk_period;
        for data_index in 0 to 7 loop
            nibble_in <= input_data(data_index);  -- Feed each nibble
            wait for clk_period;
        end loop;

        -- Wait for the CRC calculation to complete
        start <= '0';
        wait until done = '1';
        
        -- Check the CRC output
        assert crc_out = "00011100"  -- Expected CRC = 0x1C
        report "Test passed: CRC is correct."
        severity note;
        
        -- Reset the design
        wait for clk_period/2;
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;
        
        -- Test with 8 nibbles
        -- Apply the input data sequentially
        start <= '1';
        wait for clk_period;
        for data_index in 0 to 3 loop
            nibble_in <= input_data(data_index);  -- Feed each nibble
            wait for clk_period;
        end loop;

        -- Wait for the CRC calculation to complete
        start <= '0';
        wait until done = '1';
        
        
        -- Reset the design
        wait for clk_period/2;
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;
        
        -- Test with 8 nibbles
        -- Apply the input data sequentially
        start <= '1';
        wait for clk_period;
        for data_index in 0 to 15 loop
            nibble_in <= input_data(data_index);  -- Feed each nibble
            wait for clk_period;
        end loop;

        -- Wait for the CRC calculation to complete
        start <= '0';
        wait until done = '1';
        
        
        -- Wait for a while and stop the simulation
        wait for 10 * clk_period;
        report "Simulation complete.";
        wait;
    end process;

end sim;
