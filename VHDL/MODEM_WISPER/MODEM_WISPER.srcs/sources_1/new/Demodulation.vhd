library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Demodulation is
  Port ( 
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    MODULATED_inp : in std_logic_vector(7 downto 0);
    
    DEMODULATED_outp : out std_logic :='0'
  );
end Demodulation;

architecture Behavioral of Demodulation is

component FILTER is
    Port ( 
        CLK_inp      : in  std_logic;                      
        RST_inp      : in  std_logic;                      
        SIGNAL_inp    : in  std_logic_vector(7 downto 0); 
         
        SIGNAL_outp   : out std_logic_vector(7 downto 0)   
    );
end component;

signal Modulated_sig : std_logic_vector(7 downto 0) :=x"80";
signal Modulated_filtered_sig : std_logic_vector(7 downto 0) :=x"00";
signal Demodulated_sig : std_logic :='0';
constant Level_threshold : std_logic_vector(7 downto 0) := x"a4"; -- Threshold between high and low level

begin

FILTER_LP : FILTER
    port map(
    CLK_inp => CLK_inp,                   
    RST_inp => RST_inp,                 
    SIGNAL_inp => Modulated_sig,
     
    SIGNAL_outp => Modulated_filtered_sig
    );

DEMODULATE : process(CLK_inp, RST_inp)
    begin
        if(RST_inp = '1')then
            Demodulated_sig <= '0';
        elsif(CLK_inp'event and CLK_inp = '1')then
            --ABSOLUTE SIGNAL PROCESS
            if(MODULATED_inp < x"80")then
                Modulated_sig <= not MODULATED_inp;
            else
                Modulated_sig <= MODULATED_inp;
            end if;
            --DEMODU PROCESS
            if(Modulated_filtered_sig < x"24") then
                Demodulated_sig <= '0';
            else 
                Demodulated_sig <= '1';
           end if;
        end if;
    end process;

-- OUTPUTS MAPPING
DEMODULATED_outp <= Demodulated_sig; 

end Behavioral;
