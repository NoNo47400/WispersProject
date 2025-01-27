library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Modulation is
  Port ( 
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    INFO_inp : in std_logic;
    START_inp : in std_logic :='0';
    PDU_LENGTH_inp : in unsigned(7 downto 0);
    
    MODULATED_outp : out std_logic_vector(7 downto 0);
    DONE_outp : out std_logic := '0'
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
signal Counter_sig : unsigned(31 downto 0) :=(others => '0');
signal Done_sig : std_logic := '0';
signal Started_sig : std_logic := '0';
signal RST_carrier_sig : std_logic := '0';


begin

CARRIER_GEN : Carrier_generator
    port map(
    CLK_inp => CLK_inp,
    RST_inp => RST_carrier_sig,
    CARRIER_outp_1 => Carrier_sig_1,
    CARRIER_outp_2 => Carrier_sig_2
    );

MODULATE : process(CLK_inp, RST_inp)
    begin
        if(RST_inp = '1')then
            Modulated_sig <= x"7F"; --7F est la valeur codée pour le 0 du signal
            DONE_sig <= '0';
            Started_sig <= '0';
        elsif(CLK_inp'event and CLK_inp = '1')then
            if(START_inp = '1' or Started_sig = '1') then
                if(Info_sig = '1') then    
                    Modulated_sig <= Carrier_sig_1;
                elsif(Info_sig = '0') then
                    Modulated_sig <= Carrier_sig_2;
                end if;
                Counter_sig <= Counter_sig + 1;
                if(Counter_sig = PDU_LENGTH_inp * x"C350") then --*50 000
                    Counter_sig <= (others => '0'); --RAZ counter
                    Done_sig <= '1';
                    Started_sig <= '0';
                else 
                    Done_sig <= '0';
                    Started_sig <= '1'; --Maintient à 1 pour boucler le temps que le PDU soit traité
                end if;
            end if;
        end if;
    end process;

Info_sig <= INFO_inp;
RST_carrier_sig <= RST_inp or not(Started_sig);

-- OUTPUTS MAPPING
MODULATED_outp <= Modulated_sig; 
DONE_outp <= Done_sig;

end Behavioral;
