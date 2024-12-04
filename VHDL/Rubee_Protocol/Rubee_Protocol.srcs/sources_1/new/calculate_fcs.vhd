----------------------------------------------------------------------------------
-- Company: INSA Toulouse
-- Engineer: Gauché Clément
-- 
-- Create Date: 11/15/2024 09:57:25 AM
-- Design Name: Rubee_v0.1
-- Module Name: calculate_fcs - Behavioral
-- Project Name: Wisper
-- Target Devices: Basys3
-- Additional Comments:
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity declaration for the FCS calculation
entity calculate_fcs is
    port (
        clk     : in std_logic;                    -- Clock input for synchronous operation
        reset   : in std_logic;                    -- Synchronous reset signal
        start   : in std_logic;                    -- Start signal to begin FCS calculation
        data_in : in std_logic_vector(7 downto 0); -- 8-bit data input for each byte processed
        new_calcul : in std_logic;                 -- New calcul asked (reeset the values)
        fcs_out : out std_logic_vector(7 downto 0); -- Calculated 8-bit FCS output
        done    : out std_logic                     -- Signal to indicate completion of FCS calculation
    );
end calculate_fcs;

architecture Behavioral of calculate_fcs is
    -- Internal signal to hold the current value of the FCS during calculation
    signal fcs       : std_logic_vector(7 downto 0) := (others => '0');
    -- Counter to track the number of processed bits
    signal bit_count : integer range 0 to 8 := 0;
    -- Active flag for calculation
    signal active    : std_logic := '0';
    -- Finished flag to indicate completion
    signal finished  : std_logic := '0';
    -- Register for storing the current data byte
    signal data_reg  : std_logic_vector(7 downto 0) := (others => '0');
begin

    -- Main process for FCS calculation
    process(clk)
    begin
        if reset = '1' then
                -- Reset all signals
                fcs <= (others => '0');
                bit_count <= 0;
                finished <= '0';
                active <= '0';
                data_reg <= (others => '0');
        elsif rising_edge(clk) then
            if new_calcul = '1' then
                -- Reset all signals
                fcs <= (others => '0');
                bit_count <= 0;
                finished <= '0';
                active <= '0';
                data_reg <= (others => '0');
            elsif start = '1' and active = '0' then
                -- Initialize calculation on start signal
                active <= '1';
                finished <= '0';
                bit_count <= 8; -- Start processing 8 bits
                fcs <= fcs xor data_in; -- XOR with input data
                data_reg <= data_in;
            elsif active = '1' then
                -- Perform bitwise shifts and conditional XOR with polynomial (0x07)
                if fcs(7) = '1' then
                    fcs <= (fcs(6 downto 0) & '0') xor "00000111";
                else
                    fcs <= (fcs(6 downto 0) & '0');
                end if;

                -- Decrement bit count
                if bit_count > 1 then
                    bit_count <= bit_count - 1;
                else
                    -- End the calculation when all bits are processed
                    active <= '0';
                    finished <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Assign output signals
    fcs_out <= fcs;
    done <= finished;

end Behavioral;

