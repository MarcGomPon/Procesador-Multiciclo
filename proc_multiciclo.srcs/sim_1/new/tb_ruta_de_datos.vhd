----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.10.2026 19:46:29
-- Design Name: 
-- Module Name: tb_ruta_de_datos - beh
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench para la ruta de datos (Procesador completo)
--              Ejecuta el programa cargado en memoria (programa_prueba.coe)
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

entity tb_ruta_de_datos is
end tb_ruta_de_datos;

architecture beh of tb_ruta_de_datos is

    component ruta_de_datos
       Port ( 
          clk          : in  STD_LOGIC;
          rst          : in  STD_LOGIC;
          debug_enable : in  STD_LOGIC;
          debug_next   : in  STD_LOGIC;
          
          act_state    : out STD_LOGIC_VECTOR (4 downto 0);
          ALUoutput    : out STD_LOGIC_VECTOR (31 downto 0)
       );
    end component;

    -- Inputs
    signal clk          : STD_LOGIC := '0';
    signal rst          : STD_LOGIC := '0';
    signal debug_enable : STD_LOGIC := '0';
    signal debug_next   : STD_LOGIC := '0';
    
    -- Outputs
    signal act_state    : STD_LOGIC_VECTOR (4 downto 0);
    signal ALUoutput    : STD_LOGIC_VECTOR (31 downto 0);

    -- Configuración del reloj
    constant clk_period : time := 50 ns;

begin

    -- Instanciación del procesador completo (Device Under Test)
    dut : ruta_de_datos port map (
       clk          => clk,
       rst          => rst,
       debug_enable => debug_enable,
       debug_next   => debug_next,
       act_state    => act_state,
       ALUoutput    => ALUoutput
    );

    -- Generación del Reloj
    p_clk : process
    begin
       clk <= '1';
       wait for clk_period/2;
       clk <= '0';
       wait for clk_period/2;
    end process;

    -- Proceso principal de estímulos
    p_stim : process
    begin
       -- Inicialización
       -- Mantenemos el debug_enable en '0' para que el procesador 
       -- corra libremente con el reloj del sistema sin esperar al botón.
       -- Se asume que blk_mem_gen_0 ya contiene "programa_prueba.coe"
       debug_enable <= '0';
       debug_next   <= '0';
       
       -- Secuencia de Reset
       rst <= '1';
       wait for 100 ns;
       rst <= '0';
       
       -- Ejecución del programa
       -- El programa tiene unas 45 instrucciones. A un promedio de 4-5 ciclos 
       -- por instrucción, tardará aproximadamente 250 ciclos en terminar.
       -- 250 ciclos * 50 ns = 12.5 us. Damos un margen amplio de 20 us.
       
       wait for 20 us;
       
       -- 4. Fin de la simulación
       -- Llegados a este punto, el procesador debería estar atrapado en el 
       -- bucle infinito del salto final de tu .coe (0000006f -> jal x0, 0)
       wait;
       
    end process;

end beh;