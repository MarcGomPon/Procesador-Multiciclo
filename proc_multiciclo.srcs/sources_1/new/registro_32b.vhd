----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.09.2026 21:54:19
-- Design Name: 
-- Module Name: registro_32b - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity registro_32b is
   Port(
      rst : IN STD_LOGIC;
      clk : IN STD_LOGIC;
      enable : IN STD_LOGIC;
      i : IN STD_LOGIC_VECTOR(31 downto 0);
      o : OUT STD_LOGIC_VECTOR(31 downto 0)
    );
end registro_32b;

architecture rtl of registro_32b is

begin
process(clk, rst)
begin
   if (rst = '1') then 
      o <= (others => '0');
   elsif (rising_edge(clk)) then
      if (enable = '1') then
         o <= i;
      end if;
   end if;
end process;


end rtl;