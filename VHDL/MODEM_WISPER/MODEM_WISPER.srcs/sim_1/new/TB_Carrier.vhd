library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_Carrier is
end TB_Carrier;

architecture Behavioral of TB_Carrier is

signal RST_sim : std_logic := '0';
signal CLK_sim : std_logic := '0';

component Carrier_generator
    port (
    CLK_inp : in std_logic;
    RST_inp : in std_logic
    );
end component;

begin

TEST : Carrier_generator
    port map (
    CLK_inp => CLK_sim,
    RST_inp => RST_sim
    );

CLOCK : process
    begin
        wait for 2 ns; -- T=2ns <=> f=450MHz (freq du FPGA)
        CLK_sim <= not CLK_sim;
    end process;

RESET : process
    begin
        RST_sim <= '1';
        wait for 200 ns;
        RST_sim <= '0';
        wait;
    end process;

end Behavioral;
