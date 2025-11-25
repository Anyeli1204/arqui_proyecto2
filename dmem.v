module dmem(input  clk, we,
            input  [31:0] a, wd,
            output [31:0] rd);
  
  reg [31:0] RAM[63:0]; 
  integer i;

  initial begin
    // Inicializar memoria vacía 
    for (i = 0; i < 64; i = i + 1)
      RAM[i] = 32'h00000000;
    
    // Inicializar algunos valores FP para pruebas
    // IEEE-754 Single Precision (32 bits)
    RAM[0] = 32'h3F800000;  // 1.0
    RAM[1] = 32'h40000000;  // 2.0
    RAM[2] = 32'h40400000;  // 3.0
    RAM[3] = 32'h3F000000;  // 0.5
  end

  assign rd = RAM[a[31:2]]; // word aligned

  always @(posedge clk) begin 
    if (we) RAM[a[31:2]] <= wd; 
  end
endmodule