module round (in, out, mask);
  parameter width = 8; // number of elements
  parameter bw = 4;    // bit width per element

  input [width*bw-1:0] in;
  output [width*bw-1:0] out;
  output [width-1:0] mask;

  genvar i;
  generate
    for (i=0; i<width; i=i+1) begin : loop
      assign mask[i] = |in[bw*(i+1)-1:bw*i]; // 1 if non-zero
      assign out[bw*(i+1)-1:bw*i] = in[bw*(i+1)-1:bw*i]; // Pass through
    end
  endgenerate
endmodule
