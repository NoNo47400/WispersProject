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

type sin_table is array (0 to 180) of std_logic_vector(7 downto 0);
constant carrier_table : sin_table := (        
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00",  
    x"01", x"01", x"01", x"02", x"02", x"03", x"03", x"04",  
    x"04", x"05", x"06", x"06", x"07", x"08", x"09", x"0A",  
    x"0A", x"0B", x"0C", x"0D", x"0E", x"0F", x"10", x"12",  
    x"13", x"14", x"15", x"16", x"18", x"19", x"1A", x"1C",  
    x"1D", x"1F", x"20", x"22", x"23", x"25", x"26", x"28",  
    x"29", x"2B", x"2D", x"2E", x"30", x"32", x"34", x"36",  
    x"37", x"39", x"3B", x"3D", x"3F", x"41", x"43", x"45",  
    x"47", x"49", x"4B", x"4D", x"4F", x"51", x"53", x"55",  
    x"57", x"59", x"5B", x"5E", x"60", x"62", x"64", x"66",  
    x"68", x"6B", x"6D", x"6F", x"71", x"73", x"76", x"78",  
    x"7A", x"7C", x"80", x"81", x"83", x"86", x"88", x"8A", 
    x"8C", x"8F", x"91", x"93", x"95", x"97", x"99", x"9C", 
    x"9E", x"A0", x"A2", x"A4", x"A6", x"A8", x"AB", x"AD", 
    x"AF", x"B1", x"B3", x"B5", x"B7", x"B9", x"BB", x"BD", 
    x"BF", x"C1", x"C3", x"C4", x"C6", x"C8", x"CA", x"CC", 
    x"CD", x"CF", x"D1", x"D3", x"D4", x"D6", x"D8", x"D9", 
    x"DB", x"DC", x"DE", x"DF", x"E1", x"E2", x"E3", x"E5", 
    x"E6", x"E7", x"E9", x"EA", x"EB", x"EC", x"ED", x"EE", 
    x"F0", x"F1", x"F2", x"F3", x"F3", x"F4", x"F5", x"F6", 
    x"F7", x"F8", x"F8", x"F9", x"FA", x"FA", x"FB", x"FB", 
    x"FC", x"FC", x"FD", x"FD", x"FD", x"FE", x"FE", x"FE", 
    x"FE", x"FE", x"FE", x"FE", x"FE"
);

type states is (first_quarter, second_quarter, third_quarter, forth_quarter);
signal current_state : states := first_quarter;

signal Carrier_sig_1 : std_logic_vector (7 downto 0); --BIG CARRIER
signal Carrier_sig_2 : std_logic_vector (7 downto 0); --SMALL CARRIER
signal Index : unsigned(7 downto 0) := x"5A";

constant Freq_ratio : integer := 5; -- Rapport entre la fréquence du FPGA (450 MHz) et la fréquence d'échantillonnage (47 MHz cf Excel) le tout /2 pour avoir une demi période où on switch la clock
signal Counter : unsigned(3 downto 0) := "0000";
signal Clock_divided : std_logic := '1';

signal integ : integer; 

begin

-- CARRIER 1 GENERATING (BIG)
Read_table_1 : process (Clock_divided, RST_inp)
    begin
        if(RST_inp = '1') then
            Index <= x"5A";
            current_state <= first_quarter;
            
        elsif(Clock_divided'event and Clock_divided = '1') then
        
            case current_state is
            
                when first_quarter =>
                    Index <= Index + 1 ;
                    if(Index = x"B3") then
                        current_state <= second_quarter;
                    end if;
                
                when second_quarter =>
                    Index <= Index - 1 ;
                    if(Index = x"5A") then
                        current_state <= third_quarter;
                    end if;
                
                when third_quarter =>
                    Index <= Index - 1 ;
                    if(Index = x"01") then
                        current_state <= forth_quarter;
                    end if;
                
                when forth_quarter =>
                    Index <= Index + 1 ;
                    if(Index = x"5A") then
                        current_state <= first_quarter;
                    end if;
                
            end case;
        end if;
    end process;

Carrier_sig_1 <= carrier_table(TO_INTEGER(Index));

-- CARRIER 2 GENERATING (SMALL)
integ <= to_integer(unsigned(Carrier_sig_1)) / 16 + 120; --Conversion from vector to int to compute the small carrier. We divide by 12 (min 10 cd Rubee, then we add an offset to center the signal around 128)
Carrier_sig_2 <= std_logic_vector(to_unsigned(integ, Carrier_sig_2'length)); --Conversion back into vector

-- CLOCK DIVIDER
Clock_divider : process(CLK_inp, RST_inp)
    begin
        if(RST_inp = '1')then
            Counter <= "0000";
        elsif(CLK_inp'event and CLK_inp = '1')then
            Counter <= Counter + 1 ;
            if(Counter = (Freq_ratio-1))then  -- (-1) to start from 0 instead of 1
                Clock_divided <= not Clock_divided;
                Counter <= "0000";
            end if;
        end if;
    end process;

-- OUTPUTS MAPPING
CARRIER_outp_1 <= Carrier_sig_1; --BIG CARRIER
CARRIER_outp_2 <= Carrier_sig_2; --SMALL CARRIER 

end Behavioral;
