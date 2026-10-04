# Procesador-Multiciclo
Procesador multiciclo básico que implementa las instrucciones base enteras RV32I


## Procesador RISC-V Multiciclo (RV32I)
Este repositorio documenta el diseño, simulación e implementación en VHDL de un procesador multiciclo de 32 bits basado en la arquitectura RISC-V. Se pretende construir una ruta de datos eficiente y una unidad de control capaces de ejecutar código máquina real.

## Microarquitectura
El diseño emplea una arquitectura multiciclo. Cada instrucción se divide en etapas lógicas secuenciales (Fetch, Decode, Execute, Memory Access y Write-back). Este enfoque minimiza el área requerida de hardware al permitir la reutilización de recursos críticos, como la memoria principal y la Unidad Aritmético Lógica (ALU), durante diferentes ciclos de reloj. utilizaré el siguiente esquema.

<img width="1722" height="890" alt="image" src="https://github.com/user-attachments/assets/dadf7cc0-0441-4e38-b471-3ecf93c0bd60" />

El controlador será una máquina de estados cuyo funcionamiento viene dado por las siguientes tablas.
#### Función de salida
<img width="1852" height="681" alt="image" src="https://github.com/user-attachments/assets/563a9f54-3524-414b-96ed-6c0f7af233be" />

#### Transición de estados
<img width="910" height="1297" alt="Captura de pantalla 2026-10-04 1332900000000" src="https://github.com/user-attachments/assets/2e2d0388-f318-47f7-bf71-35fbe1eabd16" />

El comportamiento de las señales ImmSrc, MemWr y ALUctr viene dado por las siguientes tablas.

<img width="275" height="380" alt="image" src="https://github.com/user-attachments/assets/634bf287-5ef5-4704-9ba1-1d3bd31dbe26" /> 
<img width="381" height="187" alt="image" src="https://github.com/user-attachments/assets/b2398cc4-eff7-4e0f-895b-00eaeb76f516" />
<img width="472" height="915" alt="image" src="https://github.com/user-attachments/assets/03d81234-119f-4469-9e21-ec5332bdb920" />

las señales LoadSize y LoadUnsigned vienen dadas directamente por func3, siendo que LoadUnsigned toma el bit 2 de func3 y LoadSize toma los bits 1 y 0 de func3



## Instrucciones Implementadas (ISA)
El procesador implementa el conjunto de instrucciones base enteras RV32I. Se ha incluido soporte completo para operaciones de memoria a nivel de byte y halfword, así como direccionamiento relativo al Program Counter.
Las operaciones añadidas son:
#### Aritmético-Lógicas (Reg-Reg): 	add, sub, and, or, xor, sll, srl, sra, slt, sltu
#### Aritmético-Lógicas con inmediatos (Reg-Imm)	addi, andi, ori, xori, slli, srli, srai, slti, sltiu
#### Acceso a Memoria (Load/Save)	lw, sw, lb, lh, lbu, lhu, sb, sh
#### Saltos Condicionales (Branches)	beq, bne, blt, bge, bltu, bgeu
#### Saltos Incondicionales (Jumps)	jal, jalr
#### Inmediatos Superiores	lui, auipc

## Sobre el proyecto
Este proyecto se ha desarrollado en VHDL usando IDE Vivado y esta diseñado para la tarjeta FPGA Basys3. En este repositorio se incluye la carpeta srcs que crea por defecto Vivado al empezar un proyecto con todos los archivos .vhd de las distintos módulos diseñados, así como sus respectivos testbench para simulación. 

### Cómo empezar
Para usar los archivos en un proyecto nuevo, basta con descargar la carpeta proc_multiciclo.srcs. Durante la creación del proyecto en Vivado (en el paso 3 de añadir fuentes), haz clic en "Add Directories" y selecciona la carpeta descargada para importar automáticamente todos los módulos y simulaciones
