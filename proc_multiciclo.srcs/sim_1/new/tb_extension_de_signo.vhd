----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.09.2026 18:39:25
-- Design Name: 
-- Module Name: tb_extension_de_signo - beh
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
use IEEE.NUMERIC_STD.ALL;

entity tb_extension_de_signo is
end tb_extension_de_signo;

architecture beh of tb_extension_de_signo is

    component extension_de_signo
       Port (  
          instr   : IN  STD_LOGIC_VECTOR(31 downto 0);
          ImmSrc  : IN  STD_LOGIC_VECTOR(2 downto 0);
          imm     : OUT STD_LOGIC_VECTOR(31 downto 0)
       );
    end component;

    -- inputs
    signal instr  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ImmSrc : STD_LOGIC_VECTOR(2 downto 0)  := (others => '0');
    -- outputs
    signal imm    : STD_LOGIC_VECTOR(31 downto 0);

begin

    dut : extension_de_signo port map (
       instr  => instr,
       ImmSrc => ImmSrc,
       imm    => imm
    );

    p_stim : process
    begin
       -- =============
       -- TIPO I (000)
       -- =============
       ImmSrc <= "000";
       
       -- Inmediato Positivo 0x012
       -- instr(31:20) = 0x012 -> imm debe ser x"00000012"
       instr <= x"01200000"; 
       wait for 50 ns;
       
       -- Inmediato Negativo 0xFFB
       -- instr(31:20) = 0xFFB -> imm debe ser x"FFFFFFFB"
       instr <= x"FFB00000"; 
       wait for 50 ns;

       -- =============
       -- TIPO S (001)
       -- =============
       ImmSrc <= "001";
       
       -- Inmediato Positivo 0x34
       -- instr(31:25) = 0x00, instr(11:7) = 0x14 -> imm_tb debe ser x"00000034"
       instr <= x"02000A00"; 
       wait for 50 ns;
       
       -- Inmediato Negativo 0xFF0
       -- instr(31:25) = 0x7F, instr(11:7) = 0x10 -> imm_tb debe ser x"FFFFFFF0"
       instr <= x"FE000800"; 
       wait for 50 ns;

       -- =============
       -- TIPO B (010)
       -- =============
       ImmSrc <= "010";
       
       -- 0x4
       -- x"00000008"
       instr <= x"00000400"; 
       wait for 50 ns;
       
       -- Branch offset negativo
       -- x"FFFFF7FC"
       instr <= x"FE000E00"; 
       wait for 50 ns;

       -- ============
       -- TIPO U (011)
       -- ============
       ImmSrc <= "011";
       
       -- Cargar 0x12345 en la parte alta
       -- instr(31:12) = 0x12345 -> imm_tb debe ser x"12345000"
       instr <= x"12345111"; 
       wait for 50 ns;
       
       -- Cargar negativo en parte alta
       instr <= x"F000000A"; -- imm_tb debe ser x"F0000000"
       wait for 50 ns;

       -- ============
       -- TIPO J (100)
       -- ============
       ImmSrc <= "100";
       
       -- x"000008FE"
       instr <= x"0FF00000"; 
       wait for 50 ns;
       
       wait;
    end process;

end beh;