# Análisis: Por qué ImmExtE tiene XXXXXXXXX

## Problema Identificado

`ImmExtE` muestra valores `XXXXXXXX` (desconocidos), lo que causa que:
- `ALUResultE` siempre sea `00000000`
- `ReadDataM` siempre lea de la misma dirección
- Los registros FP no se escriban correctamente

## Flujo de Datos del Immediate

1. **Decode Stage (ID)**:
   - `InstrD` viene de `IF_ID` (instrucción actual)
   - `controller_fp` lee `InstrD[6:0]` (opcode) y genera `ImmSrcD`
   - `extend` recibe `InstrD[31:7]` y `ImmSrcD`, genera `ImmExtD`
   - `ImmExtD` se propaga a `ID_EX`

2. **Execute Stage (EX)**:
   - `ImmExtE` viene de `ID_EX`
   - Se usa en `srcbmux` para calcular `SrcBE`
   - `ALUResultE = SrcAE_forwarded + SrcBE`

## Posibles Causas del Problema

### Causa 1: `ImmSrcD` no está definido (XXX)

**Verificar en waveform:**
- `testbench/dut/rvpipeline/c/ImmSrc` - ¿Tiene valor `000` para `flw`?
- `testbench/dut/rvpipeline/dp/ImmSrcD` - ¿Se propaga correctamente?

**Si `ImmSrcD = XXX`:**
- `extend` usa `default: immext_reg = 32'bx` → `ImmExtD = XXXXXXXXX`
- Esto causa que `ImmExtE = XXXXXXXXX`

### Causa 2: `InstrD` no está definido cuando se calcula `ImmExtD`

**Verificar en waveform:**
- `testbench/dut/rvpipeline/dp/InstrD` - ¿Tiene el valor correcto de la instrucción?
- Cuando `InstrD = 00001007` (flw f1), ¿`ImmExtD` se calcula correctamente?

**Si `InstrD = XXXXXXXXX`:**
- `InstrD[31:7]` también será `XXXXXXXX`
- `extend` no puede calcular el immediate correctamente

### Causa 3: Problema de timing

**Verificar:**
- ¿`ImmExtD` se calcula en el mismo ciclo que `InstrD` está disponible?
- ¿Hay algún problema con el orden de evaluación?

## Señales Críticas a Verificar

### En el Waveform, agrega estas señales:

1. **`InstrD[31:0]`** - Instrucción en Decode
   - Debería tener: `00001007`, `00002007`, etc.

2. **`ImmSrcD[2:0]`** - Tipo de immediate en Decode
   - Para `flw`: debería ser `000` (I-type)

3. **`ImmExtD[31:0]`** - Immediate extendido en Decode
   - Para `flw f1, 0(x0)`: debería ser `00000000`
   - Para `flw f2, 4(x0)`: debería ser `00000004`

4. **`ImmExtE[31:0]`** - Immediate extendido en Execute
   - Debería ser igual a `ImmExtD` (propagado)

5. **`SrcAE_forwarded[31:0]`** - Operando A en Execute
   - Para `flw f1, 0(x0)`: debería ser `00000000` (x0 = 0)

6. **`SrcBE[31:0]`** - Operando B en Execute (después del mux)
   - Para `flw f1, 0(x0)`: debería ser `00000000` (ImmExtE)
   - Para `flw f2, 4(x0)`: debería ser `00000004` (ImmExtE)

7. **`ALUResultE[31:0]`** - Resultado de ALU en Execute
   - Para `flw f1, 0(x0)`: debería ser `00000000`
   - Para `flw f2, 4(x0)`: debería ser `00000004`

## Diagnóstico Rápido

**Si `ImmSrcD = XXX`:**
- Problema en `controller_fp` o `maindec`
- Verificar que `maindec` esté generando `ImmSrc = 000` para `flw`

**Si `InstrD = XXXXXXXXX`:**
- Problema en `IF_ID` o propagación de `InstrF`
- Verificar que `InstrF` tenga valores correctos

**Si `ImmExtD = XXXXXXXXX` pero `ImmSrcD = 000` e `InstrD` está bien:**
- Problema en `extend` module
- Verificar que `extend` esté recibiendo las señales correctas

## Solución Esperada

Una vez que `ImmExtE` tenga valores correctos:
- `ALUResultE` debería cambiar: `0`, `4`, `8`, etc.
- `ALUResultM` debería propagar estos valores
- `ReadDataM` debería leer de diferentes direcciones: `RAM[0]`, `RAM[1]`, etc.
- Los valores se escribirán en los registros FP
- `FRD1D` y `FRD2D` deberían tener valores distintos de `0`

