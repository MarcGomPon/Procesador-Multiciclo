----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.10.2026 12:46:08
-- Design Name: 
-- Module Name: tb_uniddad_de_control - beh
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

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.10.2026 10:00:00
-- Design Name: 
-- Module Name: tb_unidad_de_control - beh
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para la unidad de control multiciclo
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_unidad_de_control is
end tb_unidad_de_control;

architecture beh of tb_unidad_de_control is

component unidad_de_control
   Port ( 
      clk      : IN STD_LOGIC;
      rst      : IN STD_LOGIC;
      op       : IN STD_LOGIC_VECTOR (6 downto 0);
      func3    : IN STD_LOGIC_VECTOR (2 downto 0);
      func7    : IN STD_LOGIC;
      zero     : IN STD_LOGIC;
      sign     : IN STD_LOGIC;
      overflow : IN STD_LOGIC;
      carry    : IN STD_LOGIC;
      control  : OUT STD_LOGIC_VECTOR (28 downto 0);
      debug_state : OUT STD_LOGIC_VECTOR (4 downto 0)
   );
end component;

-- Inputs
signal clk      : STD_LOGIC := '0';
signal rst      : STD_LOGIC := '0';
signal op       : STD_LOGIC_VECTOR(6 downto 0) := (others => '0');
signal func3    : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
signal func7    : STD_LOGIC := '0';
signal zero     : STD_LOGIC := '0';
signal sign     : STD_LOGIC := '0';
signal overflow : STD_LOGIC := '0';
signal carry    : STD_LOGIC := '0';

-- Outputs
signal control  : STD_LOGIC_VECTOR(28 downto 0);
signal debug_state : STD_LOGIC_VECTOR(4 downto 0);

constant clk_period : time := 50 ns;

begin

dut : unidad_de_control port map (
   clk      => clk,
   rst      => rst,
   op       => op,
   func3    => func3,
   func7    => func7,
   zero     => zero,
   sign     => sign,
   overflow => overflow,
   carry    => carry,
   control  => control,
   debug_state => debug_state
);

p_clk : process
begin
   clk <= '1';
   wait for clk_period/2;
   clk <= '0';
   wait for clk_period/2;
end process;

p_stim : process
begin
   -- Inicializamos entradas
   op       <= (others => '0');
   func3    <= (others => '0');
   func7    <= '0';
   zero     <= '0';
   sign     <= '0';
   overflow <= '0';
   carry    <= '0';

   -- Reset
   rst <= '1';
   wait for 50 ns;
   rst <= '0';
   wait for 50 ns; 
   -- Ahora estamos en el estado S_FETCH

   -----------------------------------------------
   -- Instrucción Tipo R (ADD)
   -- Estados: FETCH -> DECODE -> EX_R -> WB_ALU 
   -----------------------------------------------
   op    <= "0110011"; 
   func3 <= "000"; 
   func7 <= '0';
   wait for clk_period * 4; 

   --------------------------------------------------------------
   -- Instrucción Load (LW)
   -- Estados: FETCH -> DECODE -> MEM_ADDR -> MEM_READ -> MEM_WB
   --------------------------------------------------------------
   op    <= "0000011";
   func3 <= "010"; 
   wait for clk_period * 5;

   -----------------------------------------------------
   --Instrucción Store (SW)
   -- Estados: FETCH -> DECODE -> MEM_ADDR -> MEM_WRITE 
   -----------------------------------------------------
   op    <= "0100011";
   func3 <= "010";
   wait for clk_period * 4;

   -------------------------------------------------------
   -- Instrucción Branch TOMADA (BEQ, Zero = 1)
   -- Estados: FETCH -> DECODE -> BRANCH -> BRANCH_TAKEN 
   -------------------------------------------------------
   op    <= "1100011";
   func3 <= "000";
   zero  <= '1'; -- Condición de salto BEQ se cumple
   wait for clk_period * 4;

   -----------------------------------------------------------
   -- Instrucción Branch NO TOMADA (BEQ, Zero = 0)
   -- Estados: FETCH -> DECODE -> BRANCH
   ----------------------------------------------------------
   op    <= "1100011";
   func3 <= "000";
   zero  <= '0'; -- Condición de salto BEQ NO se cumple
   wait for clk_period * 3;

   ---------------------------------------------
   -- Instrucción LUI
   -- Estados: FETCH -> DECODE -> LUI -> WB_ALU 
   ---------------------------------------------
   op    <= "0110111";
   wait for clk_period * 4;

   ---------------------------------------------------------
   -- Instrucción Salto JAL
   -- Estados: FETCH -> DECODE -> JAL_1 -> JAL_2 -> WB_ALU
   ---------------------------------------------------------
   op    <= "1101111";
   wait for clk_period * 5;
   
   ---------------------------------------------
   -- Instrucción Tipo I Aritmética (ADDI)
   -- Estados: FETCH -> DECODE -> EX_I -> WB_ALU
   ---------------------------------------------
   op    <= "0010011";
   func3 <= "000";
   wait for clk_period * 4;

   -------------------------------------------------
   -- Instrucción AUIPC
   -- Estados: FETCH -> DECODE -> AUIPC -> WB_ALU 
   -------------------------------------------------
   op    <= "0010111";
   wait for clk_period * 4;

   ---------------------------------------------------------
   -- PRUEBA 10: Instrucción JALR
   -- Estados: FETCH -> DECODE -> JALR_1 -> JALR_2 -> WB_ALU
   ---------------------------------------------------------
   op    <= "1100111";
   func3 <= "000";
   wait for clk_period * 5;
   
   op       <= (others => '0');
   func3    <= (others => '0');
   func7    <= '0';
   zero     <= '0';
   sign     <= '0';
   overflow <= '0';
   carry    <= '0';

   wait;
end process;

end beh;