----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 11/20/2024 03:20:18 PM
-- Design Name: Rubee_v0.1
-- Module Name: calculate_fcs - Behavioral
-- Project Name: Wisper
-- Target Devices: Basys3
-- Additional Comments:
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity serialize_pdu is
    generic (
        MAX_BUFFER_LEN : integer := 256
    );
    port (
        pdu_in      : in std_logic_vector(255 downto 0); -- Input PDU (example size)
        pdu_len     : in integer;
        buffer_out  : out std_logic_vector(MAX_BUFFER_LEN - 1 downto 0);
        buffer_size : out integer
    );
end serialize_pdu;

architecture Behavioral of serialize_pdu is
begin
    process(pdu_in, pdu_len)
        variable index : integer := 0;
    begin
        if pdu_len <= MAX_BUFFER_LEN then
            buffer_out(0 to pdu_len - 1) <= pdu_in(0 to pdu_len - 1);
            buffer_size <= pdu_len;
        else
            buffer_size <= 0; -- Indicate an error if buffer is too small
        end if;
    end process;
end Behavioral;
