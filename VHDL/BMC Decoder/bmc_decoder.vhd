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
        pdu_len_in      : in integer range 0 to PDU_MAX_LEN;
        pdu_len_out     : out integer range 0 to PDU_MAX_LEN;
        done            : out std_logic                    
    );
end bmc_decoder;

architecture rtl of bmc_decoder is
    type state_type is (IDLE, DECODING, DONE_STATE);
    signal current_state : state_type;
    signal bit_counter : integer range 0 to PDU_MAX_LEN*8-1;
    signal output_counter : integer range 0 to PDU_MAX_LEN*4-1;
begin
    process(clk)
        variable current_bits : std_logic_vector(7 downto 0);
        variable decoded_nibble : std_logic_vector(3 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                current_state <= IDLE;
                bit_counter <= 0;
                output_counter <= 0;
                done <= '0';
                pdu_out <= (others => '0');
            else
                case current_state is
                    when IDLE =>
                        if start = '1' then
                            current_state <= DECODING;
                            bit_counter <= 0;
                            output_counter <= 0;
                            done <= '0';
                        end if;

                    when DECODING =>
                        if bit_counter < pdu_len_in * 8 then
                            current_bits := pdu_in(bit_counter+7 downto bit_counter);
                            
                            for i in 0 to 3 loop
                                if current_bits(i*2) /= current_bits(i*2+1) then
                                    decoded_nibble(i) := '1';
                                else
                                    decoded_nibble(i) := '0';
                                end if;
                            end loop;
                            
                            pdu_out(output_counter+3 downto output_counter) <= decoded_nibble;
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
