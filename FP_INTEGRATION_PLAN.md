# Plan de Integración de Punto Flotante en el Pipeline

## Objetivos
- Integrar ALU de punto flotante (FADD.S, FSUB.S, FMUL.S, FDIV.S, FMIN.S, FMAX.S)
- Soporte para FLW/FSW (load/store de punto flotante)
- Gestión de latencias múltiples en el pipeline

## Arquitectura Propuesta

### 1. Detección de Instrucciones FP
- **Opcode 7'b1010011**: Operaciones FP (FADD.S, FSUB.S, FMUL.S, FDIV.S, FMIN.S, FMAX.S)
- **Opcode 7'b0000111**: FLW (load word FP)
- **Opcode 7'b0100111**: FSW (store word FP)

### 2. Señales de Control FP
- `isFP`: Indica si la instrucción es FP
- `FPOp[1:0]`: Operación FP (00=ADD, 01=SUB, 10=MUL, 11=DIV)
- `FPLatency[2:0]`: Latencia de la operación FP (1 ciclo para ADD/SUB, más para MUL/DIV)
- `FPReady`: Indica cuando la operación FP está lista

### 3. Gestión de Latencias

#### Latencias Asumidas:
- **FADD.S / FSUB.S**: 1 ciclo (combinacional)
- **FMUL.S**: 3-4 ciclos (pipeline interno)
- **FDIV.S**: 8-12 ciclos (pipeline interno)
- **FMIN.S / FMAX.S**: 1 ciclo (combinacional)

#### Estrategia de Implementación:
1. **Pipeline Extendido**: Agregar etapas adicionales entre EX y MEM para operaciones FP de múltiples ciclos
2. **Stalling**: Detener el pipeline cuando una operación FP no está lista
3. **Hazard Unit Extendido**: Detectar dependencias FP y manejar stalling por latencia

### 4. Modificaciones al Pipeline

#### ID/EX Register:
- Agregar: `isFPE`, `FPOpE`, `FPLatencyE`

#### EX Stage:
- Instanciar ALU-FP junto con ALU entera
- Mux para seleccionar resultado de ALU entera o FP
- Contador de latencia para operaciones FP

#### EX/MEM Register:
- Agregar: `FPResultM`, `FPReadyM`, `FPLatencyM`
- Pipeline extendido para operaciones FP de múltiples ciclos

#### Hazard Unit:
- Detectar dependencias FP (RAW hazards)
- Manejar stalling cuando operación FP no está lista
- Forwarding para resultados FP (cuando están disponibles)

### 5. Estructura de Archivos

```
alu_fp.v          - Wrapper para ALU FP
fpdec.v           - Decodificador de instrucciones FP
controller_fp.v    - Controlador extendido con soporte FP
datapath_fp.v     - Datapath extendido con ALU FP
hazard_unit_fp.v  - Hazard unit extendido para FP
```

## Pasos de Implementación

1. ✅ Crear wrapper ALU-FP (alu_fp.v)
2. ✅ Crear decodificador FP (fpdec.v)
3. ⏳ Extender controlador (controller_fp.v)
4. ⏳ Modificar ID/EX para propagar señales FP
5. ⏳ Modificar EX stage para instanciar ALU-FP
6. ⏳ Agregar gestión de latencias en EX/MEM
7. ⏳ Extender hazard unit para FP
8. ⏳ Agregar soporte FLW/FSW

## Notas de Implementación

- La ALU FP proporcionada es combinacional, pero MUL y DIV pueden requerir múltiples ciclos
- Se asume que las unidades funcionales internas (ProductHP, DivHP) tienen sus propias latencias
- El hazard unit debe detectar cuando una operación FP está en progreso y hacer stall si es necesario


