----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.09.2026 22:09:08
-- Design Name: 
-- Module Name: tb_registro_32b - Behavioral
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_registro_32b is
end tb_registro_32b;



architecture beh of tb_registro_32b is

component registro_32b
   Port(
      rst : IN STD_LOGIC;
      clk : IN STD_LOGIC;
      enable : IN STD_LOGIC;
      input : IN STD_LOGIC_VECTOR(31 downto 0);
      output : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
end component;

--input
signal rst : STD_LOGIC;
signal clk : STD_LOGIC;
signal enable : STD_LOGIC;
signal i : STD_LOGIC_VECTOR(31 downto 0);
--output
signal o : STD_LOGIC_VECTOR(31 downto 0);
   
constant clk_period : time := 50ns;

begin

dut : registro_32b port map (
   rst => rst,
   clk => clk,
   enable => enable,
   input => i,
   output => o
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
   rst <= '1';
   wait for 50 ns;
   rst <= '0';
   wait for 50 ns;

   i <= x"AAAA5555";
   enable <= '1';
   wait for 100 ns; 

   enable <= '0';
   i <= x"FFFF0000";
   wait for 100 ns; 

   enable <= '1';
   wait for 100 ns; 

    wait;
end process;

end beh;