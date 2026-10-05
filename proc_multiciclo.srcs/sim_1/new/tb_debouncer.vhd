----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.10.2026 21:57:37
-- Design Name: 
-- Module Name: tb_debouncer - beh
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

entity tb_debouncer is
end tb_debouncer;

architecture beh of tb_debouncer is

    component debouncer
        Generic (
            DELAY_CYCLES : integer := 1000000 
        );
        Port (
            clk     : in  STD_LOGIC;
            b_in  : in  STD_LOGIC;
            b_out : out STD_LOGIC
        );
    end component;

    signal clk     : STD_LOGIC := '0';
    signal b_in  : STD_LOGIC := '0';
    signal b_out : STD_LOGIC;

    constant clk_period : time := 10 ns; -- Reloj de 100 MHz

begin

    -- Instanciación del módulo. 
    dut: debouncer 
        generic map (
            DELAY_CYCLES => 10 -- sobreescribimos para la prueba
        )
        port map (
            clk     => clk,
            b_in  => b_in,
            b_out => b_out
        );

    -- Proceso del reloj
    p_clk: process
    begin
        clk <= '1';
        wait for clk_period/2;
        clk <= '0';
        wait for clk_period/2;
    end process;

    -- Proceso de estímulos
    p_stim: process
    begin
        -- Estado inicial
        b_in <= '0';
        wait for 50 ns;

        -- Simulamos rebotes al pulsar
        b_in <= '1'; wait for 20 ns;  -- Pico falso
        b_in <= '0'; wait for 15 ns;  -- Cae
        b_in <= '1'; wait for 10 ns;  -- Pico falso
        b_in <= '0'; wait for 25 ns;  -- Cae
        
        -- Pulsación sostenida
        b_in <= '1'; 
        -- Esperamos 15 ciclos
        wait for 150 ns; 

        -- Simulamos rebotes al soltar el botón
        b_in <= '0'; wait for 10 ns;
        b_in <= '1'; wait for 20 ns;
        b_in <= '0'; wait for 15 ns;
        b_in <= '1'; wait for 10 ns;
        
        -- Soltado definitivo y estable
        b_in <= '0';
        wait for 150 ns;

        wait; -- Fin de la simulación
    end process;

end beh;
