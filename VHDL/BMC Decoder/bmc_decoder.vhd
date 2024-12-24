library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bmc_decoder is
    generic (
        PDU_MAX_LEN   : integer := 256
    );
    port (
        clk             : in std_logic;                      
        reset           : in std_logic;                     
        start           : in std_logic;                    
        pdu_in          : in std_logic_vector(PDU_MAX_LEN*8-1 downto 0);
        pdu_out         : out std_logic_vector(PDU_MAX_LEN*4-1 downto 0);
        pdu_len_in  : in unsigned(7 downto 0);  -- Longueur du PDU en nibble
        pdu_len_out : out unsigned(7 downto 0); -- Longueur du PDU en bytes
        done            : out std_logic                    
    );
end bmc_decoder;

architecture rtl of bmc_decoder is
    type state_type is (IDLE, DECODING, DONE_STATE);
    signal current_state : state_type;
    signal bit_counter : unsigned(10 downto 0) := (others => '0'); -- Pour indexer les bytes encodés
    signal output_counter : unsigned(9 downto 0) := (others => '0'); -- Pour indexer les nibbles décodés 
begin
    process(clk)
        variable current_bits : std_logic_vector(7 downto 0);
        variable decoded_nibble : std_logic_vector(3 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= IDLE;
                bit_counter <= (others => '0');
                output_counter <= (others => '0');
                done <= '0';
                pdu_out <= (others => '0');
            else
                case current_state is
                    when IDLE =>
                        if start = '1' then
                            current_state <= DECODING;
                            bit_counter <= (others => '0');
                            output_counter <= (others => '0');
                            done <= '0';
                        end if;

                    when DECODING =>
                        if bit_counter < pdu_len_in * 8 then
                            current_bits := pdu_in(to_integer(bit_counter)+7 downto to_integer(bit_counter));
                            
                            for i in 0 to 3 loop
                                if current_bits(i*2) /= current_bits(i*2+1) then
                                    decoded_nibble(i) := '1';
                                else
                                    decoded_nibble(i) := '0';
                                end if;
                            end loop;
                            
                            pdu_out(to_integer(output_counter)+3 downto to_integer(output_counter)) <= decoded_nibble;
                            bit_counter <= bit_counter + 8;
                            output_counter <= output_counter + 4;
                        else
                            current_state <= DONE_STATE;
                            pdu_len_out <= pdu_len_in / 2;
                        end if;

                    when DONE_STATE =>
                        done <= '1';
                        current_state <= IDLE;
                end case;
            end if;
        end if;
    end process;
end rtl;
