----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2026 18:12:22
-- Design Name: 
-- Module Name: extension_de_signo - rtl
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

entity extension_de_signo is
   Port ( 
      instr   : IN  STD_LOGIC_VECTOR(31 downto 0); -- Instrucción completa de 32 bits
      ImmSrc  : IN  STD_LOGIC_VECTOR(2 downto 0);  -- Selector del tipo de inmediato
      imm : OUT STD_LOGIC_VECTOR(31 downto 0)  -- Inmediato extendido a 32 bits
   );
end extension_de_signo;

architecture rtl of extension_de_signo is
signal imm_temp : signed(31 downto 0);
begin

imm_temp <= resize(signed(instr(31 downto 20)), 32) when (ImmSrc = "000") else --tipo I
            resize(signed(instr(31 downto 25) & instr(11 downto 7)), 32) when (ImmSrc = "001") else -- tipo S
            resize(signed(instr(31) & instr(7) & instr(30 downto 25) & instr(11 downto 8) & '0'),32) when (ImmSrc = "010") else -- tipo B
            signed(instr(31 downto 12)  & x"000") when (ImmSrc = "011") else -- tipo U
            resize(signed(instr(31) & instr(19 downto 12) & instr(20) & instr(30 downto 21) & '0'), 32) when (ImmSrc = "100") else -- tipo J
            (others => '0');
           
 imm <= std_logic_vector(imm_temp);


end rtl;
