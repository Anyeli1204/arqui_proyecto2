# Valores Esperados de FRD1 y FRD2

## ¿Qué son FRD1 y FRD2?

- **FRD1**: Valor leído del registro FP `fs1` (InstrD[19:15])
- **FRD2**: Valor leído del registro FP `fs2` (InstrD[24:20])
- Vienen del **fregfile** (register file de punto flotante)

## Valores Iniciales

Todos los registros FP se inicializan en **`0x00000000`** (que es **+0.0** en IEEE-754).

## Análisis de las Instrucciones

### Instrucción 1: `flw f1, 0(x0)` (00001007)
- **Acción**: Carga valor desde `memoria[0]` a `f1`
- **FRD1**: No se usa (no es operación aritmética)
- **FRD2**: No se usa
- **Resultado esperado**: `f1 = memoria[0]` (probablemente `0x00000000` si la memoria está en 0)

### Instrucción 2: `flw f2, 4(x0)` (00002007)
- **Acción**: Carga valor desde `memoria[4]` a `f2`
- **FRD1**: No se usa
- **FRD2**: No se usa
- **Resultado esperado**: `f2 = memoria[4]` (probablemente `0x00000000`)

### Instrucción 3: `fadd.s f3, f1, f2` (00208053)
- **Decodificación**: 
  - `fs1 = f1` (bits [19:15] = 00001)
  - `fs2 = f2` (bits [24:20] = 00010)
  - `fd = f3` (bits [11:7] = 00011)
- **FRD1**: Valor de `f1` (lo que se cargó con `flw f1`)
- **FRD2**: Valor de `f2` (lo que se cargó con `flw f2`)
- **Valores esperados**:
  - Si la memoria está inicializada en 0: `FRD1 = 0x00000000`, `FRD2 = 0x00000000`
  - Resultado: `f3 = 0.0 + 0.0 = 0.0` → `0x00000000`

### Instrucción 4: `fsub.s f4, f3, f1` (00118053)
- **Decodificación**:
  - `fs1 = f3` (bits [19:15] = 00011)
  - `fs2 = f1` (bits [24:20] = 00001)
  - `fd = f4` (bits [11:7] = 00100)
- **FRD1**: Valor de `f3` (resultado de `fadd.s`)
- **FRD2**: Valor de `f1`
- **Valores esperados**:
  - `FRD1 = 0x00000000` (valor de f3)
  - `FRD2 = 0x00000000` (valor de f1)
  - Resultado: `f4 = 0.0 - 0.0 = 0.0` → `0x00000000`

## Problema Actual

**La memoria de datos (`dmem`) está inicializada en 0**, por lo que:
- `flw f1, 0(x0)` carga `0x00000000` en `f1`
- `flw f2, 4(x0)` carga `0x00000000` en `f2`
- Todas las operaciones FP resultan en `0.0 + 0.0 = 0.0`

## Solución: Inicializar Valores FP en Memoria

Para ver resultados interesantes, necesitas inicializar valores FP en la memoria. Ejemplos:

### Valores IEEE-754 Single Precision (32 bits):
- **1.0** = `0x3F800000`
- **2.0** = `0x40000000`
- **3.0** = `0x40400000`
- **0.5** = `0x3F000000`
- **-1.0** = `0xBF800000`

### Cómo inicializar en `dmem.v`:

```verilog
initial begin
  // Inicializar memoria vacía 
  for (i = 0; i < 64; i = i + 1)
    RAM[i] = 32'h00000000;
  
  // Inicializar algunos valores FP para pruebas
  RAM[0] = 32'h3F800000;  // 1.0 en IEEE-754
  RAM[1] = 32'h40000000;  // 2.0 en IEEE-754
  RAM[2] = 32'h40400000;  // 3.0 en IEEE-754
end
```

## Valores Esperados con Memoria Inicializada

Si inicializas `memoria[0] = 1.0` y `memoria[4] = 2.0`:

1. **flw f1, 0(x0)**: `f1 = 0x3F800000` (1.0)
2. **flw f2, 4(x0)**: `f2 = 0x40000000` (2.0)
3. **fadd.s f3, f1, f2**:
   - `FRD1 = 0x3F800000` (1.0)
   - `FRD2 = 0x40000000` (2.0)
   - `f3 = 1.0 + 2.0 = 3.0` → `0x40400000`
4. **fsub.s f4, f3, f1**:
   - `FRD1 = 0x40400000` (3.0)
   - `FRD2 = 0x3F800000` (1.0)
   - `f4 = 3.0 - 1.0 = 2.0` → `0x40000000`

## Verificación en el Waveform

En Vivado, agrega estas señales al waveform:
- `testbench/dut/rvpipeline/dp/frf/frf` - Contenido del register file FP
- `testbench/dut/rvpipeline/dp/FRD1D` - Valor leído de fs1
- `testbench/dut/rvpipeline/dp/FRD2D` - Valor leído de fs2
- `testbench/dut/rvpipeline/dp/FRD1E` - Valor de fs1 en Execute
- `testbench/dut/rvpipeline/dp/FRD2E` - Valor de fs2 en Execute

