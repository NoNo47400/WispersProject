library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_Modulation is
end TB_Modulation;

architecture Behavioral of TB_Modulation is

signal RST_sim : std_logic := '0';
signal CLK_sim : std_logic := '1';
signal INFO_sim : std_logic := '0';
signal START_sim : std_logic := '0';
signal PDU_LENGTH_sim : unsigned(7 downto 0) := x"05";

component Modulation
    port (
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    INFO_inp : in std_logic;
    START_inp : in std_logic :='0';
    PDU_LENGTH_inp : in unsigned(7 downto 0);
    
    MODULATED_outp : out std_logic_vector(7 downto 0);
    DONE_outp : out std_logic := '0'
    );
end component;

begin

TEST : Modulation
    port map (
    CLK_inp => CLK_sim,
    RST_inp => RST_sim,
    INFO_inp => INFO_sim,
    START_inp => START_sim,
    PDU_LENGTH_inp => PDU_LENGTH_sim,
    
    MODULATED_outp => open,
    DONE_outp => open
    );

CLOCK : process
    begin
        --wait for 1.11 ns; -- T=2.22ns <=> f=450MHz (freq du FPGA)
        wait for 7.63 us; --fréquence de 131kHz
        CLK_sim <= not CLK_sim;
    end process;
    
START : process
    begin
        wait for 5 us;
        START_sim <= not START_sim;
        wait;
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
        --wait for 32 us;
        wait for 1 us;
    end process;

end Behavioral;
