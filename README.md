# Procesador-Multiciclo
Procesador multiciclo básico que implementa las instrucciones base enteras RV32I


## Procesador RISC-V Multiciclo (RV32I)
Este repositorio documenta el diseño, simulación e implementación en VHDL de un procesador multiciclo de 32 bits basado en la arquitectura RISC-V. Se pretende construir una ruta de datos eficiente y una unidad de control capaces de ejecutar código máquina real.

## Microarquitectura
El diseño emplea una arquitectura multiciclo. Cada instrucción se divide en etapas lógicas secuenciales (Fetch, Decode, Execute, Memory Access y Write-back). Este enfoque minimiza el área requerida de hardware al permitir la reutilización de recursos críticos, como la memoria principal y la Unidad Aritmético Lógica (ALU), durante diferentes ciclos de reloj. utilizaré el siguiente esquema.

<img width="1401" height="786" alt="image" src="https://github.com/user-attachments/assets/a969e57e-6e17-446b-bdda-8d6d809f142d" />


## Instrucciones Implementadas (ISA)
El procesador implementa el conjunto de instrucciones base enteras RV32I. Se ha incluido soporte completo para operaciones de memoria a nivel de byte y halfword, así como direccionamiento relativo al Program Counter.
Las operaciones añadidas son:
#### Aritmético-Lógicas (Reg-Reg): 	add, sub, and, or, xor, sll, srl, sra, slt, sltu
#### Aritmético-Lógicas con inmediatos (Reg-Imm)	addi, andi, ori, xori, slli, srli, srai, slti, sltiu
#### Acceso a Memoria (Load/Save)	lw, sw, lb, lh, lbu, lhu, sb, sh
#### Saltos Condicionales (Branches)	beq, bne, blt, bge, bltu, bgeu
#### Saltos Incondicionales (Jumps)	jal, jalr
#### Inmediatos Superiores	lui, auipc
