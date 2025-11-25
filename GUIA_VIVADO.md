# Guía: Cómo Abrir y Ejecutar el Testbench en Vivado

## Opción 1: Usar Script TCL (Recomendado)

### Paso 1: Abrir Vivado
1. Abre **Vivado** desde el menú de inicio
2. En la ventana inicial, selecciona **"Open Project"** o **"Open Example Project"**

### Paso 2: Ejecutar Script de Configuración
1. En la **Tcl Console** (parte inferior de Vivado), ejecuta:
   ```tcl
   cd C:/Users/anyel/OneDrive/Desktop/pipeline
   source setup_vivado.tcl
   ```
   
   O si prefieres usar el script actualizado:
   ```tcl
   source setup_vivado_fp.tcl
   ```

2. El script creará/abrirá el proyecto y agregará todos los archivos necesarios.

### Paso 3: Configurar Simulación
1. En el panel izquierdo, ve a **"Simulation"** → **"Simulation Settings"**
2. Asegúrate de que:
   - **Simulation set**: `sim_1`
   - **Top module**: `testbench` (no `top`)
   - **Target simulator**: `XSim`

### Paso 4: Ejecutar Simulación
1. En el menú superior: **"Run Simulation"** → **"Run Behavioral Simulation"**
   - O usa el atajo: `Ctrl + Alt + B`
   - O haz clic derecho en `testbench` → **"Set as Top"** → **"Run Simulation"**

2. Vivado compilará y ejecutará la simulación automáticamente.

### Paso 5: Ver Resultados
1. **Waveform**: Se abrirá automáticamente con todas las señales
2. **Tcl Console**: Verás mensajes de `$display` del testbench
3. **Agregar señales al waveform**:
   - En el panel **"Scope"**, navega a `testbench` → `dut` → `rvpipeline` → `dp`
   - Arrastra señales al waveform o haz clic derecho → **"Add to Wave Window"**

---

## Opción 2: Crear Proyecto Manualmente

### Paso 1: Crear Nuevo Proyecto
1. **File** → **Project** → **New Project**
2. **Project Name**: `riscv_pipeline`
3. **Project Location**: `C:/VivadoProjects/riscv_pipeline` (fuera de OneDrive)
4. **Project Type**: **RTL Project**
5. **Add Sources**: Agregar todos los archivos `.v`:
   - `top.v`
   - `riscvpipeline.v`
   - `datapath.v`
   - `controller_fp.v` ⚠️ **IMPORTANTE: Usar controller_fp.v, NO controller.v**
   - `hazard_unit.v`
   - `maindec.v`
   - `aludec.v`
   - `fpdec.v` ⚠️ **NUEVO: Decoder FP**
   - `regfile.v`
   - `fregfile.v` ⚠️ **NUEVO: Register file FP**
   - `extend.v`
   - `alu.v`
   - `alu_fp_full.v` ⚠️ **NUEVO: ALU FP**
   - `adder.v`
   - `imem.v`
   - `dmem.v`
   - `flopr.v`
   - `mux2.v`
   - `mux3.v`
   - `mux_df.v`
   - `IF_ID.v`
   - `ID_EX.v`
   - `EX_MEM.v`
   - `MEM_WB.v`

6. **Add Simulation Sources**: Agregar `testbench.v`

7. **Default Part**: Seleccionar cualquier FPGA (ej: `xc7a35tcpg236-1`)

### Paso 2: Configurar Top Module
1. En **Sources**, haz clic derecho en `testbench.v`
2. **Set as Top** (para simulación)

### Paso 3: Verificar Archivos de Memoria
1. Asegúrate de que `riscvtest_fp.txt` esté en el mismo directorio que `imem.v`
2. Verifica que `imem.v` tenga: `$readmemh("riscvtest_fp.txt", RAM);`

### Paso 4: Ejecutar Simulación
1. **Run Simulation** → **Run Behavioral Simulation**
2. Espera a que compile y ejecute

---

## Señales Importantes a Observar

### En el Waveform, agrega estas señales:

**Desde `testbench/dut/rvpipeline/dp`:**
- `PCF` - Contador de programa
- `InstrD` - Instrucción en Decode
- `isFPE` - Señal FP en Execute
- `FALUControlE` - Control ALU FP
- `FRD1E`, `FRD2E` - Operandos FP
- `FALUResultE` - Resultado ALU FP
- `FPRegWriteW` - Escritura en register file FP
- `FResultW` - Resultado final FP

**Desde `testbench/dut/rvpipeline/c`:**
- `isFPD` - Detecta instrucción FP
- `FALUControlD` - Control FP en Decode

**Desde `testbench/dut/rvpipeline/dp/frf`:**
- `frf` - Contenido del register file FP (para ver valores en f0-f31)

---

## Solución de Problemas

### Error: "Cannot find file riscvtest_fp.txt"
- **Solución**: Copia `riscvtest_fp.txt` al directorio donde Vivado ejecuta la simulación
- Generalmente: `C:/VivadoProjects/riscv_pipeline/riscv_pipeline.sim/sim_1/behav/xsim/`
- O modifica `imem.v` para usar ruta absoluta

### Error: "Module controller not found"
- **Solución**: Asegúrate de usar `controller_fp.v`, NO `controller.v`
- El archivo `controller.v` fue eliminado

### Error: "Undefined signal FPMemWriteM"
- **Solución**: Verifica que `top.v` tenga las conexiones FP correctas
- Verifica que `riscvpipeline.v` exporte `FPMemWriteM` y `FWriteDataM`

### La simulación no muestra señales FP
- **Solución**: 
  1. En el waveform, expande `testbench` → `dut` → `rvpipeline` → `dp`
  2. Busca señales que empiecen con `F` (FP)
  3. Arrástralas al waveform

### Cambiar entre pruebas FP y enteras
1. Edita `imem.v`
2. Cambia `$readmemh("riscvtest_fp.txt", RAM);` a `$readmemh("riscvtest.txt", RAM);`
3. Re-ejecuta la simulación

---

## Atajos Útiles

- **Run Simulation**: `Ctrl + Alt + B`
- **Reload Simulation**: `Ctrl + R`
- **Zoom Fit**: `Ctrl + F`
- **Zoom In/Out**: Rueda del mouse
- **Agregar señal al waveform**: Doble clic en la señal

---

## Tiempo de Simulación

El testbench está configurado para:
- **Duración máxima**: 100,000 ns (100 µs)
- **Detención automática**: Después de 500 ciclos
- **Periodo de reloj**: 10 ns (100 MHz)

Para cambiar el tiempo, edita `testbench.v`:
```verilog
# 100000;  // Cambiar este valor
```

