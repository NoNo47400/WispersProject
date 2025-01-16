----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 01/03/2025 11:51:49 AM
-- Design Name: Rubee_v0.1
-- Module Name: decode_pdu - Behavioral
-- Project Name: Wispers
-- Target Devices: Basys3
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decode_pdu is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           rx_buffer : in STD_LOGIC_VECTOR(7 downto 0);
           fcs : out STD_LOGIC_VECTOR(7 downto 0));
end decode_pdu;

architecture Behavioral of decode_pdu is
    signal fcs_reg : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal nibble_count : integer := 0;
begin
    process(clk, rst)
    begin
        if rst = '1' then
            fcs_reg <= (others => '0');
            nibble_count <= 0;
        elsif rising_edge(clk) then
            if nibble_count < 2 then
                fcs_reg(3 downto 0) <= rx_buffer(3 downto 0);
                nibble_count <= nibble_count + 1;
            else
                fcs_reg(7 downto 4) <= rx_buffer(7 downto 4);
                nibble_count <= 0;
            end if;
        end if;
    end process;

    fcs <= fcs_reg;
end Behavioral;
