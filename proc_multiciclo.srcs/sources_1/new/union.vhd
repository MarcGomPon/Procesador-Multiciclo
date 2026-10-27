----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2026 22:12:56
-- Design Name: 
-- Module Name: union - rtl
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

entity union is
   Port ( 
      clk          : in  STD_LOGIC;
      rst          : in  STD_LOGIC;
      debug_enable : in  STD_LOGIC;
      debug_next   : in  STD_LOGIC;
      
      act_state    : out STD_LOGIC_VECTOR (4 downto 0);
      seg          : out STD_LOGIC_VECTOR (6 downto 0);
      an           : out STD_LOGIC_VECTOR (3 downto 0)
   );
end union;

architecture rtl of union is

   -- Procesador
   component ruta_de_datos
      Port ( 
         clk       : in  STD_LOGIC;
         rst       : in  STD_LOGIC;
         enable    : in  STD_LOGIC;
         act_state : out STD_LOGIC_VECTOR (4 downto 0);
         ALUoutput : out STD_LOGIC_VECTOR (31 downto 0)
      );
   end component;

   -- Display
   component display_7seg
      Port ( 
         clk      : IN STD_LOGIC;
         rst      : IN STD_LOGIC;
         data_in  : IN STD_LOGIC_VECTOR (15 downto 0);
         seg      : OUT STD_LOGIC_VECTOR (6 downto 0);
         an       : OUT STD_LOGIC_VECTOR (3 downto 0)
      );
   end component;

   -- Debouncer
   component debouncer
      Generic (
         DELAY_CYCLES : integer := 1000000 
      );
      Port (
         clk   : in  STD_LOGIC;
         b_in  : in  STD_LOGIC;
         b_out : out STD_LOGIC
      );
   end component;

   -- Buses y señales de control
   signal ALU_out_net      : STD_LOGIC_VECTOR(31 downto 0);
   signal debug_step       : STD_LOGIC;
   signal debug_step_reg   : STD_LOGIC := '0';
   signal debug_step_pulse : STD_LOGIC;
   signal sys_en           : STD_LOGIC;

begin

   db : debouncer
      port map(
         clk   => clk,
         b_in  => debug_next,
         b_out => debug_step
      );

   process(clk)
   begin
      if rising_edge(clk) then
         debug_step_reg <= debug_step;
      end if;
   end process;
   
   debug_step_pulse <= debug_step and (not debug_step_reg);
   
   -- Si debug_enable está activo, avanzamos paso a paso con el botón.
   -- Si no, el procesador corre libremente (sys_en = '1').
   sys_en <= debug_step_pulse when debug_enable = '1' else '1';  

   cpu : ruta_de_datos
      port map(
         clk => clk,
         rst => rst,
         enable => sys_en,  
         act_state => act_state,
         ALUoutput => ALU_out_net   
      );

   pantalla : display_7seg
      port map(
         clk      => clk,
         rst      => rst,
         data_in  => ALU_out_net(15 downto 0), -- Mostrar los 16 bits inferiores
         seg      => seg,
         an       => an
      );

end rtl;