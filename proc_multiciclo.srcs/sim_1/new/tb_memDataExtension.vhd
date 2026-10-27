----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2026 19:59:21
-- Design Name: 
-- Module Name: tb_memDataExtension - beh
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

entity tb_MDE is
end tb_MDE;

architecture beh of tb_MDE is

    component MDE
       Port ( 
          mem_in       : IN  STD_LOGIC_VECTOR(31 downto 0);
          LoadSize     : IN  STD_LOGIC_VECTOR(1 downto 0);
          LoadUnsigned : IN  STD_LOGIC;
          Offset       : IN  STD_LOGIC_VECTOR(1 downto 0); -- Offset añadido
          data_out     : OUT STD_LOGIC_VECTOR(31 downto 0)
       );
    end component;

    -- inputs
    signal mem_in       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal LoadSize     : STD_LOGIC_VECTOR(1 downto 0)  := (others => '0');
    signal LoadUnsigned : STD_LOGIC := '0';
    signal Offset       : STD_LOGIC_VECTOR(1 downto 0)  := "00"; -- Señal de offset
    
    -- outputs
    signal data_out     : STD_LOGIC_VECTOR(31 downto 0);

begin

    dut : MDE port map (
       mem_in       => mem_in,
       LoadSize     => LoadSize,
       LoadUnsigned => LoadUnsigned,
       Offset       => Offset, -- NUEVO: Mapeo de puerto
       data_out     => data_out
    );

    p_stim : process
    begin
       -- ==============
       -- LOAD BYTE (Offset 0)
       -- ==============
       LoadSize <= "00";
       Offset   <= "00";
       
       -- Byte Negativo (0xF0) con extensión de signo
       mem_in <= x"AAAAAAF0"; 
       LoadUnsigned <= '0';
       wait for 50 ns;
       
       -- Byte Negativo (0xF0) sin signo
       LoadUnsigned <= '1';
       wait for 50 ns;
       
       -- Byte Positivo (0x7F) con extensión de signo
       mem_in <= x"AAAAAA7F"; 
       LoadUnsigned <= '0';
       wait for 50 ns; 
       -- y sin extension de signo
       LoadUnsigned <= '1';
       wait for 50 ns;

       -- ==============
       -- LOAD HALFWORD (Offset 0)
       -- ==============
       LoadSize <= "01";
       Offset   <= "00";
       
       -- Halfword Negativo (0x8000) con extensión de signo
       mem_in <= x"AAAA8000"; 
       LoadUnsigned <= '0';
       wait for 50 ns;
       
       -- Halfword Negativo (0x8000) sin signo
       mem_in <= x"AAAA8000"; 
       LoadUnsigned <= '1';
       wait for 50 ns;
       
        -- Halfword Positivo (0x7FFF) con extensión de signo
       mem_in <= x"AAAA7FFF"; 
       LoadUnsigned <= '0';
       wait for 50 ns; 
       -- y sin extension de signo
       LoadUnsigned <= '1';
       wait for 50 ns;

       -- ==============
       -- LOAD WORD (Offset 0)
       -- ==============
       LoadSize <= "10";
       Offset   <= "00";
       
       -- Pasa la palabra completa independientemente del signo
       mem_in <= x"DEADBEEF"; 
       LoadUnsigned <= '0'; 
       wait for 50 ns; 
       
       -- ==============
       -- PRUEBA DE ALINEACIÓN (OFFSET)
       -- ==============
       -- Leer el byte 2 (Bits 23 downto 16) de la memoria
       LoadSize <= "00";
       Offset   <= "10"; -- Apunta al tercer byte
       mem_in   <= x"11F03344"; -- El byte a leer será 0xF0
       LoadUnsigned <= '0'; -- Con extensión de signo (debe salir 0xFFFFFFF0)
       wait for 50 ns;
       
       wait;
    end process;

end beh;