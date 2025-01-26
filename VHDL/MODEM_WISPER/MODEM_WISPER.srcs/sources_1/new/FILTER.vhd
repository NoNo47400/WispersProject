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
    type sample_array is array (0 to 31) of unsigned(7 downto 0); -- Tableau de 32 échantillons de 8 bits
    signal samples : sample_array := (others => (others => '0')); -- Initialisation des échantillons à 0

    -- Autres signaux internes
    signal sum     : unsigned(14 downto 0) := (others => '0');   -- Somme des échantillons (15 bits pour éviter le débordement)
    signal filtered_value : unsigned(7 downto 0) := (others => '0'); -- Valeur filtrée (8 bits)

begin

    FILTERING : process(CLK_inp, RST_inp)
    begin
        if RST_inp = '1' then
            -- Réinitialisation des signaux
            samples <= (others => (others => '0'));
            sum <= (others => '0');
            filtered_value <= (others => '0');
        elsif rising_edge(CLK_inp) then
            -- Décalage des échantillons
            samples(31) <= samples(30);
            samples(30) <= samples(29);
            samples(29) <= samples(28);
            samples(28) <= samples(27);
            samples(27) <= samples(26);
            samples(26) <= samples(25);
            samples(25) <= samples(24);
            samples(24) <= samples(23);
            samples(23) <= samples(22);
            samples(22) <= samples(21);
            samples(21) <= samples(20);
            samples(20) <= samples(19);
            samples(19) <= samples(18);
            samples(18) <= samples(17);
            samples(17) <= samples(16);
            samples(16) <= samples(15);
            samples(15) <= samples(14);
            samples(14) <= samples(13);
            samples(13) <= samples(12);
            samples(12) <= samples(11);
            samples(11) <= samples(10);
            samples(10) <= samples(9);
            samples(9) <= samples(8);
            samples(8) <= samples(7);
            samples(7) <= samples(6);
            samples(6) <= samples(5);
            samples(5) <= samples(4);
            samples(4) <= samples(3);
            samples(3) <= samples(2);
            samples(2) <= samples(1);
            samples(1) <= samples(0);
            samples(0) <= unsigned(SIGNAL_inp);

            -- Calcul de la somme des 32 échantillons
            sum <= resize(samples(0), 15) + resize(samples(1), 15) + 
                   resize(samples(2), 15) + resize(samples(3), 15) + 
                   resize(samples(4), 15) + resize(samples(5), 15) + 
                   resize(samples(6), 15) + resize(samples(7), 15) + 
                   resize(samples(8), 15) + resize(samples(9), 15) + 
                   resize(samples(10), 15) + resize(samples(11), 15) + 
                   resize(samples(12), 15) + resize(samples(13), 15) + 
                   resize(samples(14), 15) + resize(samples(15), 15) + 
                   resize(samples(16), 15) + resize(samples(17), 15) + 
                   resize(samples(18), 15) + resize(samples(19), 15) + 
                   resize(samples(20), 15) + resize(samples(21), 15) + 
                   resize(samples(22), 15) + resize(samples(23), 15) + 
                   resize(samples(24), 15) + resize(samples(25), 15) + 
                   resize(samples(26), 15) + resize(samples(27), 15) + 
                   resize(samples(28), 15) + resize(samples(29), 15) + 
                   resize(samples(30), 15) + resize(samples(31), 15);

            -- Calcul de la moyenne
            filtered_value <= sum(14 downto 7); -- Division par 32 (32 échantillons)
        end if;
    end process;

    -- Conversion du signal filtré en std_logic_vector pour la sortie
    SIGNAL_outp <= std_logic_vector(filtered_value);

end Behavioral;
