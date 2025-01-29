library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FILTER is
    Port ( 
        CLK_inp      : in  std_logic;                        -- Horloge
        RST_inp      : in  std_logic;                        -- Reset
        SIGNAL_inp   : in  std_logic_vector(7 downto 0);     -- Signal d'entrée
        SIGNAL_outp  : out std_logic_vector(7 downto 0)      -- Signal filtré
    );
end FILTER;

architecture Behavioral of FILTER is

    -- Déclaration du type et du tableau des échantillons
    type sample_array is array (0 to 15) of unsigned(7 downto 0); -- Tableau de 32 échantillons de 8 bits
    signal samples : sample_array := (others => (others => '0')); -- Initialisation des échantillons à 0

    -- Autres signaux internes
    signal sum     : unsigned(14 downto 0) := (others => '0');   -- Somme des échantillons (15 bits pour éviter le débordement)
    signal filtered_value : unsigned(7 downto 0) := (others => '0'); -- Valeur filtrée (8 bits)

    signal clock_divided : std_logic :='0';
    signal counter : unsigned(7 downto 0) := (others => '0');
    
begin

    FILTERING : process(clock_divided, RST_inp)
    begin
        if RST_inp = '1' then
            -- Réinitialisation des signaux
            samples <= (others => (others => '0'));
            sum <= (others => '0');
            filtered_value <= (others => '0');
        elsif rising_edge(clock_divided) then
            -- Décalage des échantillons et ajout de l'input actuel
            samples(0 to 14) <= samples(1 to 15);
            samples(15) <= unsigned(SIGNAL_inp);

            -- Calcul de la somme des 32 échantillons
            sum <= resize(samples(0), 15) + resize(samples(1), 15) + 
                   resize(samples(2), 15) + resize(samples(3), 15) + 
                   resize(samples(4), 15) + resize(samples(5), 15) + 
                   resize(samples(6), 15) + resize(samples(7), 15) + 
                   resize(samples(8), 15) + resize(samples(9), 15) + 
                   resize(samples(10), 15) + resize(samples(11), 15) + 
                   resize(samples(12), 15) + resize(samples(13), 15) + 
                   resize(samples(14), 15) + resize(samples(15), 15) ;

            -- Calcul de la moyenne
            filtered_value <= sum(13 downto 6); -- Division par 32 (32 échantillons)
        end if;
    end process;
    
    -- PROCESS POUR DIVISER PAR 100 LA CLOCK SYTEME (100MHz -> 1MHz)
    CLK_DIVISION : process(CLK_inp, RST_inp)
    begin
        if(RST_inp = '1') then
            counter <= (others => '0');
            clock_divided <= '0';
        elsif (CLK_inp'event and CLK_inp = '1') then
            counter <= counter + 1;
            if (counter = x"0A") then
                clock_divided <= not clock_divided;
                counter <= (others => '0');
            end if;
        end if;
    end process;

    -- Conversion du signal filtré en std_logic_vector pour la sortie
    SIGNAL_outp <= std_logic_vector(filtered_value);

end Behavioral;