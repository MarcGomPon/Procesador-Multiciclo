----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2026 21:49:34
-- Design Name: 
-- Module Name: display_7seg - rtl
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

entity display_7seg is
   Port ( 
      clk : IN STD_LOGIC;
      rst : IN STD_LOGIC;
      data_in : IN STD_LOGIC_VECTOR (15 downto 0);
      seg : OUT STD_LOGIC_VECTOR (6 downto 0);
      an : OUT STD_LOGIC_VECTOR (3 downto 0)
   );
end display_7seg;

architecture rtl of display_7seg is
   -- Contador de 20 bits para el refresco (100 MHz a 95 Hz)
   signal refresh_counter : unsigned(19 downto 0);
   signal sel             : std_logic_vector(1 downto 0);
   signal dig       : std_logic_vector(3 downto 0);
begin

   -- Divisor de reloj: incrementa en cada ciclo de 100MHz
   process(clk, rst)
   begin
      if (rst = '1') then
         refresh_counter <= (others => '0');
      elsif rising_edge(clk) then
         refresh_counter <= refresh_counter + 1;
      end if;
   end process;

   -- Extraemos los 2 bits superiores para cambiar de dígito a la frecuencia adecuada
   sel <= std_logic_vector(refresh_counter(19 downto 18));

   -- Multiplexor de los ánodos (activos en baja) y selección del byte
   process(sel, data_in)
   begin
      case sel is
         when "00" =>
            an <= "1110"; -- Enciende el dígito 0 (derecha)
            dig <= data_in(3 downto 0);
         when "01" =>
            an <= "1101"; -- Enciende el dígito 1
            dig <= data_in(7 downto 4);
         when "10" =>
            an <= "1011"; -- Enciende el dígito 2
            dig <= data_in(11 downto 8);
         when "11" =>
            an <= "0111"; -- Enciende el dígito 3 (izquierda)
            dig <= data_in(15 downto 12);
         when others =>
            an <= "1111";
            dig <= "0000";
      end case;
   end process;

   -- Decodificador Hexadecimal a 7 Segmentos 
   -- Segmentos ordenados como: "g f e d c b a" (Activos con 0 en Basys3)
   process(dig)
   begin
      case dig is
         when x"0" => seg <= "1000000"; -- 0
         when x"1" => seg <= "1111001"; -- 1
         when x"2" => seg <= "0100100"; -- 2
         when x"3" => seg <= "0110000"; -- 3
         when x"4" => seg <= "0011001"; -- 4
         when x"5" => seg <= "0010010"; -- 5
         when x"6" => seg <= "0000010"; -- 6
         when x"7" => seg <= "1111000"; -- 7
         when x"8" => seg <= "0000000"; -- 8
         when x"9" => seg <= "0010000"; -- 9
         when x"A" => seg <= "0001000"; -- A
         when x"B" => seg <= "0000011"; -- b
         when x"C" => seg <= "1000110"; -- C
         when x"D" => seg <= "0100001"; -- d
         when x"E" => seg <= "0000110"; -- E
         when x"F" => seg <= "0001110"; -- F
         when others => seg <= "1111111"; -- Apagado
      end case;
   end process;

end rtl;