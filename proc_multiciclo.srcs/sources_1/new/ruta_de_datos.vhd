----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05.10.2026 22:24:49
-- Design Name: 
-- Module Name: ruta_de_datos - rtl
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


entity ruta_de_datos is
   Port ( 
      clk          : in  STD_LOGIC;
      rst          : in  STD_LOGIC;
      debug_enable : in  STD_LOGIC;
      debug_next   : in  STD_LOGIC;
      
      act_state    : out STD_LOGIC_VECTOR (4 downto 0);
      ALUoutput    : out STD_LOGIC_VECTOR (31 downto 0)
   );
end ruta_de_datos;

architecture rtl of ruta_de_datos is

   component unidad_de_control
      Port ( 
         clk : IN STD_LOGIC;
         rst : IN STD_LOGIC;
         enable : IN STD_LOGIC;
         op : IN STD_LOGIC_VECTOR (6 downto 0);
         func3 : IN STD_LOGIC_VECTOR (2 downto 0);
         func7 : In STD_LOGIC;
         zero : IN STD_LOGIC;
         sign : IN STD_LOGIC;
         overflow : IN STD_LOGIC;
         carry : IN STD_LOGIC;
         control : OUT STD_LOGIC_VECTOR (28 downto 0);
         debug_state : OUT STD_LOGIC_VECTOR (4 downto 0)
      );
   end component; 

   component ALU_32b
      Port ( 
         A : IN STD_LOGIC_VECTOR (31 downto 0);
         B : IN STD_LOGIC_VECTOR (31 downto 0);
         ALUctr : IN STD_LOGIC_VECTOR (3 downto 0);
         R : OUT STD_LOGIC_VECTOR (31 downto 0);
         zero : OUT STD_LOGIC;
         sign : OUT STD_LOGIC;
         carry : OUT STD_LOGIC;
         overflow : OUT STD_LOGIC
      );
   end component;

   component banco_de_registros
      Port ( 
         clk : IN STD_LOGIC;
         rst : IN STD_LOGIC;
         WE : IN STD_LOGIC;
         RA1 : IN STD_LOGIC_VECTOR (4 downto 0);
         RA2 : IN STD_LOGIC_VECTOR (4 downto 0);
         WA : IN STD_LOGIC_VECTOR (4 downto 0);
         WD : IN STD_LOGIC_VECTOR (31 downto 0);
         RD1 : OUT STD_LOGIC_VECTOR (31 downto 0);
         RD2 : OUT STD_LOGIC_VECTOR (31 downto 0)
      );
   end component; 

   component registro_32b
      Port(
         rst : IN STD_LOGIC;
         clk : IN STD_LOGIC;
         enable : IN STD_LOGIC;
         input : IN STD_LOGIC_VECTOR(31 downto 0);
         output : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
   end component; 

   component mux2a1
      Port (
         sel : IN STD_LOGiC; 
         input0 : IN STD_LOGIC_VECTOR(31 downto 0);
         input1 : IN STD_LOGIC_VECTOR(31 downto 0);
         output : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
   end component; 

   component mux4a1
      Port (
         sel : IN STD_LOGIC_VECTOR(1 downto 0); 
         input0 : IN STD_LOGIC_VECTOR(31 downto 0);
         input1 : IN STD_LOGIC_VECTOR(31 downto 0);
         input2 : IN STD_LOGIC_VECTOR(31 downto 0);
         input3 : IN STD_LOGIC_VECTOR(31 downto 0);
         output : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
   end component; 

   component extension_de_signo
      Port ( 
         instr   : IN  STD_LOGIC_VECTOR(31 downto 0);
         ImmSrc  : IN  STD_LOGIC_VECTOR(2 downto 0);
         imm : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
   end component; 

   component MDE
      Port ( 
         mem_in       : IN  STD_LOGIC_VECTOR(31 downto 0);
         LoadSize     : IN  STD_LOGIC_VECTOR(1 downto 0);
         LoadUnsigned : IN  STD_LOGIC;
         Offset       : IN  STD_LOGIC_VECTOR(1 downto 0);  
         data_out     : OUT STD_LOGIC_VECTOR(31 downto 0)
      );
   end component; 

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

   component blk_mem_gen_0
      PORT (
         clka : IN STD_LOGIC;
         ena : IN STD_LOGIC;
         wea : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
         addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
         dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
         douta : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
   end component;
   
   -- Reloj del sistema
   signal debug_step  : STD_LOGIC;
   signal clk_sys     : STD_LOGIC;

   -- Señales de Control
   signal control_bus : STD_LOGIC_VECTOR(28 downto 0);
   alias PCwr         : std_logic is control_bus(0);
   alias AddrSrc      : std_logic is control_bus(1);
   alias MemWr        : std_logic_vector(3 downto 0) is control_bus(5 downto 2);
   alias LoadSize     : std_logic_vector(1 downto 0) is control_bus(7 downto 6);
   alias LoadUnsigned : std_logic is control_bus(8);
   alias MDRwr        : std_logic is control_bus(9);
   alias OldPCwr      : std_logic is control_bus(10);
   alias IRwr         : std_logic is control_bus(11);
   alias BRwr         : std_logic is control_bus(12);
   alias ImmSrc       : std_logic_vector(2 downto 0) is control_bus(15 downto 13);
   alias Awr          : std_logic is control_bus(16);
   alias Bwr          : std_logic is control_bus(17);
   alias ALUSrcA      : std_logic_vector(1 downto 0) is control_bus(19 downto 18);
   alias ALUSrcB      : std_logic_vector(1 downto 0) is control_bus(21 downto 20);
   alias ALUctr       : std_logic_vector(3 downto 0) is control_bus(25 downto 22);
   alias ALUoutwr     : std_logic is control_bus(26);
   alias ResSrc       : std_logic_vector(1 downto 0) is control_bus(28 downto 27);

   -- Señales de la Ruta de Datos
   signal PC_out, OldPC_out     : STD_LOGIC_VECTOR(31 downto 0);
   signal MemAddr, MemDataOut   : STD_LOGIC_VECTOR(31 downto 0);
   signal IR_out, MDR_out       : STD_LOGIC_VECTOR(31 downto 0);
   signal RD1, RD2              : STD_LOGIC_VECTOR(31 downto 0);
   signal A_out, B_out          : STD_LOGIC_VECTOR(31 downto 0);
   signal Imm_ext               : STD_LOGIC_VECTOR(31 downto 0);
   signal SrcA, SrcB            : STD_LOGIC_VECTOR(31 downto 0);
   signal ALU_res, ALUout_out   : STD_LOGIC_VECTOR(31 downto 0);
   signal Result                : STD_LOGIC_VECTOR(31 downto 0);
   signal MDE_out               : STD_LOGIC_VECTOR(31 downto 0);
   signal debug_step_reg   : STD_LOGIC := '0';
   signal debug_step_pulse : STD_LOGIC;
   signal sys_en           : STD_LOGIC;
   signal MemDataIn_aligned: STD_LOGIC_VECTOR(31 downto 0);
   signal MemWr_aligned    : STD_LOGIC_VECTOR(3 downto 0);
   
   -- Señales de habilitación condicionadas por sys_en
   signal BRwr_en     : STD_LOGIC;
   signal PCwr_en     : STD_LOGIC;
   signal OldPCwr_en  : STD_LOGIC;
   signal IRwr_en     : STD_LOGIC;
   signal MDRwr_en    : STD_LOGIC;
   signal Awr_en      : STD_LOGIC;
   signal Bwr_en      : STD_LOGIC;
   signal ALUoutwr_en : STD_LOGIC;
    
   -- Flags de la ALU
   signal alu_zero, alu_sign, alu_carry, alu_overflow : STD_LOGIC;
   
begin
   db : debouncer
   port map(
      clk => clk,
      b_in => debug_next,
      b_out => debug_step
   );
    
   --elección del reloj del datapath
   process(clk)
   begin
      if rising_edge(clk) then
         debug_step_reg <= debug_step;
      end if;
   end process;
   debug_step_pulse <= debug_step and (not debug_step_reg);
   sys_en <= debug_step_pulse when debug_enable = '1' else '1';  
   
   -- Habilitadores combinados con el pulso del sistema
   BRwr_en     <= BRwr and sys_en;
   PCwr_en     <= PCwr and sys_en;
   OldPCwr_en  <= OldPCwr and sys_en;
   IRwr_en     <= IRwr and sys_en;
   MDRwr_en    <= MDRwr and sys_en;
   Awr_en      <= Awr and sys_en;
   Bwr_en      <= Bwr and sys_en;
   ALUoutwr_en <= ALUoutwr and sys_en; 
   
   -- salida directa
   ALUoutput <= ALUout_out;
   
   -- controlador
   uc : unidad_de_control
   port map(
      clk         => clk,
      rst         => rst,
      enable      => sys_en,
      op          => IR_out(6 downto 0),
      func3       => IR_out(14 downto 12),
      func7       => IR_out(30),
      zero        => alu_zero,
      sign        => alu_sign,
      overflow    => alu_overflow,
      carry       => alu_carry,
      control     => control_bus,
      debug_state => act_state
   );
   
   -- selecciona la dirección de memoria
   PCmux : mux2a1 
   port map (
      sel    => AddrSrc,
      input0 => PC_out,
      input1 => ALUout_out,
      output => MemAddr
   );
    
    
   MemDataIn_aligned <= std_logic_vector(shift_left(unsigned(B_out), to_integer(unsigned(MemAddr(1 downto 0))) * 8));
   MemWr_aligned     <= std_logic_vector(shift_left(unsigned(MemWr), to_integer(unsigned(MemAddr(1 downto 0)))));
   -- memoria
   mem : blk_mem_gen_0 
   port map (
      clka  => clk,
      ena   => sys_en,
      wea   => MemWr_aligned,
      addra => MemAddr(9 downto 2), -- Alineación a palabras de 32 bits
      dina  => MemDataIn_aligned,
      douta => MemDataOut
   );
   
   -- Extensión de Datos de Memoria para Lb, Lh, Lw
   memde : MDE port map (
      mem_in       => MemDataOut,
      LoadSize     => LoadSize,
      LoadUnsigned => LoadUnsigned,
      Offset       => MemAddr(1 downto 0),
      data_out     => MDE_out
   );
   
   -- Banco de 32 registros x 32 bits
   br : banco_de_registros port map (
      clk => clk,
      rst => rst,
      WE  => BRwr_en,
      RA1 => IR_out(19 downto 15),
      RA2 => IR_out(24 downto 20),
      WA  => IR_out(11 downto 7),
      WD  => Result,
      RD1 => RD1,
      RD2 => RD2
   );
   
   -- Decodificación y extensión de inmediatos
   ext_signo : extension_de_signo port map (
      instr  => IR_out,
      ImmSrc => ImmSrc,
      imm    => Imm_ext
   );
 
   -- registros
   reg_PC : registro_32b port map (
      rst => rst, 
      clk => clk, 
      enable => PCwr_en,
      input => ALU_res, 
      output => PC_out
   );

   reg_OldPC : registro_32b port map (
      rst => rst, 
      clk => clk, 
      enable => OldPCwr_en, 
      input => PC_out, 
      output => OldPC_out
   );

   reg_IR : registro_32b port map (
      rst => rst, 
      clk => clk, 
      enable => IRwr_en, 
      input => MemDataOut, 
      output => IR_out
   );

   reg_MDR : registro_32b port map (
      rst => rst, 
      clk => clk, 
      enable => MDRwr_en, 
      input => MDE_out, 
      output => MDR_out
   );

   reg_A : registro_32b port map (
      rst => rst, 
      clk => clk, 
      enable => Awr_en, 
      input => RD1, 
      output => A_out
   );

   reg_B : registro_32b port map (
      rst => rst, 
      clk => clk, 
      enable => Bwr_en, 
      input => RD2, 
      output => B_out
   );

   reg_ALUout : registro_32b port map (
      rst => rst, 
      clk => clk, 
      enable => ALUoutwr_en, 
      input => ALU_res, 
      output => ALUout_out
   ); 
   
   -- ENTORNO DE LA ALU
   -- Selector del operando A
   Amux : mux4a1 port map (
      sel => ALUSrcA,
      input0 => PC_out,
      input1 => A_out,
      input2 => OldPC_out,
      input3 => x"00000000", -- Constante 0 inyectada para instrucción LUI
      output => SrcA
   );

   -- Selector del operando B
   Bmux : mux4a1 port map (
      sel => ALUSrcB,
      input0 => B_out,
      input1 => Imm_ext,
      input2 => x"00000004", -- Constante 4 para suma a PC
      input3 => x"00000000",
      output => SrcB
   );

   -- ALU principal de 32 bits[cite: 21]
   alu_inst : ALU_32b port map (
      A => SrcA,
      B => SrcB,
      ALUctr => ALUctr,
      R => ALU_res,
      zero => alu_zero,
      sign => alu_sign,
      carry => alu_carry,
      overflow => alu_overflow
   );

   -- Selector del resultado final a escribir en registro (ResMux)[cite: 18]
   ALUmux : mux4a1 port map (
      sel => ResSrc,
      input0 => ALUout_out,
      input1 => MDR_out,
      input2 => x"00000000",
      input3 => x"00000000",
      output => Result
   );
   
 
end rtl;
