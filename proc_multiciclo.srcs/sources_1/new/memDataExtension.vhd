----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2026 19:41:50
-- Design Name: 
-- Module Name: memDataExtension - rtl
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

entity MDE is
   Port ( 
      mem_in       : IN  STD_LOGIC_VECTOR(31 downto 0); -- Viene de Memoria
      LoadSize     : IN  STD_LOGIC_VECTOR(1 downto 0);  -- Señal LS (2 bits)
      LoadUnsigned : IN  STD_LOGIC;                     -- Señal LU (1 bit)
      data_out     : OUT STD_LOGIC_VECTOR(31 downto 0)  -- Va hacia el MDR
   );
end MDE;

architecture rtl of MDE is
signal data_temp : signed(31 downto 0);

begin

data_temp <= 
        -- Byte (8 bits)
        signed(resize(unsigned(mem_in(7 downto 0)), 32)) when (LoadSize = "00" and LoadUnsigned = '1') else
        resize(signed(mem_in(7 downto 0)), 32)           when (LoadSize = "00" and LoadUnsigned = '0') else
        
        -- Halfword (16 bits)
        signed(resize(unsigned(mem_in(15 downto 0)), 32)) when (LoadSize = "01" and LoadUnsigned = '1') else
        resize(signed(mem_in(15 downto 0)), 32)           when (LoadSize = "01" and LoadUnsigned = '0') else
        
        -- Word (32 bits)
        signed(mem_in) when (LoadSize = "10") else
        
        (others => '0');
        
    -- Asignación final al puerto de salida
    data_out <= std_logic_vector(data_temp); 


end rtl;
