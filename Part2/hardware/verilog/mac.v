// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac (out, a0, a1, b0, b1, c, mode);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input signed  [1:0] a0;  // activation MSB
input signed  [1:0] a1;  // activation LSB
input signed  [bw-1:0] b0; // weight 0
input signed  [bw-1:0] b1; // weight 1
input signed  [psum_bw-1:0] c; // psum
input mode; // 1: 2-bit, 0: 4-bit

wire signed [bw+2:0] prod0;
wire signed [bw+2:0] prod1;

// a0 * b0
assign prod0 = {1'b0, a0} * b0;
// a1 * b1
assign prod1 = {1'b0, a1} * b1;

assign out = (mode ? prod0 : (prod0 << 2)) + prod1 + c;

endmodule
