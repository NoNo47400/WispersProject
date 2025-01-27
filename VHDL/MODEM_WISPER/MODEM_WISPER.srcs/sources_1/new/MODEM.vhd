library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MODEM is
  Port ( 
        CLK_inp : in std_logic;
        RST_inp : in std_logic;
        INFO_inp : in std_logic;
        START_inp : in std_logic;
        PDU_LENGTH_inp : in unsigned(7 downto 0);
        
        INFO_outp : out std_logic
  );
end MODEM;

architecture Behavioral of MODEM is

component Modulation is
    port(
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    INFO_inp : in std_logic;
    START_inp : in std_logic;
    PDU_LENGTH_inp : in unsigned(7 downto 0);
    
    MODULATED_outp : out std_logic_vector(7 downto 0);
    DONE_outp : out std_logic
    );
end component;

component Demodulation is
    port(
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    MODULATED_inp : in std_logic_vector(7 downto 0);
    
    DEMODULATED_outp : out std_logic
    );
end component;

signal Modulated_sig : std_logic_vector (7 downto 0);
signal Demodulated_sig : std_logic;


begin

MODU : Modulation
    port map(
    CLK_inp => CLK_inp,
    RST_inp => RST_inp,
    INFO_inp => INFO_inp,
    START_inp => START_inp,
    PDU_LENGTH_inp => PDU_LENGTH_inp,
    
    MODULATED_outp => Modulated_sig,
    DONE_outp => open
    );
    
DEMODU : Demodulation
    port map(
    CLK_inp => CLK_inp,
    RST_inp => RST_inp,
    MODULATED_inp => Modulated_sig,
    
    DEMODULATED_outp => Demodulated_sig
    );

-- OUTPUTS MAPPING
INFO_outp <= Demodulated_sig; 

end Behavioral;
