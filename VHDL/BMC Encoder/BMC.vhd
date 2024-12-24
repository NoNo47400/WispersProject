library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bmc_encoder is
    generic (
        PDU_MAX_LEN : integer := 256  -- Taille maximale du PDU
    );
    port (
        clk         : in std_logic;
        reset       : in std_logic;
        start       : in std_logic;
        pdu_in      : in std_logic_vector(PDU_MAX_LEN*4-1 downto 0);
        pdu_out     : out std_logic_vector(PDU_MAX_LEN*8-1 downto 0);
        pdu_len_in  : in unsigned(7 downto 0);  -- Longueur du PDU en nibble
        pdu_len_out : out unsigned(7 downto 0); -- Longueur du PDU en bytes
        done        : out std_logic
    );
end bmc_encoder;

architecture rtl of bmc_encoder is
    type state_type is (IDLE, ENCODING, DONE_STATE);
    signal current_state : state_type;

    -- Compteurs pour suivre les positions dans `pdu_in` et `pdu_out`
    signal bit_counter : unsigned(9 downto 0) := (others => '0'); -- Pour indexer les nibbles
    signal output_counter : unsigned(10 downto 0) := (others => '0'); -- Pour indexer les bytes    
begin
    process(clk)
        variable previous_bit : std_logic := '0';
        variable current_nibble : std_logic_vector(3 downto 0) := (others => '0');
        variable encoded_byte : std_logic_vector(7 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            if reset = '1' then
                -- Réinitialisation
                current_state <= IDLE;
                bit_counter <= (others => '0');
                output_counter <= (others => '0');
                done <= '0';
                pdu_out <= (others => '0');
                previous_bit := '0';
            else
                case current_state is
                    when IDLE =>
                        if start = '1' then
                            -- Initialisation pour le démarrage de l'encodage
                            current_state <= ENCODING;
                            bit_counter <= (others => '0');
                            output_counter <= (others => '0');
                            done <= '0';
                            previous_bit := '0';
                        end if;

                    when ENCODING =>
                        -- Vérification si tous les nibbles ont été encodés
                        if bit_counter < (pdu_len_in * 4) then
                            -- Extraction du nibble courant
                            current_nibble := pdu_in(to_integer(bit_counter)+3 downto to_integer(bit_counter));
                            
                            -- Encodage BMC du nibble
                            for i in 0 to 3 loop
                                if current_nibble(i) = '1' then
                                    encoded_byte(i*2) := not previous_bit;
                                    encoded_byte(i*2 + 1) := previous_bit;
                                else
                                    encoded_byte(i*2) := not previous_bit;
                                    encoded_byte(i*2 + 1) := not previous_bit;
                                    previous_bit := not previous_bit;
                                end if;
                            end loop;

                            -- Stockage du byte encodé dans la sortie
                            pdu_out(to_integer(output_counter)+7 downto to_integer(output_counter)) <= encoded_byte;

                            -- Incrémentation des compteurs
                            bit_counter <= bit_counter + 4;
                            output_counter <= output_counter + 8;
                        else
                            -- Fin de l'encodage
                            current_state <= DONE_STATE;
                            pdu_len_out <= pdu_len_in * 2;
                        end if;

                    when DONE_STATE =>
                        done <= '1';
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end rtl;
