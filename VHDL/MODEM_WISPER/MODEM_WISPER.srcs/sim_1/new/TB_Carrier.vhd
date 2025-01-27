library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_Carrier is
end TB_Carrier;

architecture Behavioral of TB_Carrier is

signal RST_sim : std_logic := '0';
signal CLK_sim : std_logic := '0';
signal Counter_sim : unsigned(15 downto 0) :=x"0000";

component Carrier_generator
    port (
    CLK_inp : in std_logic;
    RST_inp : in std_logic;
    
    CARRIER_outp_1 : out std_logic_vector(7 downto 0); --BIG CARRIER
    CARRIER_outp_2 : out std_logic_vector(7 downto 0) --SMALL CARRIER
    );
end component;


begin

TEST : Carrier_generator
    port map (
    CLK_inp => CLK_sim,
    RST_inp => RST_sim,
    
    CARRIER_outp_1 => open,
    CARRIER_outp_2 => open
    );

CLOCK : process
    begin
        --wait for 10.596 ns; --(On veut f=131 072 Hz donc on échantillonne à 47.186 MHz ce qui fait une période de 21.1928ns)
        wait for 5 ns; -- Clock fpga à 100MHz = 10 ns
        CLK_sim <= not CLK_sim;
    end process;

-- Pour compter le nombre de coups d'horloge
--COMPTEUR : process(CLK_sim)
--    begin
--        if(CLK_sim'event and CLK_sim ='1') then
--           Counter_sim <= Counter_sim +1;
--        end if;
--    end process;

--RESET : process
--   begin
--        RST_sim <= '1';
--        wait for 100 us;
--        RST_sim <= '0';
--        wait for 500 us;
--        RST_sim <= '1';
--        wait for 100 us;
--        RST_sim <= '0';
--        wait;
--    end process;

end Behavioral;
