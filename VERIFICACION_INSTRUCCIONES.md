# Verificación de Instrucciones FP

## Instrucciones en `riscvtest_fp.txt`

### 1. `00001087` - flw f1, 0(x0)
- **Formato I-type**: imm[11:0] rs1 funct3 rd opcode
- imm[11:0] = 0 = `0000 0000 0000`
- rs1 = x0 = `00000`
- funct3 = `010` (flw)
- rd = f1 = `00001`
- opcode = `0000111` (flw)
- **Codificación**: `0000 0000 0000 00000 010 00001 0000111` = `0x00001087` ✓

### 2. `00001097` - flw f2, 0(x0)
- imm[11:0] = 0 = `0000 0000 0000`
- rs1 = x0 = `00000`
- funct3 = `010` (flw)
- rd = f2 = `00010`
- opcode = `0000111` (flw)
- **Codificación**: `0000 0000 0000 00000 010 00010 0000111` = `0x00001097` ✓

### 3. `00208053` - fadd.s f3, f1, f2
- **Formato R-type**: funct7 rs2 rs1 funct3 rd opcode
- funct7 = `0000000`
- rs2 = f2 = `00010`
- rs1 = f1 = `00001`
- funct3 = `000`
- rd = f3 = `00011`
- opcode = `1010011` (FP op)
- **Codificación**: `0000000 00010 00001 000 00011 1010011` = `0x00208053` ✓

### 4. `00118053` - fsub.s f4, f3, f1
- funct7 = `0000100` (fsub)
- rs2 = f1 = `00001`
- rs1 = f3 = `00011`
- funct3 = `000`
- rd = f4 = `00100`
- opcode = `1010011` (FP op)
- **Codificación**: `0000100 00001 00011 000 00100 1010011` = `0x00118053` ✓

### 5. `08208053` - fmul.s f5, f1, f2
- funct7 = `0001000` (fmul)
- rs2 = f2 = `00010`
- rs1 = f1 = `00001`
- funct3 = `000`
- rd = f5 = `00101`
- opcode = `1010011` (FP op)
- **Codificación**: `0001000 00010 00001 000 00101 1010011` = `0x08208053` ✓

### 6. `0C108053` - fdiv.s f6, f2, f1
- funct7 = `0001100` (fdiv)
- rs2 = f1 = `00001`
- rs1 = f2 = `00010`
- funct3 = `000`
- rd = f6 = `00110`
- opcode = `1010011` (FP op)
- **Codificación**: `0001100 00001 00010 000 00110 1010011` = `0x0C108053` ✓

### 7. `00302027` - fsw f3, 8(x0)
- **Formato S-type**: imm[11:5] rs2 rs1 funct3 imm[4:0] opcode
- imm[11:5] = 0 = `0000000`
- imm[4:0] = 8 = `01000`
- rs2 = f3 = `00011`
- rs1 = x0 = `00000`
- funct3 = `010` (fsw)
- opcode = `0100111` (fsw)
- **Codificación**: `0000000 00011 00000 010 01000 0100111` = `0x00302027` ✓

### 8. `00007007` - flw f7, 8(x0)
- imm[11:0] = 8 = `0000 0000 1000`
- rs1 = x0 = `00000`
- funct3 = `010` (flw)
- rd = f7 = `00111`
- opcode = `0000111` (flw)
- **Codificación esperada**: `0000 0000 1000 00000 010 00111 0000111` = `0x00007087`
- **Codificación actual**: `0x00007007` ✗

**PROBLEMA**: La instrucción `00007007` no es correcta. Debería ser `00007087` para `flw f7, 8(x0)`.

### 9-11. `00000013` - NOP (addi x0, x0, 0)
- ✓ Correcto

## Resumen

- **Instrucciones correctas**: 1-7, 9-11
- **Instrucción incorrecta**: 8 (`00007007` debería ser `00007087`)

