----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.09.2026 20:09:30
-- Design Name: 
-- Module Name: ALU_32b - rtl
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
use IEEE.NUMERIC_STD.all;

entity ALU_32b is
   Port ( 
      A : IN STD_LOGIC_VECTOR (31 downto 0);
      B : IN STD_LOGIC_VECTOR (31 downto 0);
      ALUctr : IN STD_LOGIC_VECTOR (3 downto 0);
      R : OUT STD_LOGIC_VECTOR (31 downto 0);
      zero : OUT STD_LOGIC;
      sign : OUT STD_LOGIC;
      carry : OUT STD_LOGIC;
      overflow : OUT STD_LOGIC
   );
end ALU_32b;

architecture rtl of ALU_32b is
   -- Señales con signo
   signal A_signed   : signed(31 downto 0);
   signal B_signed   : signed(31 downto 0);
   signal R_signed   : signed(31 downto 0);
    
   -- Señales sin signo necesarias para desplazamientos lógicos y SLTU
   signal A_unsigned : unsigned(31 downto 0);
   signal B_unsigned : unsigned(31 downto 0);
   
   -- Señal para el carry
   signal ext  : unsigned(32 downto 0);
begin
   
   -- Casting entrada
   A_signed <= signed(A);
   B_signed <= signed(B);
   A_unsigned <= unsigned(A);
   B_unsigned <= unsigned(B);
   
   -- Calculo extendido para el carry (un solo sumador/restador inferido)
   ext <= resize(A_unsigned, 33) + resize(B_unsigned, 33) when (ALUctr = "0000") else
          resize(A_unsigned, 33) - resize(B_unsigned, 33);
                 
    -- Lógica combinacional
    R_signed <= -- Aritméticas
                signed(ext(31 downto 0)) when (ALUctr = "0000" or ALUctr = "0001") else -- ADD / SUB
                
                -- Lógicas
                A_signed and B_signed when (ALUctr = "0010") else -- AND, ANDI
                A_signed or B_signed when (ALUctr = "0011") else -- OR, ORI
                A_signed xor B_signed when (ALUctr = "0100") else -- XOR, XORI
                
                -- Desplazamiento
                signed(shift_left(A_unsigned, to_integer(B_unsigned(4 downto 0)))) when (ALUctr = "0111") else -- SLL, SLLI
                signed(shift_right(A_unsigned, to_integer(B_unsigned(4 downto 0)))) when (ALUctr = "1000") else -- SRL, SRLI
                shift_right(A_signed, to_integer(B_unsigned(4 downto 0))) when (ALUctr = "1001") else -- SRA, SRAI
                
                -- Saltos
                -- SLT / SLTI (Comparación con signo usando la resta)
                x"00000001" when (ALUctr = "0101" and (((A(31) and not B(31)) or (not (A(31) xor B(31)) and ext(31))) = '1')) else 
                x"00000000" when (ALUctr = "0101") else
                
                -- SLTU / SLTIU (Comparación sin signo usando el Carry de la resta)
                x"00000001" when (ALUctr = "0110" and ext(32) = '1') else 
                x"00000000" when (ALUctr = "0110") else
                
                (others=>'0');

   -- Puertos de salida
   R <= std_logic_vector(R_signed);
   Zero <= '1' when (R_signed = x"00000000") else '0';
   sign <= R_signed(31);
   carry <= ext(32) when (ALUctr = "0000" or ALUctr = "0001") else '0';
   
   overflow <= ((A(31) xnor B(31)) and (A(31) xor R_signed(31))) when (ALUctr = "0000") else
               ((A(31) xor B(31)) and (A(31) xor R_signed(31))) when (ALUctr = "0001") else
               '0';

end rtl;
