// Created by Jingbin Lin on 2025/12/12
module sram_2048b_w2048 (CLK, D, Q, CEN, WEN, A);

  input  CLK;
  input  WEN;
  input  CEN;
  input  [2047:0] D;
  input  [10:0] A;
  output [2047:0] Q;
  parameter num = 2048;

  reg [2047:0] memory [num-1:0];
  reg [10:0] add_q;
  assign Q = memory[add_q];

  always @ (posedge CLK) begin

   if (!CEN && WEN) // read 
      add_q <= A;
   if (!CEN && !WEN) // write
      memory[A] <= D; 

  end

endmodule
