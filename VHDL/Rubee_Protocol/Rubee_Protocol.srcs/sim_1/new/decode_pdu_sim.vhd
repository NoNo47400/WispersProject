----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 27/01/2025
-- Design Name: Rubee_v0.1 Testbench
-- Module Name: decode_pdu_tb - Testbench
-- Project Name: Wispers
-- Target Devices: Basys3
-- Description:
-- Testbench for the decode_pdu module.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decode_request_pdu_tb is
end decode_request_pdu_tb;

architecture Behavioral of decode_request_pdu_tb is
    -- Component declaration for the Unit Under Test (UUT)
    component decode_request_pdu
        Port (
            clk             : in  STD_LOGIC;
            rst             : in  STD_LOGIC;
            bit_in          : in  STD_LOGIC;
            header_validity : in  STD_LOGIC;
            
            pdu_out         : out STD_LOGIC_VECTOR(127 downto 0);
            pdu_validity    : out STD_LOGIC
        );
    end component;

    -- Testbench signals
    signal clk             : STD_LOGIC := '0';
    signal rst             : STD_LOGIC := '0';
    signal bit_in          : STD_LOGIC := '0';
    signal header_validity : STD_LOGIC := '0';

    signal pdu_out         : STD_LOGIC_VECTOR(127 downto 0);
    signal pdu_validity    : STD_LOGIC;

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: decode_request_pdu
        Port map (
            clk => clk,
            rst => rst,
            bit_in => bit_in,
            header_validity => header_validity,
            pdu_out => pdu_out,
            pdu_validity => pdu_validity
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus process
    stimulus_process: process
        -- Data to be sent: 0x0, 0x0, 0x5, 0x1, 0xa, 0xa, 0xa, 0xa, 0xa, 0xa, 0xa, 0xa, 0x5, 0x5, 0x5, 0x5, 0x5, 0x5, 0x5, 0x5, 0xa, 0x2
        type pdu_array is array (0 to 21) of std_logic_vector(3 downto 0);
        constant pdu_data : pdu_array := (
            "0000", "0000", "0101", "0001", "1010", "1010", "1010", "1010",
            "1010", "1010", "1010", "1010", "0101", "0101", "0101", "0101",
            "0101", "0101", "0101", "0101", "1010", "0010"
        );
        constant pdu_data2 : pdu_array := (
            "0000", "0000", "0101", "0001", "1010", "1010", "1010", "1010",
            "1010", "1010", "1010", "1010", "0101", "0101", "0101", "0101",
            "0101", "0101", "0101", "0101", "1010", "0010"
        );
        
    begin
        -- Reset the system
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait for 2 * CLK_PERIOD;

        -- Simulate a valid header detection
        header_validity <= '1';
        wait for CLK_PERIOD;
        header_validity <= '0';

        -- Send PDU bits
        for i in pdu_data'range loop
            for j in 3 downto 0 loop
                bit_in <= pdu_data(i)(j);
                wait for CLK_PERIOD;
            end loop;
        end loop;

        -- Wait to observe results
        wait until pdu_validity = '1';
        
        wait for CLK_PERIOD*5;
        
        -- Reset the system
        rst <= '1';
        wait for 2 * CLK_PERIOD;
        rst <= '0';
        wait for 2 * CLK_PERIOD;

        -- Simulate a valid header detection
        header_validity <= '1';
        wait for CLK_PERIOD;
        header_validity <= '0';

        -- Send PDU bits
        for i in pdu_data2'range loop
            for j in 3 downto 0 loop
                bit_in <= pdu_data2(i)(j);
                wait for CLK_PERIOD;
            end loop;
        end loop;
        
        wait for CLK_PERIOD * 20;
        -- Finish simulation
        wait;
    end process;

end Behavioral;
