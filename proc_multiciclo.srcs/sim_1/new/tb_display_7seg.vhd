----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2026 22:03:57
-- Design Name: 
-- Module Name: tb_display_7seg - beh
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

entity tb_display_7seg is
end tb_display_7seg;

architecture beh of tb_display_7seg is

   component display_7seg
   Port ( 
      clk      : IN STD_LOGIC;
      rst      : IN STD_LOGIC;
      data_in  : IN STD_LOGIC_VECTOR (15 downto 0);
      seg      : OUT STD_LOGIC_VECTOR (6 downto 0);
      an       : OUT STD_LOGIC_VECTOR (3 downto 0)
   );
   end component;

   -- Señales internas
   signal clk      : std_logic := '0';
   signal rst      : std_logic := '1';
   signal data_in  : std_logic_vector(15 downto 0) := (others => '0');
   signal seg      : std_logic_vector(6 downto 0);
   signal an       : std_logic_vector(3 downto 0);
   
   constant clk_period : time := 10 ns;

begin

   -- 4. Instanciación del módulo
   uut: display_7seg PORT MAP (
      clk => clk,
      rst => rst,
      data_in => data_in,
      seg => seg,
      an => an
    );

    -- Generación del Reloj
   clk_process :process
   begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
   end process;

    -- Proceso de estímulos
   stim_proc: process
   begin		
      -- Reset inicial
      rst <= '1';
      wait for 100 ns;	
      rst <= '0';
        
      -- Mostramos el número hexadecimal "4321"
      data_in <= x"4321";
      -- Esperamos 15 milisegundos. 
      -- Como el contador es de 20 bits, tarda unos 2.6 ms en cambiar de dígito.
      -- Con 15 ms damos tiempo a que la pantalla complete un barrido entero de los 4 números.
      wait for 15 ms;
        
      -- Mostramos letras en hexadecimal "ABCD"
      data_in <= x"ABCD";
      wait for 15 ms;
        
      -- Fin de la simulación
      wait;
   end process;



end beh;
