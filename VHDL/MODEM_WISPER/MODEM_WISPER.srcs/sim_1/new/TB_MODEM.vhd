library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_MODEM is
end TB_MODEM;

architecture Behavioral of TB_MODEM is

signal RST_sim : std_logic := '0';
signal CLK_sim : std_logic := '1';
signal INFO_sim : std_logic := '0';
--signal START_sim: std_logic :='1';
signal START_sim: std_logic :='1';
signal PDU_LENGTH_sim: unsigned(7 downto 0) :=x"02";

component MODEM
    Port ( 
        CLK_inp : in std_logic;
        RST_inp : in std_logic;
        INFO_inp : in std_logic;
        START_inp : in std_logic :='0';
        PDU_LENGTH_inp : in unsigned(7 downto 0);
        
        INFO_outp : out std_logic
  );
end component;

begin

TEST : MODEM
    port map (
    CLK_inp => CLK_sim,
    RST_inp => RST_sim,
    INFO_inp => INFO_sim,
    START_inp => START_sim,
    PDU_LENGTH_inp => PDU_LENGTH_sim,
        
    INFO_outp => open
    );

CLOCK : process
    begin
        wait for 10 ns; --clock  générale à 50MHz pour test
        CLK_sim <= not CLK_sim;
    end process;

INFO : process
    begin
        INFO_sim <= not INFO_sim;
        wait for 1 ms; --data à 1000Hz
    end process;
    
--START : process
--    begin
--        wait for 200 us;
--        START_sim <= not START_sim;
--        wait for 1 ms;
--        START_sim <= not START_sim;
--        wait;
--    end process;

end Behavioral;
