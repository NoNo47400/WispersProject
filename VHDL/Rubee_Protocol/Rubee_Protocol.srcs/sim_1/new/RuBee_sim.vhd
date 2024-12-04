----------------------------------------------------------------------------------
-- RuBee_sim.vhd
-- Simulation file to test the RuBee module.
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
            start   : in std_logic    -- Start signal
        );
    end component;

    -- Signals for simulation
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal start   : std_logic := '0';

    -- Clock period definition
    constant CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate the RuBee module
    DUT: RuBee
        port map (
            clk     => clk,
            reset   => reset,
            start   => start
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
