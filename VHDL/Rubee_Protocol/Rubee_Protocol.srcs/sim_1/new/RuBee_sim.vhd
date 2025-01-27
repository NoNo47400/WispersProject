----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 12/04/2024 15:50:15 AM
-- Design Name: Rubee_v0.1
-- Module Name: RuBee - Behavioral
-- Project Name: Wisper
-- Target Devices: Basys3
-- Tool Versions: 
-- Description : 
--   This module simulates the RuBee module to verify its functionality.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RuBee_sim is
end RuBee_sim;

architecture Behavioral of RuBee_sim is

    -- Component Declaration
    component RuBee is
        Port (
            clk     : in std_logic;    -- Clock signal
            reset   : in std_logic;    -- Reset signal
            start   : in std_logic;    -- Start signal
            pdu_out : out std_logic_vector(127 downto 0)
        );
    end component;

    -- Signals for simulation
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal start   : std_logic := '0';
    signal pdu_out : std_logic_vector(127 downto 0);
    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the RuBee module
    DUT: RuBee
        port map (
            clk     => clk,
            reset   => reset,
            start   => start,
            pdu_out => pdu_out
        );

    -- Clock generation process
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stimulus_process : process
    begin
        -- Apply reset
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;

        -- Apply start signal to begin PDU generation
        start <= '1';
        wait for 10 ns;
        start <= '0';

        -- Wait for the done signal to verify output
        wait for 300 ns;
    end process;

end Behavioral;
