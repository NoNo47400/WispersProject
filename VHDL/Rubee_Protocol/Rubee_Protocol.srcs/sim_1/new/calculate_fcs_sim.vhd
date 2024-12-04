----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 11/15/2024 09:57:25 AM
-- Design Name: Rubee_v0.1
-- Module Name: calculate_fcs - Behavioral
-- Project Name: Wisper
-- Target Devices: Basys3
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculate_fcs_sim is
end calculate_fcs_sim;

architecture Behavioral of calculate_fcs_sim is
    -- Component declaration for the `calculate_fcs` entity
    component calculate_fcs is
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            start       : in std_logic;
            data_in     : in std_logic_vector(7 downto 0);
            new_calcul  : in std_logic;
            fcs_out     : out std_logic_vector(7 downto 0);
            done        : out std_logic
        );
    end component;

-- Test signals
signal clk          : std_logic := '0';
signal reset        : std_logic := '0';
signal start        : std_logic := '0';
signal new_calcul   : std_logic := '0';
signal data_in      : std_logic_vector(7 downto 0);
signal fcs_out      : std_logic_vector(7 downto 0);
signal done         : std_logic;

-- Clock generation: 10 ns period (100 MHz)
constant clk_period : time := 10 ns;

begin
    -- Instantiate the `calculate_fcs` component
    uut: calculate_fcs
        port map (
            clk => clk,
            reset => reset,
            start => start,
            data_in => data_in,
            new_calcul => new_calcul,
            fcs_out => fcs_out,
            done => done
        );

    -- Clock generation process
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
        -- Reset the circuit
        reset <= '1';
        wait for clk_period;
        reset <= '0';
        wait for clk_period;

        -- Test case 1: Short data input of "0xAA" repeated 3 times (3 bytes)
        data_in <= "11110001"; -- 0xF1
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Wait until done is asserted
        wait until done = '1';
        --report "Test case 1: FCS output = " & std_logic_vector'(fcs_out);

        wait for clk_period*4;
        
        -- Reset the circuit
        new_calcul <= '1';
        wait for clk_period;
        new_calcul <= '0';
        wait for clk_period;
        -- Test case 2: Single-byte input "0xFF"
        data_in <= "11111111"; -- 0xFF
        start <= '1';
        wait for clk_period*2;
        start <= '0';

        -- Wait until done is asserted
        wait until done = '1';
        --report "Test case 2: FCS output = " & std_logic_vector'(fcs_out);

        -- Additional test cases can be added here

        -- End the simulation
        wait;
    end process;
end Behavioral;
