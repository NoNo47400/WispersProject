library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_MODEM is
end TB_MODEM;

architecture Behavioral of TB_MODEM is

signal RST_sim : std_logic := '0';
signal CLK_sim : std_logic := '1';
signal INFO_sim : std_logic := '0';

component MODEM
    Port ( 
        CLK_inp : in std_logic;
        RST_inp : in std_logic;
        INFO_inp : in std_logic;
        
        INFO_outp : out std_logic
  );
end component;

begin

TEST : MODEM
    port map (
    CLK_inp => CLK_sim,
    RST_inp => RST_sim,
    INFO_inp => INFO_sim,
    INFO_outp => open
    );

CLOCK : process
    begin
        wait for 1.11 ns; -- T=2.22ns <=> f=450MHz (freq du FPGA)
        CLK_sim <= not CLK_sim;
    end process;

INFO : process
    begin
        INFO_sim <= not INFO_sim;
        wait for 32 us;
    end process;

end Behavioral;
