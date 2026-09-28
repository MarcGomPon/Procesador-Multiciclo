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
          data_out     : OUT STD_LOGIC_VECTOR(31 downto 0)
       );
    end component;

    -- inputs
    signal mem_in       : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal LoadSize     : STD_LOGIC_VECTOR(1 downto 0)  := (others => '0');
    signal LoadUnsigned : STD_LOGIC := '0';
    
    -- outputs
    signal data_out     : STD_LOGIC_VECTOR(31 downto 0);

begin

    dut : MDE port map (
       mem_in       => mem_in,
       LoadSize     => LoadSize,
       LoadUnsigned => LoadUnsigned,
       data_out     => data_out
    );

    p_stim : process
    begin
       -- ==============
       -- LOAD BYTE
       -- ==============
       LoadSize <= "00";
       
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
       -- LOAD HALFWORD 
       -- ==============
       LoadSize <= "01";
       
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
       -- LOAD WORD
       -- ==============
       LoadSize <= "10";
       
       -- Pasa la palabra completa independientemente del signo
       mem_in <= x"DEADBEEF"; 
       LoadUnsigned <= '0'; 
       wait for 50 ns; 
       
       wait;
    end process;

end beh;
