library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FILTER is
    Port ( 
        CLK_inp      : in  std_logic;                      
        RST_inp      : in  std_logic;                      
        SIGNAL_inp   : in  std_logic_vector(7 downto 0); 
         
        SIGNAL_outp  : out std_logic_vector(7 downto 0)  
    );
end FILTER;

architecture Behavioral of FILTER is

signal entry : std_logic_vector(7 downto 0) :=x"80";
signal outpt : std_logic_vector(7 downto 0) :=x"40";
signal counter : std_logic_vector(15 downto 0) :=x"0000";

signal integ : integer; 

begin

FILTERING : process(CLK_inp, RST_inp)
    begin
        if(RST_inp = '1') then
            entry <= x"00";
            outpt <= x"00";
            counter <= (others => '0');
        elsif(CLK_inp'event and CLK_inp = '1') then
            entry <= SIGNAL_inp;  
            if(counter = x"0900") then
                counter <= (others => '0') ;
                integ <= to_integer(unsigned(entry) + unsigned(outpt)) /2 ;
                outpt <= std_logic_vector(to_unsigned(integ, 8));
            else
                counter <= counter + 1 ;
            end if;
        end if;
    end process;

SIGNAL_outp <= x"0A";

end Behavioral;
