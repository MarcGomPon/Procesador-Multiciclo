----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.09.2026 11:03:43
-- Design Name: 
-- Module Name: banco_de_registros - rtl
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity banco_de_registros is
   Port ( 
      clk : IN STD_LOGIC;
      rst : IN STD_LOGIC;
      WE : IN STD_LOGIC;
      RA1 : IN STD_LOGIC_VECTOR (4 downto 0);
      RA2 : IN STD_LOGIC_VECTOR (4 downto 0);
      WA : IN STD_LOGIC_VECTOR (4 downto 0);
      WD : IN STD_LOGIC_VECTOR (31 downto 0);
      RD1 : OUT STD_LOGIC_VECTOR (31 downto 0);
      RD2 : OUT STD_LOGIC_VECTOR (31 downto 0)
   );
end banco_de_registros;

architecture rtl of banco_de_registros is
   type br_t is array(31 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
   signal br : br_t;
begin

RD1 <= br(to_integer(unsigned(RA1)));
RD2 <= br(to_integer(unsigned(RA2)));

   write : process(rst, clk)
   begin
      if (rst = '1') then for i in 0 to 31 loop
         br(i) <= (others=>'0');
         end loop;
      elsif rising_edge(clk) then
         if (WE = '1'AND WA/="00000") then
            br(to_integer(unsigned(WA))) <= WD;
         end if;
      end if;
   end process;   

end rtl;
