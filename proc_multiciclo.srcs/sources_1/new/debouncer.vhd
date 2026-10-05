----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.10.2026 21:54:12
-- Design Name: 
-- Module Name: debouncer - rtl
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

entity debouncer is
    Generic (
        -- 10 ms con reloj de 100 MHz
        DELAY_CYCLES : integer := 1000000 
    );
    Port (
        clk     : in  STD_LOGIC;
        b_in  : in  STD_LOGIC;
        b_out : out STD_LOGIC
    );
end debouncer;

architecture rtl of debouncer is
    -- Señales de sincronización
    signal b_sync_0 : std_logic := '0';
    signal b_sync_1 : std_logic := '0';
    
    -- Estado estable y contador
    signal b_stable : std_logic := '0';
    signal counter    : integer range 0 to DELAY_CYCLES := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            -- Sincronización para evitar metaestabilidad
            b_sync_0 <= b_in;
            b_sync_1 <= b_sync_0;

            -- Lógica del contador
            if (b_sync_1 = b_stable) then
                -- Si la entrada es igual a la salida actual, reiniciamos contador
                counter <= 0;
            else
                -- Si hay un cambio, empezamos a contar
                counter <= counter + 1;
                
                -- Si el cambio se mantiene estable durante todo el retardo
                if (counter = DELAY_CYCLES) then
                    b_stable <= b_sync_1;
                    counter <= 0;
                end if;
            end if;
        end if;
    end process;

    -- Asignación a la salida
    b_out <= b_stable;

end rtl;