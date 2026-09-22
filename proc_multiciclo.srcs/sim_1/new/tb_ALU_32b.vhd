----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.09.2026 21:49:00
-- Design Name: 
-- Module Name: tb_ALU_32b - beh
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

entity tb_ALU_32b is
end tb_ALU_32b;

architecture beh of tb_ALU_32b is

component ALU_32b
    Port(
      A : IN STD_LOGIC_VECTOR (31 downto 0);
      B : IN STD_LOGIC_VECTOR (31 downto 0);
      ALUctr : IN STD_LOGIC_VECTOR (3 downto 0);
      R : OUT STD_LOGIC_VECTOR (31 downto 0);
      zero : OUT STD_LOGIC;
      sign : OUT STD_LOGIC;
      carry : OUT STD_LOGIC;
      overflow : OUT STD_LOGIC
      );
end component;

-- inputs
signal A : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal B : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal ALUctr : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
-- outputs
signal R : STD_LOGIC_VECTOR(31 downto 0);
signal zero : STD_LOGIC;
signal sign : STD_LOGIC;
signal carry : STD_LOGIC;
signal overflow : STD_LOGIC;

begin

dut : ALU_32b port map (
   A => A,
   B => B,
   ALUctr => ALUctr,
   R => R,
   zero => zero,
   sign => sign,
   carry => carry,
   overflow => overflow
);

p_stim : process
begin
   -- =========================================================
   -- SUMA (0000): Casos normales, Carry y Overflow
   -- =========================================================
   ALUctr <= "0000";
   
   -- Suma simple (1 + 2 = 3)
   A <= x"00000001"; 
   B <= x"00000002"; 
   wait for 50 ns;
   
   -- Suma que genera Carry sin signo (Max Unsigned + 1)
   A <= x"FFFFFFFF"; 
   B <= x"00000001"; 
   wait for 50 ns;
   
   -- Suma con Overflow (Positivo + Positivo = Negativo)
   A <= x"7FFFFFFF"; 
   B <= x"00000001"; 
   wait for 50 ns;
   
   -- Suma con Overflow (Negativo + Negativo = Positivo)
   A <= x"80000000"; 
   B <= x"80000000"; 
   wait for 50 ns;

   -- =========================================================
   -- RESTA (0001): Casos normales, Zero, Sign y Overflow
   -- =========================================================
   ALUctr <= "0001";
   
   -- Resta que da Zero -> zero = 1
   A <= x"00000004"; 
   B <= x"00000004"; 
   wait for 50 ns;
   
   -- Resta que da negativo (5 - 10 = -5) -> sign = 1
   A <= x"00000005"; 
   B <= x"0000000A"; 
   wait for 50 ns;
   
   -- Resta con Overflow (Negativo - Positivo = Positivo)
   A <= x"80000000"; 
   B <= x"00000001"; 
   wait for 50 ns;

   -- =========================================================
   -- OPERACIONES LÓGICAS (0010, 0011, 0100)
   -- =========================================================
   -- AND (0010)
   ALUctr <= "0010";
   A <= x"FFFFF000"; 
   B <= x"000FFFFF"; 
   wait for 50 ns;
   
   -- OR (0011)
   ALUctr <= "0011";
   A <= x"FFFFF000"; 
   B <= x"000FFFFF"; 
   wait for 50 ns;
   
   -- XOR (0100)
   ALUctr <= "0100";
   A <= x"FFFFF000"; 
   B <= x"000FFFFF"; 
   wait for 50 ns;

   -- =========================================================
   -- COMPARACIONES (SLT y SLTU)
   -- =========================================================
   -- SLT (0101): Negativo < Positivo (-1 < 1) -> R = 1
   ALUctr <= "0101";
   A <= x"FFFFFFFF"; 
   B <= x"00000001"; 
   wait for 50 ns;
   
   -- SLT (0101): Falso Overflow (Extremos opuestos) -> R = 1
   A <= x"80000000"; 
   B <= x"7FFFFFFF"; 
   wait for 50 ns;
   
   -- SLTU (0110): Max unsigned vs 1 (4.2B no es menor que 1) -> R = 0
   ALUctr <= "0110";
   A <= x"FFFFFFFF"; 
   B <= x"00000001"; 
   wait for 50 ns;

   -- =========================================================
   -- DESPLAZAMIENTOS SHIFTS (0111, 1000, 1001)
   -- =========================================================
   A <= x"F0000000"; 
   B <= x"00000004"; 
   
   -- SLL (0111)
   ALUctr <= "0111"; 
   wait for 50 ns;
   
   --  SRL (1000)
   ALUctr <= "1000"; 
   wait for 50 ns;
   
   -- SRA (1001)
   ALUctr <= "1001"; 
   wait for 50 ns;

   wait;
end process;

end beh;