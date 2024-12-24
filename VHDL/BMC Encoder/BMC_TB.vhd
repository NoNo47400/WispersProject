library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bmc_encoder_tb is
end bmc_encoder_tb;

architecture behavior of bmc_encoder_tb is
    -- Constantes
    constant CLK_PERIOD : time := 10 ns;
    constant PDU_MAX_LEN : integer := 4;

    -- Signaux de test
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal pdu_in : std_logic_vector(PDU_MAX_LEN*4-1 downto 0) := (others => '0');
    signal pdu_out : std_logic_vector(PDU_MAX_LEN*8-1 downto 0);
    signal pdu_len_in : unsigned(7 downto 0);
    signal done : std_logic;

    -- Composant à tester
    component bmc_encoder is
        generic (
            PDU_MAX_LEN : integer := 2
        );
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            start       : in std_logic;
            pdu_in      : in std_logic_vector(PDU_MAX_LEN*4-1 downto 0);
            pdu_out     : out std_logic_vector(PDU_MAX_LEN*8-1 downto 0);
            pdu_len_in  : in unsigned(7 downto 0);
            done        : out std_logic
        );
    end component;

begin
    -- Instanciation du composant à tester
    uut: bmc_encoder
        generic map (
            PDU_MAX_LEN => PDU_MAX_LEN
        )
        port map (
            clk => clk,
            reset => reset,
            start => start,
            pdu_in => pdu_in,
            pdu_out => pdu_out,
            pdu_len_in => pdu_len_in,
            done => done
        );

    -- Génération de l'horloge
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Process de stimulation
    stim_proc: process
    begin
        -- Reset initial
        reset <= '1';
        wait for CLK_PERIOD*2;
        reset <= '0';
        wait for CLK_PERIOD;

        -- Préparation des données d'entrée
        -- Deux nibbles : "0101" et "1100"
        pdu_in(3 downto 0) <= "0101";  -- Premier nibble
        pdu_in(7 downto 4) <= "1100";  -- Deuxième nibble
        pdu_len_in <= x"02";  -- Deux nibbles

        -- Démarrage de l'encodage
        wait for CLK_PERIOD*2;
        start <= '1';
        wait for CLK_PERIOD;
        start <= '0';

        -- Attente de la fin de l'encodage
        wait until done = '1';
        wait for CLK_PERIOD*2;

        wait for CLK_PERIOD*10;
        wait;
    end process;

end behavior;