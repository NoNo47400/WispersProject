-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 01/15/2025 03:30:10 PM
-- Design Name: Rubee_v0.1
-- Module Name: header_detection_tb - Testbench
-- Project Name: Wispers
-- Target Devices: Basys3
-- Tool Versions: 
-- Description: Simulation file for header_detection entity
--
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity header_detection_tb is
-- Testbench does not have ports
end header_detection_tb;

architecture Behavioral of header_detection_tb is

    -- Component declaration for the Unit Under Test (UUT)
    component header_detection
        Port (
            CLK_in : in std_logic;
            RST_in : in std_logic;
            DEMODULATED_in : in std_logic;
            pdu_type : in std_logic;
            FLAG_out : out std_logic
        );
    end component;

    -- Testbench signals
    signal CLK_in_tb : std_logic := '0';
    signal RST_in_tb : std_logic := '0';
    signal DEMODULATED_in_tb : std_logic := '0';
    signal pdu_type_tb : std_logic := '0';
    signal FLAG_out_tb : std_logic;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: header_detection
        Port map (
            CLK_in => CLK_in_tb,
            RST_in => RST_in_tb,
            DEMODULATED_in => DEMODULATED_in_tb,
            pdu_type => pdu_type_tb,
            FLAG_out => FLAG_out_tb
        );

    -- Clock process
    clk_process : process
    begin
        while true loop
            CLK_in_tb <= '0';
            wait for CLK_PERIOD / 2;
            CLK_in_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        RST_in_tb <= '1';
        wait for 20 ns;
        RST_in_tb <= '0';

        -- Test PDU Type = 0 (Target_Value_request)
        pdu_type_tb <= '0';
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '1'; -- Start inputting the target value for request
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '1';

        -- Wait to observe FLAG_out_tb
        wait for 100 ns;

        -- Test PDU Type = 1 (Target_Value_receive)
        RST_in_tb <= '1';
        wait for 20 ns;
        RST_in_tb <= '0';
        pdu_type_tb <= '1';
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '1'; -- Start inputting the target value for receive
        wait for 10 ns;
        DEMODULATED_in_tb <= '0';
        wait for 10 ns;
        DEMODULATED_in_tb <= '1';

        -- Wait to observe FLAG_out_tb
        wait for 100 ns;

        -- End simulation
        wait;
    end process;

end Behavioral;
