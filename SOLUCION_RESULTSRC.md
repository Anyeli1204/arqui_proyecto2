# Solución: ResultSrcW no se activa para flw

## Problema Identificado

`ResultSrcW[0]` debería ser `1` para `flw`, pero parece que no se está activando correctamente.

## Verificación

### En maindec.v:
- `flw` (opcode `7'b0000111`) tiene `ResultSrc = 01` ✅ CORRECTO

### En datapath.v:
- `fresultmux` usa `ResultSrcW[0]` para seleccionar entre `FALUResultW` y `ReadDataW` ✅ CORRECTO

## Señales a Verificar en el Waveform

1. **`ResultSrcD`** cuando `InstrD = 00001007` (flw f1):
   - Debería ser `2'b01`

2. **`ResultSrcE`** cuando `flw f1` está en EX:
   - Debería ser `2'b01`

3. **`ResultSrcM`** cuando `flw f1` está en MEM:
   - Debería ser `2'b01`

4. **`ResultSrcW`** cuando `flw f1` está en WB:
   - Debería ser `2'b01`
   - `ResultSrcW[0]` debería ser `1`

5. **`FResultW`** cuando `flw f1` está en WB:
   - Debería ser igual a `ReadDataW` (porque `ResultSrcW[0] = 1`)

## Si ResultSrcW[0] NO es 1 para flw:

El problema puede ser que `ResultSrc` se está modificando en algún lugar, o que hay un problema con la propagación.

### Verificar:
- ¿`ResultSrcD` es `01` cuando `InstrD = 00001007`?
- ¿`ResultSrcE` es `01` cuando `flw` está en EX?
- ¿`ResultSrcM` es `01` cuando `flw` está en MEM?
- ¿`ResultSrcW` es `01` cuando `flw` está en WB?

Si alguno de estos NO es `01`, entonces hay un problema en la propagación.

## Solución Temporal

Si `ResultSrcW[0]` no se activa para `flw`, podemos usar una señal adicional para detectar `flw` directamente:

```verilog
wire isFLW_W = (InstrW[6:0] == 7'b0000111);  // Detectar flw en WB
assign FResultW = (isFLW_W || ResultSrcW[0]) ? ReadDataW : FALUResultW;
```

Pero esto requiere agregar `InstrW` al pipeline register MEM_WB.

## Verificación Rápida

En el waveform, busca el ciclo donde:
- `InstrD = 00001007` (flw f1 en Decode)
- Verifica `ResultSrcD` - ¿es `01`?

Si `ResultSrcD` es `01` pero `ResultSrcW` no lo es, entonces hay un problema en la propagación.

