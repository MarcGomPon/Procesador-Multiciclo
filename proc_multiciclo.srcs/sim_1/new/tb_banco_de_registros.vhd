----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 29.09.2026 11:30:00
-- Design Name: 
-- Module Name: tb_banco_de_registros - beh
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
use IEEE.NUMERIC_STD.ALL;

entity tb_banco_de_registros is
end tb_banco_de_registros;

architecture beh of tb_banco_de_registros is

component banco_de_registros
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
end component;

--input
signal clk : STD_LOGIC;
signal rst : STD_LOGIC;
signal WE : STD_LOGIC;
signal RA1 : STD_LOGIC_VECTOR(4 downto 0);
signal RA2 : STD_LOGIC_VECTOR(4 downto 0);
signal WA : STD_LOGIC_VECTOR(4 downto 0);
signal WD : STD_LOGIC_VECTOR(31 downto 0);
--output
signal RD1 : STD_LOGIC_VECTOR(31 downto 0);
signal RD2 : STD_LOGIC_VECTOR(31 downto 0);

constant clk_period : time := 50ns;

begin

dut : banco_de_registros port map (
   clk => clk,
   rst => rst,
   WE => WE,
   RA1 => RA1,
   RA2 => RA2,
   WA => WA,
   WD => WD,
   RD1 => RD1,
   RD2 => RD2
);

p_clk : process
begin
   clk <= '0';
   wait for clk_period/2;
   clk <= '1';
   wait for clk_period/2;
end process;

p_stim : process
begin
   -- Inicializamos entradas
   WE <= '0';
   RA1 <= (others => '0');
   RA2 <= (others => '0');
   WA <= (others => '0');
   WD <= (others => '0');

   -- Reset según tu estilo
   rst <= '1';
   wait for 50 ns;
   rst <= '0';
   wait for 50 ns;

   -- Escribimos en el registro 5
   WA <= "00101";
   WD <= x"AAAAAAAA";
   WE <= '1';
   wait for 100 ns; 

   -- Dejamos de escribir y leemos el registro 5 en RD1
   WE <= '0';
   RA1 <= "00101";
   wait for 100 ns; 

   -- Escribimos en el registro 10
   WA <= "01010";
   WD <= x"12345678";
   WE <= '1';
   wait for 100 ns; 

   -- Dejamos de escribir y leemos el registro 10 en RD2
   WE <= '0';
   RA2 <= "01010";
   wait for 100 ns; 
   
   -- Prueba escritura en Registro 0 (x0)
   WA <= "00000";
   WD <= x"FFFFFFFF";
   WE <= '1';
   wait for 100 ns;
   
   -- Leemos el x0
   WE <= '0';
   RA1 <= "00000";
   wait for 100 ns;

   wait;
end process;

end beh;