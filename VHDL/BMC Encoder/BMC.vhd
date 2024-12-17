library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bmc_encoder is
    generic (
        PDU_MAX_LEN   : integer := 256
    );
    port (
        clk             : in std_logic;                      
        reset           : in std_logic;                     
        start           : in std_logic;                    
        pdu_in          : in std_logic_vector(PDU_MAX_LEN*4-1 downto 0);
        pdu_out         : out std_logic_vector(PDU_MAX_LEN*8-1 downto 0);
        pdu_len_in      : in integer range 0 to PDU_MAX_LEN;
        pdu_len_out     : out integer range 0 to PDU_MAX_LEN;
        done            : out std_logic                    
    );
end bmc_encoder;

architecture rtl of bmc_encoder is
    type state_type is (IDLE, ENCODING, DONE_STATE);
    signal current_state : state_type;
    signal bit_counter : integer range 0 to PDU_MAX_LEN*4-1;
    signal output_counter : integer range 0 to PDU_MAX_LEN*8-1;
begin
    process(clk)
        variable current_nibble : std_logic_vector(3 downto 0);
        variable encoded_byte : std_logic_vector(7 downto 0);
        variable previous_bit : std_logic := '0';
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
                            current_state <= ENCODING;
                            bit_counter <= 0;
                            output_counter <= 0;
                            done <= '0';
                            previous_bit := '0';
                        end if;

                    when ENCODING =>
                        if bit_counter < pdu_len_in * 4 then
                            current_nibble := pdu_in(bit_counter+3 downto bit_counter);
                            
                            for i in 0 to 3 loop
                                if current_nibble(i) = '1' then
                                    encoded_byte(i*2) := not previous_bit;
                                    previous_bit := not previous_bit;
                                    encoded_byte(i*2 + 1) := not previous_bit;
                                    previous_bit := not previous_bit;
                                else
                                    encoded_byte(i*2) := not previous_bit;
                                    previous_bit := not previous_bit;
                                    encoded_byte(i*2 + 1) := previous_bit;
                                end if;
                            end loop;
                            
                            pdu_out(output_counter+7 downto output_counter) <= encoded_byte;
                            bit_counter <= bit_counter + 4;
                            output_counter <= output_counter + 8;
                        else
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
