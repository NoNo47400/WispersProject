library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bmc_decoder_transition is
    port (
        clk             : in std_logic;                      
        reset           : in std_logic;                    
        pdu_in          : in std_logic;
        pdu_out         : out std_logic;
        done            : out std_logic                    
    );
end bmc_decoder_transition;

architecture rtl of bmc_decoder_transition is
    type state_type is (IDLE, DECODING, DONE_STATE);
    signal current_state            : state_type;
    signal bit_ctn                  : unsigned(11 downto 0) := (others => '0'); --Pour compter entre 2 transitions
    signal synchro_bit_ctn          : unsigned(11 downto 0) := (others => '0'); --Pour garder le compte précédent
    signal i_done, i_done_final     : std_logic := '0';
    signal i_done_temp              : std_logic := '0';
    signal i_pdu_out                : std_logic := '0';
    
    -- Ensure signals are declared as std_logic and not duplicated
    signal current_bit              : std_logic := '0';
    signal last_pdu_in              : std_logic := '0';
    signal reset_ctn                : std_logic := '0';

begin
    process(clk, reset, pdu_in)
    begin
        if reset = '1' then
            current_state <= IDLE;
            bit_ctn <= (others => '0');
            current_bit <= '0';
            synchro_bit_ctn <= (others => '0');
            i_pdu_out <= '0';
            i_done <= '0';
        else            
            if ((last_pdu_in = '0' and pdu_in = '1') or (last_pdu_in = '1' and pdu_in = '0')) and (reset_ctn = '0') then
                if synchro_bit_ctn = 0 then --Pas de transition avant, on est pas sur mais on pourra corriger après
                    synchro_bit_ctn <= bit_ctn;
                    reset_ctn <= '1';
                elsif bit_ctn > (synchro_bit_ctn + (synchro_bit_ctn / 2)) then --On s'etait trompé, on adapte
                    synchro_bit_ctn <= bit_ctn;
                    reset_ctn <= '1';
                elsif bit_ctn > ((synchro_bit_ctn * 9) / 10) then --Longue transition veut dire '0'
                    i_pdu_out <= '0';
                    i_done <= '1';
                    reset_ctn <= '1';
                elsif bit_ctn < ((synchro_bit_ctn * 6) / 10) then --Courte transition veut dire '1'
                    if (current_bit = '0') then
                        i_pdu_out <= '1';
                        current_bit <= '1';
                    else
                        i_done <= '1';
                        current_bit <= '0';
                    end if;
                    reset_ctn <= '1';
                end if;
            end if;
            
            if rising_edge(clk) then --remettre done a 0 une période d'horloge
                last_pdu_in <= pdu_in;
                bit_ctn <= bit_ctn + 1;
                if reset_ctn = '1' then
                    bit_ctn <= (others => '0');
                    reset_ctn <= '0';
                end if;
                
                if i_done_temp = '1' then
                    i_done_temp <= '0';
                    i_done <= '0';
                elsif i_done = '1' then
                    i_done_temp <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Assign outputs to internal signals to avoid multi-driven nets
    done <= i_done;
    pdu_out <= i_pdu_out;

end rtl;
