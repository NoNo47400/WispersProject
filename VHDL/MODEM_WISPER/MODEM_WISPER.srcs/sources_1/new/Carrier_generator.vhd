library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Carrier_generator is

  Port ( 
  CLK_inp : in std_logic;
  RST_inp : in std_logic;
  CARRIER_outp_1 : out std_logic_vector(7 downto 0); --BIG CARRIER
  CARRIER_outp_2 : out std_logic_vector(7 downto 0) --SMALL CARRIER
  );
  
  
end Carrier_generator;

architecture Behavioral of Carrier_generator is

type sin_table is array (0 to 90) of std_logic_vector(7 downto 0);
constant carrier_table : sin_table := (        
    x"80", x"81", x"83", x"86", x"88", x"8A", x"8C", x"8F", 
    x"91", x"93", x"95", x"97", x"99", x"9C", x"9E", x"A0", 
    x"A2", x"A4", x"A6", x"A8", x"AB", x"AD", x"AF", x"B1", 
    x"B3", x"B5", x"B7", x"B9", x"BB", x"BD", x"BF", x"C1", 
    x"C3", x"C4", x"C6", x"C8", x"CA", x"CC", x"CD", x"CF", 
    x"D1", x"D3", x"D4", x"D6", x"D8", x"D9", x"DB", x"DC", 
    x"DE", x"DF", x"E1", x"E2", x"E3", x"E5", x"E6", x"E7", 
    x"E9", x"EA", x"EB", x"EC", x"ED", x"EE", x"F0", x"F1", 
    x"F2", x"F3", x"F3", x"F4", x"F5", x"F6", x"F7", x"F8", 
    x"F8", x"F9", x"FA", x"FA", x"FB", x"FB", x"FC", x"FC", 
    x"FD", x"FD", x"FD", x"FE", x"FE", x"FE", x"FE", x"FF", 
    x"FF", x"FF", x"FF" 
); 

type states is (first_quarter, second_quarter, third_quarter, forth_quarter);
signal current_state : states := first_quarter;

signal Carrier_sig_1 : std_logic_vector (7 downto 0):=x"80"; --BIG CARRIER
signal Carrier_sig_2 : std_logic_vector (7 downto 0):=x"80"; --SMALL CARRIER
signal Index : unsigned(7 downto 0) := x"00";
signal Calcul : unsigned(7 downto 0) := x"00";

begin

-- CARRIER 1 GENERATING (BIG)
Read_table_1 : process (CLK_inp, RST_inp)
    begin
        if(RST_inp = '1') then
            Index <= x"00";
            current_state <= first_quarter;
            
        elsif(CLK_inp'event and CLK_inp = '1') then
        
            case current_state is
            
                when first_quarter =>
                    Index <= Index + 1 ;
                    Carrier_sig_1 <= carrier_table(TO_INTEGER(Index));
                    if(Index = x"59") then --on détectele seuil un coup d'horloge avant la valeur max pour éviter que index dépasse les limites du tableau
                        current_state <= second_quarter;
                    end if;
                
                when second_quarter =>
                    Index <= Index - 1 ;
                    Carrier_sig_1 <= carrier_table(TO_INTEGER(Index));
                    if(Index = x"01") then 
                        current_state <= third_quarter;
                    end if;
                
                when third_quarter =>
                    Index <= Index + 1 ;
                    Carrier_sig_1 <= not carrier_table(TO_INTEGER(Index));
                    if(Index = x"59") then 
                        current_state <= forth_quarter;
                    end if;
                
                when forth_quarter =>
                    Index <= Index - 1 ;
                    Carrier_sig_1 <= not carrier_table(TO_INTEGER(Index));
                    if(Index = x"01") then 
                        current_state <= first_quarter;
                    end if;
                
            end case;
        end if;
    end process;



-- CARRIER 2 GENERATING (SMALL)
Calcul <= unsigned(Carrier_sig_1) / 16 + 120;
Carrier_sig_2 <= std_logic_vector(Calcul);

-- OUTPUTS MAPPING
CARRIER_outp_1 <= Carrier_sig_1; --BIG CARRIER
CARRIER_outp_2 <= Carrier_sig_2; --SMALL CARRIER 

end Behavioral;
