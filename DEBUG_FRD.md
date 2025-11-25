# Debug: Por qué FRD1D y FRD2D están en 0

## Problema
FRD1D y FRD2D se mantienen en `0x00000000` durante toda la simulación.

## Análisis del Flujo

### Para `flw f1, 0(x0)` (00001007):
1. **ID Stage**: Lee `FRD1D` y `FRD2D` (pero aún no hay valores escritos)
2. **EX Stage**: Calcula dirección `0 + 0 = 0`
3. **MEM Stage**: Lee `ReadDataM` desde `memoria[0]` = `0x3F800000` (1.0)
4. **WB Stage**: 
   - `ReadDataW = 0x3F800000`
   - `FResultW = ReadDataW` (porque `ResultSrcW[0] = 1`)
   - `FPRegWriteW = 1` (debería activarse)
   - Escribe `f1 = 0x3F800000`

### Para `fadd.s f3, f1, f2` (00208053):
- **fs1 = f1** (bits [19:15] = 00001)
- **fs2 = f2** (bits [24:20] = 00010)
- **FRD1D** debería leer `f1` (que ya debería tener `0x3F800000`)
- **FRD2D** debería leer `f2` (que debería tener `0x40000000` si `flw f2` ya terminó)

## Señales a Verificar en el Waveform

Agrega estas señales para debug:

### 1. Señales de Control:
- `testbench/dut/rvpipeline/c/FPRegWrite` - ¿Se activa para flw?
- `testbench/dut/rvpipeline/dp/FPRegWriteW` - ¿Se propaga hasta WB?
- `testbench/dut/rvpipeline/dp/ResultSrcW` - ¿Es `01` para flw?

### 2. Señales de Datos:
- `testbench/dut/rvpipeline/dp/ReadDataM` - ¿Tiene valores de memoria?
- `testbench/dut/rvpipeline/dp/ReadDataW` - ¿Se propaga correctamente?
- `testbench/dut/rvpipeline/dp/FResultW` - ¿Selecciona ReadDataW?
- `testbench/dut/rvpipeline/dp/frf/wd3` - ¿Llega al register file?
- `testbench/dut/rvpipeline/dp/frf/we3` - ¿Write enable está activo?

### 3. Register File FP:
- `testbench/dut/rvpipeline/dp/frf/frf[1]` - Contenido de f1
- `testbench/dut/rvpipeline/dp/frf/frf[2]` - Contenido de f2
- `testbench/dut/rvpipeline/dp/frf/a1` - Dirección de lectura fs1
- `testbench/dut/rvpipeline/dp/frf/a2` - Dirección de lectura fs2
- `testbench/dut/rvpipeline/dp/frf/a3` - Dirección de escritura fd

### 4. Instrucciones:
- `testbench/dut/rvpipeline/dp/InstrD` - Instrucción actual en Decode
- `testbench/dut/rvpipeline/dp/RdW` - Registro destino en WB

## Posibles Problemas

1. **FPRegWrite no se activa para flw**: Verificar `controller_fp.v` línea 72
2. **FResultW no selecciona ReadDataW**: Verificar `ResultSrcW[0]` para flw
3. **Register file no escribe**: Verificar `we3` y `wd3` en `fregfile`
4. **Direcciones incorrectas**: Verificar que `RdW` sea correcto para flw
5. **Timing**: Los valores se escriben en WB, pero se leen en ID (mismo ciclo o antes)

## Verificación Paso a Paso

1. **Ciclo donde `flw f1` está en WB**:
   - `RdW` debería ser `5'b00001` (f1)
   - `ReadDataW` debería ser `0x3F800000`
   - `FResultW` debería ser `0x3F800000`
   - `FPRegWriteW` debería ser `1`
   - `fregfile/frf[1]` debería cambiar a `0x3F800000` en el siguiente ciclo

2. **Ciclo siguiente (después de escribir f1)**:
   - Cuando `fadd.s f3, f1, f2` está en ID:
   - `InstrD[19:15]` debería ser `5'b00001` (fs1 = f1)
   - `FRD1D` debería ser `0x3F800000` (valor de f1)

