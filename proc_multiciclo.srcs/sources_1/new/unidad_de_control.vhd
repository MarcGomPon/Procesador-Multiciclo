----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.10.2026 20:20:38
-- Design Name: 
-- Module Name: unidad_de_control - rtl
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

entity unidad_de_control is
   Port ( 
      clk : IN STD_LOGIC;
      rst : IN STD_LOGIC;
      
      op : IN STD_LOGIC_VECTOR (6 downto 0);
      func3 : IN STD_LOGIC_VECTOR (2 downto 0);
      func7 : In STD_LOGIC;
      
      zero : IN STD_LOGIC;
      sign : IN STD_LOGIC;
      overflow : IN STD_LOGIC;
      carry : IN STD_LOGIC;
      
      control : OUT STD_LOGIC_VECTOR (28 downto 0);
      debug_state : OUT STD_LOGIC_VECTOR (4 downto 0) -- depuración
   );
end unidad_de_control;

architecture rtl of unidad_de_control is

   signal control_aux : std_logic_vector(28 downto 0);
    
   -- Mapeo de señales al vector de control 
   alias PCwr         : std_logic is control_aux(0);
   alias AddrSrc      : std_logic is control_aux(1);
   alias MemWr        : std_logic_vector(3 downto 0) is control_aux(5 downto 2);
   alias LoadSize     : std_logic_vector(1 downto 0) is control_aux(7 downto 6);
   alias LoadUnsigned : std_logic is control_aux(8);
   alias MDRwr        : std_logic is control_aux(9);
   alias OldPCwr      : std_logic is control_aux(10);
   alias IRwr         : std_logic is control_aux(11);
   alias BRwr         : std_logic is control_aux(12);
   alias ImmSrc       : std_logic_vector(2 downto 0) is control_aux(15 downto 13);
   alias Awr          : std_logic is control_aux(16);
   alias Bwr          : std_logic is control_aux(17);
   alias ALUSrcA      : std_logic_vector(1 downto 0) is control_aux(19 downto 18);
   alias ALUSrcB      : std_logic_vector(1 downto 0) is control_aux(21 downto 20);
   alias ALUctr       : std_logic_vector(3 downto 0) is control_aux(25 downto 22);
   alias ALUoutwr     : std_logic is control_aux(26);
   alias ResSrc       : std_logic_vector(1 downto 0) is control_aux(28 downto 27);

   -- Máquina de estados (17 estados)
    type states is (
        S_FETCH, S_DECODE, 
        S_EX_R, S_EX_I, S_LUI, S_AUIPC,
        S_BRANCH, S_BRANCH_TAKEN, 
        S_JAL_1, S_JAL_2, S_JALR_1, S_JALR_2,
        S_MEM_ADDR, S_MEM_READ, S_MEM_WB, S_MEM_WRITE, S_WB_ALU
    );
    signal currentState, nextState: states;
    
begin

   
   control <= control_aux;

   debug_state <= std_logic_vector(to_unsigned(states'pos(currentState), 5));

    stateGen:
    PROCESS (currentState, Op, func3, func7, zero, sign, carry, overflow)
        variable branch_taken : std_logic;
    BEGIN
        nextState <= currentState;
        control_aux <= (others=>'0');
        branch_taken := '0';
          
        CASE currentState IS
            
            WHEN S_FETCH =>
                AddrSrc <= '0';     -- Selecciona PC para memoria
                IRwr <= '1';        -- Guarda la instrucción
                OldPCwr <= '1';     -- Guarda el PC actual
                -- PC = PC + 4
                ALUSrcA <= "00";    -- Mux A: PC
                ALUSrcB <= "10";    -- Mux B: 4
                ALUctr <= "0000";   -- Suma
                PCwr <= '1';        -- Actualiza PC
                nextState <= S_DECODE;
                
            WHEN S_DECODE =>
                Awr <= '1';         -- Leer RS1
                Bwr <= '1';         -- Leer RS2
                
                -- Decodificación de tipo de instrucción y selector de inmediato
                if (Op = "0110011") then     -- Tipo R
                    nextState <= S_EX_R;
                elsif (Op = "0010011") then  -- Tipo I (Aritmética/Lógica)
                    ImmSrc <= "000";
                    nextState <= S_EX_I;
                elsif (Op = "0000011") then  -- Load (Tipo I)
                    ImmSrc <= "000";
                    nextState <= S_MEM_ADDR;
                elsif (Op = "0100011") then  -- Store (Tipo S)
                    ImmSrc <= "001";
                    nextState <= S_MEM_ADDR;
                elsif (Op = "1100011") then  -- Branch (Tipo B)
                    ImmSrc <= "010";
                    nextState <= S_BRANCH;
                elsif (Op = "0110111") then  -- LUI (Tipo U)
                    ImmSrc <= "011";
                    nextState <= S_LUI;
                elsif (Op = "0010111") then  -- AUIPC (Tipo U)
                    ImmSrc <= "011";
                    nextState <= S_AUIPC;
                elsif (Op = "1101111") then  -- JAL (Tipo J)
                    ImmSrc <= "100";
                    nextState <= S_JAL_1;
                elsif (Op = "1100111") then  -- JALR (Tipo I)
                    ImmSrc <= "000";
                    nextState <= S_JALR_1;
                else
                    nextState <= S_FETCH;    -- volvemos a estado inicial
                end if;

            ---------------------------------
            -- Ejecución Aritmética y Lógica 
            ---------------------------------
            WHEN S_EX_R | S_EX_I =>
                ALUSrcA <= "01"; -- Entrada A de la ALU = Registro A
                
                if (currentState = S_EX_R) then
                    ALUSrcB <= "00"; -- Entrada B = Registro B
                else
                    ALUSrcB <= "01"; -- Entrada B = Inmediato extendido
                end if;
                
                -- Decodificación de la operación de la ALU
                if (func3 = "000") then
                    if (Op = "0110011" and func7 = '1') then 
                        ALUctr <= "0001"; -- SUB
                    else 
                        ALUctr <= "0000"; -- ADD / ADDI
                    end if;
                elsif (func3 = "001") then ALUctr <= "0111"; -- SLL / SLLI
                elsif (func3 = "010") then ALUctr <= "0101"; -- SLT / SLTI
                elsif (func3 = "011") then ALUctr <= "0110"; -- SLTU / SLTIU
                elsif (func3 = "100") then ALUctr <= "0100"; -- XOR / XORI
                elsif (func3 = "101") then
                    if (func7 = '1') then 
                        ALUctr <= "1001"; -- SRA / SRAI
                    else 
                        ALUctr <= "1000"; -- SRL / SRLI
                    end if;
                elsif (func3 = "110") then ALUctr <= "0011"; -- OR / ORI
                elsif (func3 = "111") then ALUctr <= "0010"; -- AND / ANDI
                end if;
                
                ALUoutwr <= '1';
                nextState <= S_WB_ALU;

            ----------------
            -- LUI y AUIPC
            ---------------
            WHEN S_LUI =>
                ALUSrcA <= "11";  -- Constante 0 inyectada al Mux
                ALUSrcB <= "01";  -- Inmediato
                ALUctr <= "0000"; -- Suma (0 + Imm = Imm)
                ALUoutwr <= '1';
                nextState <= S_WB_ALU;

            WHEN S_AUIPC =>
                ALUSrcA <= "10";  -- OldPC
                ALUSrcB <= "01";  -- Inmediato
                ALUctr <= "0000"; -- Suma
                ALUoutwr <= '1';
                nextState <= S_WB_ALU;

            ------------------------
            -- Saltos Condicionales
            -------------------------
            WHEN S_BRANCH =>
                ALUSrcA <= "01";  -- Registro A
                ALUSrcB <= "00";  -- Registro B
                ALUctr <= "0001"; -- Resta para setear flags
                
                -- Evaluación de condición
                if (func3 = "000" and zero = '1') then branch_taken := '1';                   -- BEQ
                elsif (func3 = "001" and zero = '0') then branch_taken := '1';                -- BNE
                elsif (func3 = "100" and (sign xor overflow) = '1') then branch_taken := '1'; -- BLT
                elsif (func3 = "101" and (sign xor overflow) = '0') then branch_taken := '1'; -- BGE
                elsif (func3 = "110" and carry = '1') then branch_taken := '1';               -- BLTU
                elsif (func3 = "111" and carry = '0') then branch_taken := '1';               -- BGEU
                end if;

                if (branch_taken = '1') then
                    nextState <= S_BRANCH_TAKEN;
                else
                    nextState <= S_FETCH;
                end if;

            WHEN S_BRANCH_TAKEN =>
                ALUSrcA <= "10";  -- OldPC
                ALUSrcB <= "01";  -- Inmediato B
                ALUctr <= "0000"; -- Suma del target
                PCwr <= '1';
                nextState <= S_FETCH;

            -------------------------
            -- Saltos Incondicionales 
            -------------------------
            WHEN S_JAL_1 =>
                ALUSrcA <= "10";  -- OldPC
                ALUSrcB <= "01";  -- Inmediato
                ALUctr <= "0000"; -- Suma
                PCwr <= '1';
                nextState <= S_JAL_2;
                
            WHEN S_JAL_2 =>
                ALUSrcA <= "10";  -- OldPC
                ALUSrcB <= "10";  -- 4
                ALUctr <= "0000"; -- Suma
                ALUoutwr <= '1';
                nextState <= S_WB_ALU;

            WHEN S_JALR_1 =>
                ALUSrcA <= "01";  -- Registro A
                ALUSrcB <= "01";  -- Inmediato
                ALUctr <= "0000"; -- Suma
                PCwr <= '1';
                nextState <= S_JALR_2;
                
            WHEN S_JALR_2 =>
                ALUSrcA <= "10";  -- OldPC
                ALUSrcB <= "10";  -- 4
                ALUctr <= "0000"; -- Suma
                ALUoutwr <= '1';
                nextState <= S_WB_ALU;

            -----------
            -- Memoria
            -----------
            WHEN S_MEM_ADDR =>
                ALUSrcA <= "01";  -- Registro A
                ALUSrcB <= "01";  -- Inmediato
                ALUctr <= "0000"; -- Suma de dirección
                ALUoutwr <= '1';
                
                if (Op = "0000011") then 
                    nextState <= S_MEM_READ;
                else 
                    nextState <= S_MEM_WRITE; 
                end if;

            WHEN S_MEM_READ =>
                AddrSrc <= '1';   -- Dirección desde ALUout
                MDRwr <= '1';     -- Escribir en MDR
                LoadSize <= func3(1 downto 0); -- Controla byte/half/word
                LoadUnsigned <= func3(2);      -- Controla extensión
                nextState <= S_MEM_WB;

            WHEN S_MEM_WRITE =>
                AddrSrc <= '1';   -- Dirección desde ALUout
                
                -- Control del byte-enable basado en la instrucción a través de func3
                if (func3 = "000") then 
                    MemWr <= "0001"; -- sb
                elsif (func3 = "001") then 
                    MemWr <= "0011"; -- sh
                elsif (func3 = "010") then 
                    MemWr <= "1111"; -- sw
                else 
                    MemWr <= "0000";
                end if;
                
                nextState <= S_FETCH;

            -------------------------
             -- Estados de Write-Back
            --------------------------
            WHEN S_MEM_WB =>
                ResSrc <= "01";   -- Dato desde Memoria (MDR)
                BRwr <= '1';      -- Escribir en banco de registros
                nextState <= S_FETCH;

            WHEN S_WB_ALU =>
                ResSrc <= "00";   -- Dato desde la ALU (ALUout)
                BRwr <= '1';      -- Escribir en banco de registros
                nextState <= S_FETCH;

            WHEN OTHERS =>
                nextState <= S_FETCH;
                
        END CASE;
    END PROCESS stateGen;
   
   state:
   process(clk, rst)
   begin
      if (rst = '1') then currentState <= S_FETCH;
      elsif rising_edge(clk) then currentState <= nextState;
      end if;
   end process state;
end rtl;
