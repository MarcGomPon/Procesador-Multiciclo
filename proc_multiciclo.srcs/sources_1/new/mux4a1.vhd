----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.09.2026 11:04:58
-- Design Name: 
-- Module Name: mux2a1 - rtl
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

entity mux4a1 is
   Port (
      sel : IN STD_LOGIC_VECTOR(1 downto 0); 
      input0 : IN STD_LOGIC_VECTOR(31 downto 0);
      input1 : IN STD_LOGIC_VECTOR(31 downto 0);
      input2 : IN STD_LOGIC_VECTOR(31 downto 0);
      input3 : IN STD_LOGIC_VECTOR(31 downto 0);
      output : OUT STD_LOGIC_VECTOR(31 downto 0)
   );
end mux4a1;

architecture rtl of mux4a1 is

begin

   output <= input0 when (sel = "00") else 
             input1 when (sel = "01") else
             input2 when (sel = "10") else
             input3;

end rtl;
