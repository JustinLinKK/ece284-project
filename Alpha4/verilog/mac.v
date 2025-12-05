module mac (out, a, b, c, mac_mode);

parameter bw = 4;
parameter psum_bw = 16;

output signed [psum_bw-1:0] out;
input signed  [bw-1:0] a;  // activation
input signed  [bw-1:0] b;  // weight
input signed  [psum_bw-1:0] c;
input mac_mode; // 0: WS, 1: OS

wire signed [2*bw:0] product;
wire signed [psum_bw-1:0] psum;
wire signed [bw:0]   a_pad;

assign a_pad = {1'b0, a}; // force to be unsigned number
assign product = a_pad * b;

assign out_weight = a_pad*b + c;
assign out_output = $signed(a)*$signed(b) + $signed(c);
assign out = mac_mode ? out_output : out_weight;

endmodule
