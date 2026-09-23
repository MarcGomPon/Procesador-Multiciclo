----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.09.2026 21:50:00
-- Design Name: 
-- Module Name: tb_ALU_32b - beh
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para la ALU de 32 bits (Estilo adaptado)
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

entity tb_mux4a1 is
end tb_mux4a1;

architecture beh of tb_mux4a1 is

component mux4a1
    Port(
      sel : IN STD_LOGiC_VECTOR (1 downto 0); 
      input0 : IN STD_LOGIC_VECTOR(31 downto 0);
      input1 : IN STD_LOGIC_VECTOR(31 downto 0);
      input2 : IN STD_LOGIC_VECTOR(31 downto 0);
      input3 : IN STD_LOGIC_VECTOR(31 downto 0);
      output : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
end component;

-- inputs
signal in0 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal in1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal in2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal in3 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal s : STD_LOGIC_VECTOR(1 downto 0);
-- outputs
signal o : STD_LOGIC_VECTOR(31 downto 0);


begin

dut : mux4a1 port map (
   sel    => s,
   input0 => in0,
   input1 => in1,
   input2 => in2,
   input3 => in3,
   output => o
);

p_stim : process
begin
   
   in0 <= x"00000000";
   in1 <= x"44444444";
   in2 <= x"88888888";
   in3 <= x"CCCCCCCC";
   wait for 50ns;
   s <= "00";
   wait for 50ns;
   s <= "01";
   wait for 50ns;
   s <= "10";
   wait for 50ns;
   s <= "11";
   wait;
end process;

end beh;