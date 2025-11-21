module top(input  clk, reset, 
           output [31:0] WriteData, DataAdr, 
           output MemWrite);
  
  wire [31:0] PC, Instr, ReadData; 
  
  // Instanciar el procesador pipeline
  riscvpipeline rvpipeline(
    .clk(clk), 
    .reset(reset), 
    .PCF(PC), 
    .InstrF(Instr), 
    .MemWriteM(MemWrite), 
    .ALUResultM(DataAdr), 
    .WriteDataM(WriteData), 
    .ReadDataM(ReadData)
  ); 

  // Memoria de instrucciones
  imem imem(
    .a(PC), 
    .rd(Instr)
  ); 
  
  // Memoria de datos
  dmem dmem(
    .clk(clk), 
    .we(MemWrite), 
    .a(DataAdr), 
    .wd(WriteData), 
    .rd(ReadData)
  ); 
endmodule