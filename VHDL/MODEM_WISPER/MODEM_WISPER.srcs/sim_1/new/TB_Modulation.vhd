library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity TB_Modulation is
end TB_Modulation;

architecture Behavioral of TB_Modulation is

signal RST_sim : std_logic := '0';
signal CLK_sim : std_logic := '1';
signal INFO_sim : std_logic := '0';

component Modulation
    port (
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    INFO_inp : in std_logic;
    MODULATED_outp : out std_logic_vector(7 downto 0)
    );
end component;

begin

TEST : Modulation
    port map (
    CLK_inp => CLK_sim,
    RST_inp => RST_sim,
    INFO_inp => INFO_sim,
    MODULATED_outp => open
    );

CLOCK : process
    begin
        wait for 1.11 ns; -- T=2.22ns <=> f=450MHz (freq du FPGA)
        CLK_sim <= not CLK_sim;
    end process;

--RESET : process
--    begin
--        RST_sim <= '1';
--        wait for 8 ns;
--        RST_sim <= '0';
--        wait;
--    end process;

INFO : process
    begin
        INFO_sim <= not INFO_sim;
        wait for 32 us;
    end process;

end Behavioral;
