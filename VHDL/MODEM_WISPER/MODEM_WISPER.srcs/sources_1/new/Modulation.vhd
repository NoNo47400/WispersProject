library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Modulation is
  Port ( 
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    INFO_inp : in std_logic;
    
    MODULATED_outp : out std_logic_vector(7 downto 0)
  );
end Modulation;


architecture Behavioral of Modulation is

component Carrier_generator is
    port(
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    CARRIER_outp_1 : out std_logic_vector(7 downto 0);
    CARRIER_outp_2 : out std_logic_vector(7 downto 0)
    );
end component;

signal Info_sig : std_logic;
signal Carrier_sig_1 : std_logic_vector(7 downto 0);
signal Carrier_sig_2 : std_logic_vector(7 downto 0);
signal Modulated_sig : std_logic_vector(7 downto 0) := x"80";


begin

CARRIER_GEN : Carrier_generator
    port map(
    CLK_inp => CLK_inp,
    RST_inp => RST_inp,
    CARRIER_outp_1 => Carrier_sig_1,
    CARRIER_outp_2 => Carrier_sig_2
    );

MODULATE : process(CLK_inp, RST_inp)
    begin
        if(RST_inp = '1')then
            Modulated_sig <= x"7F";
        elsif(CLK_inp'event and CLK_inp = '1')then
            if(Info_sig = '1') then    
                Modulated_sig <= Carrier_sig_1;
            elsif(Info_sig = '0') then
                Modulated_sig <= Carrier_sig_2;
            end if;
        end if;
    end process;

Info_sig <= INFO_inp;

-- OUTPUTS MAPPING
MODULATED_outp <= Modulated_sig; 

end Behavioral;
