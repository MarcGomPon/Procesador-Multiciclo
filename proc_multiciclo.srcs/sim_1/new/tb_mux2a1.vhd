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

entity tb_mux2a1 is
end tb_mux2a1;

architecture beh of tb_mux2a1 is

component mux2a1
    Port(
      sel : IN STD_LOGiC; 
      input0 : IN STD_LOGIC_VECTOR(31 downto 0);
      input1 : IN STD_LOGIC_VECTOR(31 downto 0);
      output : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
end component;

-- inputs
signal in0 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal in1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal s : STD_LOGIC;
-- outputs
signal o : STD_LOGIC_VECTOR(31 downto 0);


begin

dut : mux2a1 port map (
   sel    => s,
   input0 => in0,
   input1 => in1,
   output => o
);

p_stim : process
begin
   
   in0 <= x"FFFFFFFF";
   in1 <= x"12345678";
   wait for 50ns;
   s <= '1';
   wait for 50ns;
   s <= '0';
   wait;
end process;

end beh;