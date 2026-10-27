# Procesador RISC-V Multiciclo (RV32I) en SoC

Este repositorio documenta el diseño, simulación e implementación en VHDL de un procesador multiciclo de 32 bits basado en la arquitectura RISC-V. El objetivo del proyecto es construir una ruta de datos eficiente, una unidad de control robusta y una arquitectura SoC completa para su síntesis directa en la tarjeta FPGA Basys3 (Artix-7).

## Microarquitectura

El diseño emplea una arquitectura multiciclo donde cada instrucción se divide en etapas lógicas secuenciales (Fetch, Decode, Execute, Memory Access y Write-back). Este enfoque minimiza el área de hardware requerida al permitir la reutilización de recursos críticos, como la memoria principal y la Unidad Aritmético Lógica (ALU), durante diferentes ciclos de reloj.

### Arquitectura Jerárquica SoC
Para garantizar un diseño escalable, el sistema está estructurado en dos niveles lógicos:

**Core:** El módulo `ruta_de_datos.vhd` es un procesador puro. No contiene lógica de interacción física, operando exclusivamente mediante una señal limpia de `enable`.

**`union.vhd`:** Actúa como la placa base del SoC. Se encarga de instanciar el procesador, limpiar el ruido físico de los pulsadores mediante un filtro antirrebotes (`debouncer`) de 10 ms, y extraer los datos de la ALU para inyectarlos en el controlador de los periféricos de salida.

El esquema de la ruta de datos es el siguiente:

<img width="1722" height="890" alt="Ruta de datos" src="https://github.com/user-attachments/assets/dadf7cc0-0441-4e38-b471-3ecf93c0bd60" />

### Unidad de Control (FSM)
El controlador es una máquina de estados finitos (FSM) que orquesta la ejecución. Su comportamiento se define mediante las siguientes tablas de transición y salida:

**Función de salida:**
<img width="1852" height="681" alt="Función de salida" src="https://github.com/user-attachments/assets/563a9f54-3524-414b-96ed-6c0f7af233be" />

**Transición de estados:**
<img width="910" height="1297" alt="Transición de estados" src="https://github.com/user-attachments/assets/2e2d0388-f318-47f7-bf71-35fbe1eabd16" />

El comportamiento de las señales de control de la ALU y accesos a memoria se gestiona de la siguiente forma:

<img width="275" height="380" alt="Control 1" src="https://github.com/user-attachments/assets/634bf287-5ef5-4704-9ba1-1d3bd31dbe26" /> 
<img width="381" height="187" alt="Control 2" src="https://github.com/user-attachments/assets/b2398cc4-eff7-4e0f-895b-00eaeb76f516" />
<img width="472" height="915" alt="Control 3" src="https://github.com/user-attachments/assets/03d81234-119f-4469-9e21-ec5332bdb920" />

*Nota: Las señales `LoadSize` y `LoadUnsigned` se derivan directamente del campo `func3` de la instrucción (el bit 2 define el signo y los bits 1-0 definen el tamaño).*

## Decisiones de Diseño Destacadas
* **Diseño Síncrono:** Se ha evitado el uso de clock gating, implementando en su lugar un control mediante señales de habilitación (`enable`) síncronas para garantizar una síntesis segura en FPGA al implemetar el modo debug.
* **Extensión de Datos de Memoria (MDE):** Para soportar los accesos a memoria parciales, se diseñó un módulo MDE personalizado que gestiona la alineación y el manejo de los Offsets de forma transparente a la ruta principal.
* **Interfaz Visual Multiplexada:** El SoC incluye un controlador VHDL (`display_7seg`) que actúa como divisor de frecuencia, utilizando un contador de 20 bits, para refrescar los 4 displays de 7 segmentos de la Basys3 a ~95 Hz. Esto permite visualizar el resultado hexadecimal de la ALU en tiempo real sin parpadeos perceptibles.

## Instrucciones Implementadas (ISA)

El procesador implementa 37 de las 40 instrucciones del conjunto base entero RV32I, incluyendo soporte completo para operaciones de memoria a nivel de byte y halfword, y direccionamiento relativo al PC.

* **Aritmético-Lógicas (Reg-Reg):** `add`, `sub`, `and`, `or`, `xor`, `sll`, `srl`, `sra`, `slt`, `sltu`
* **Aritmético-Lógicas (Reg-Imm):** `addi`, `andi`, `ori`, `xori`, `slli`, `srli`, `srai`, `slti`, `sltiu`
* **Acceso a Memoria (Load/Store):** `lw`, `sw`, `lb`, `lh`, `lbu`, `lhu`, `sb`, `sh`
* **Saltos Condicionales (Branches):** `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
* **Saltos Incondicionales (Jumps):** `jal`, `jalr`
* **Inmediatos Superiores:** `lui`, `auipc`

*Limitaciones: No se implementan las instrucciones de sistema (`ecall`, `ebreak`, `fence`). Al no contar con un gestor de excepciones, las direcciones desalineadas en memoria pueden generar datos corruptos.*

## Simulación y Verificación

El diseño ha sido verificado funcionalmente mediante testbenches en Vivado utilizando un programa de prueba en código máquina. En la siguiente captura se observa la correcta extracción, decodificación y ejecución ininterrumpida de instrucciones con inmediatos (Tipos U e I) por parte de la FSM y la ruta de datos:

<img width="1887" height="1023" alt="image" src="https://github.com/user-attachments/assets/46890b3b-998c-4583-bac9-fef90aa819d0" />

**Detalle de ejecución temporal (300 ns - 650 ns):** 
Captura de la simulación en Vivado mostrando la decodificación y ejecución secuencial de dos instrucciones sin bloqueos: `auipc x2, 0` (00000117) y `addi x3, x0, 15` (00f00193). 

Se observa la correcta sincronización de la Unidad de Control orquestando la ruta de datos:
1. **Transición de la FSM:** Se aprecian los saltos condicionales de la máquina de estados según el tipo de instrucción, pasando por el estado `05` para ejecutar la instrucción tipo U, y por el estado `03` para la instrucción tipo I, finalizando ambas en el estado de Write-back (`10`).
2. **Cálculo en la ALU:** En la etapa de ejecución de la suma inmediata (`addi`), el multiplexor enruta correctamente el operando `SrcA` (00000000) y el inmediato `SrcB` (0000000f), resolviendo el cálculo en `ALU_res` de forma síncrona.

## Reproducción del Proyecto

Este proyecto ha sido desarrollado en VHDL usando el IDE Vivado (configurado para IP cores en modo *Mixed language*). 

Opción recomendada (vía script TCL para control de versiones):
1. Clona este repositorio.
2. Abre la consola de comandos de Vivado (Tcl Console).
3. Navega hasta el directorio raíz del repositorio clonado.
4. Ejecuta el script de regeneración mediante el comando:
   `source recrear_proyecto.tcl`
5. Vivado reconstruirá automáticamente la jerarquía del proyecto, enlazará las fuentes VHDL, el banco de pruebas (simulación) y el archivo de restricciones físicas (`Basys3_Master.xdc`), dejándolo listo para síntesis, implementación y generación de *Bitstream*.

Opción alternativa:
1. Descarga el repositorio.
2. Crea un proyecto nuevo en Vivado apuntando a la familia Artix-7 (FPGA Basys3).
3. En el paso de añadir fuentes, selecciona "Add Directories" e importa la carpeta `proc_multiciclo.srcs`.
4. Vivado detectará automáticamente las fuentes de diseño (`sources_1`) y los bancos de pruebas (`sim_1`).


