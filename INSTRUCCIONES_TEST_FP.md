# Instrucciones para Probar Operaciones Floating Point

## Archivos Creados/Modificados

1. **`riscvtest_fp.txt`**: Archivo con instrucciones FP en hexadecimal
2. **`imem.v`**: Modificado para cargar `riscvtest_fp.txt` por defecto
3. **`testbench.v`**: Actualizado para mostrar señales FP
4. **`top.v`**: Actualizado para pasar señales FP al testbench

## Instrucciones FP Incluidas

El archivo `riscvtest_fp.txt` contiene las siguientes instrucciones:

1. **flw f1, 0(x0)** - Carga valor FP desde memoria[0] a f1
2. **flw f2, 4(x0)** - Carga valor FP desde memoria[4] a f2
3. **fadd.s f3, f1, f2** - f3 = f1 + f2 (suma FP)
4. **fsub.s f4, f3, f1** - f4 = f3 - f1 (resta FP)
5. **fmul.s f5, f1, f2** - f5 = f1 * f2 (multiplicación FP)
6. **fdiv.s f6, f2, f1** - f6 = f2 / f1 (división FP)
7. **fsw f3, 8(x0)** - Guarda f3 en memoria[8]
8. **flw f7, 8(x0)** - Carga de vuelta desde memoria[8] a f7

## Cómo Ejecutar las Pruebas

### Opción 1: Usar el archivo FP (recomendado)
El archivo `imem.v` ya está configurado para cargar `riscvtest_fp.txt` por defecto.

### Opción 2: Volver a instrucciones enteras
Si quieres volver a probar con instrucciones enteras, cambia en `imem.v`:
```verilog
$readmemh("riscvtest.txt", RAM);  // En lugar de riscvtest_fp.txt
```

## Ejecutar la Simulación

1. **En Vivado/Xilinx:**
   - Abre el proyecto
   - Ejecuta la simulación del testbench
   - Observa las señales en el waveform

2. **En Icarus Verilog:**
   ```bash
   iverilog -o sim testbench.v top.v riscvpipeline.v datapath.v controller_fp.v ...
   vvp sim
   ```

3. **En ModelSim:**
   - Compila todos los archivos
   - Ejecuta `testbench`
   - Observa el waveform

## Señales a Observar

### En el Waveform:
- **PCF**: Contador de programa
- **InstrD**: Instrucción en etapa Decode
- **isFPE**: Señal que indica operación FP en Execute
- **FALUControlE**: Control de la ALU FP
- **FRD1E, FRD2E**: Operandos FP en Execute
- **FALUResultE**: Resultado de operación FP
- **FPRegWriteW**: Escritura en register file FP
- **FResultW**: Resultado final FP en Writeback

### En la Consola:
El testbench mostrará mensajes cuando:
- Hay escritura a memoria entera (`MemWrite`)
- Hay escritura a memoria FP (`FPMemWriteM`)
- Cada 10 ciclos de reloj

## Notas Importantes

1. **Memoria de Datos**: La memoria de datos (`dmem`) no distingue entre enteros y FP. Ambos usan la misma memoria física.

2. **Valores Iniciales**: La memoria de datos se inicializa en cero. Para pruebas más realistas, puedes:
   - Modificar `dmem.v` para inicializar valores FP específicos
   - O usar instrucciones enteras primero para escribir valores FP en memoria

3. **Formato IEEE-754**: Los valores FP están en formato IEEE-754 single precision (32 bits).

4. **Registros FP**: Los registros FP (f0-f31) son independientes de los registros enteros (x0-x31).

## Ejemplo de Valores FP para Pruebas

Si quieres inicializar valores FP en memoria, puedes usar estos valores IEEE-754:

- **1.0** = `0x3F800000`
- **2.0** = `0x40000000`
- **3.0** = `0x40400000`
- **0.5** = `0x3F000000`
- **-1.0** = `0xBF800000`

## Solución de Problemas

1. **No se cargan las instrucciones**: Verifica que `riscvtest_fp.txt` esté en el mismo directorio que `imem.v`

2. **Señales FP no aparecen**: Verifica que `top.v` y `testbench.v` tengan las conexiones FP correctas

3. **Resultados incorrectos**: Revisa que las codificaciones de instrucciones sean correctas (ver `riscvtest_fp.txt`)

## Próximos Pasos

Para pruebas más avanzadas, puedes:
- Agregar más instrucciones FP al archivo
- Crear secuencias de operaciones más complejas
- Probar casos especiales (NaN, Inf, cero, etc.)
- Verificar el forwarding y stalling para operaciones FP

