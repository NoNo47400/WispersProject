library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_bmc_decoder is
end tb_bmc_decoder;

architecture behavior of tb_bmc_decoder is
    -- Composant à tester
    component bmc_decoder_transition
        port (
            clk         : in std_logic;
            reset       : in std_logic;
            pdu_in      : in std_logic;
            pdu_out     : out std_logic;
            done        : out std_logic
        );
    end component;

    -- Signaux pour connecter au composant
    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
    signal pdu_in  : std_logic := '0';
    signal pdu_out : std_logic;
    signal done    : std_logic;

    -- Constantes de simulation
    constant CLK_PERIOD : time := 10 ns; -- Période de l'horloge
    constant BMC_PERIOD : time := 1 us; -- Période normale pour BMC
    constant SLOW_BMC_PERIOD : time := 2 us; -- Période deux fois plus lente
begin
    -- Instanciation du composant
    uut: bmc_decoder_transition
        port map (
            clk => clk,
            reset => reset,
            pdu_in => pdu_in,
            pdu_out => pdu_out,
            done => done
        );

    -- Processus pour générer l'horloge
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    -- Stimulus : génération des transitions sur pdu_in
    stim_process: process
    begin
        -- Initialisation
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Première transition lente
        pdu_in <= '0';
        wait for SLOW_BMC_PERIOD / 2;
        pdu_in <= '1';
        wait for SLOW_BMC_PERIOD / 2;
        pdu_in <= '0';
        
        -- Transition normale
        wait for BMC_PERIOD / 2;
        pdu_in <= '1';
        wait for BMC_PERIOD / 2;
        pdu_in <= '0';
        wait for BMC_PERIOD / 2;
        pdu_in <= '1';
        wait for BMC_PERIOD / 2;
        pdu_in <= '0';

        -- Transition lente (période deux fois plus lente)
        wait for SLOW_BMC_PERIOD / 2;
        pdu_in <= '1';
        wait for SLOW_BMC_PERIOD / 2;
        pdu_in <= '0';

        -- Retour à une transition normale
        wait for BMC_PERIOD / 2;
        pdu_in <= '1';
        wait for BMC_PERIOD / 2;
        pdu_in <= '0';

        -- Fin de simulation
        wait for 200 ns;
        wait;
    end process;
end behavior;
