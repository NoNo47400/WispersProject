----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 01/15/2025 02:39:10 PM
-- Design Name: Rubee_v0.1
-- Module Name: header_detection - Behavioral
-- Project Name: Wispers
-- Target Devices: Basys3
-- Tool Versions: 
-- Description: 
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity header_detection is
    Port ( 
        CLK_in : in std_logic;
        RST_in : in std_logic;
        DEMODULATED_in : in std_logic;
        
        FLAG_out : out std_logic
    );
end header_detection;

architecture Behavioral of header_detection is

    signal Shift_Register : std_logic_vector(11 downto 0) := (others => '0');
    constant Target_Value : std_logic_vector(11 downto 0) := x"005";

begin

    PROCESS(CLK_in, RST_in)
    begin
        if RST_in = '1' then
            Shift_Register <= (others => '0');
        elsif rising_edge(CLK_in) then
            -- Shift in the new bit and discard the oldest bit
            Shift_Register <= Shift_Register(10 downto 0) & DEMODULATED_in;
        end if;
    end PROCESS;

    -- Raise flag if the 12-bit value equals the target
    FLAG_out <= '1' when Shift_Register = Target_Value else '0';

end Behavioral;