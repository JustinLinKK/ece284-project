// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, mac_mode, out_output, ififo_loop, out_output_valid);

  parameter bw       = 4;
  parameter psum_bw  = 16;
  parameter acc_kij  = 9; // 3x3 kernel
  parameter input_ch = 3; // 3 input channels

  input                  clk;
  input                  reset;
  input                  mac_mode; // 0: WS, 1: OS
  input  [1:0]           inst_w;
  input  [bw-1:0]        in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [psum_bw-1:0]   in_n;

  output                 ififo_loop; // high if psum finish 9 times accumulation, ififo need to loop the weight
  output                 out_output_valid;
  output [1:0]           inst_e;
  output [bw-1:0]        out_e;
  output [psum_bw-1:0]   out_s;
  output [psum_bw-1:0]   out_output;

  reg                    load_ready_q;
  reg                    output_psum_valid; // high if finished 3 input channels accumulation
  reg                    ififo_loop_q;
  reg    [1:0]           inst_q;
  reg    [4:0]           acc_counter; // counter for accumulation in Output Stationary
  reg    [bw-1:0]        a_q; // activation
  reg    [bw-1:0]        b_q; // weight
  reg    [psum_bw-1:0]   c_q; // psum
  reg    [psum_bw-1:0]   output_psum; // store the psum of tile0

  wire   [psum_bw-1:0]   mac_out;

  assign out_output_valid = output_psum_valid;
  assign out_output       = out_s;
  assign out_s            = mac_mode ? {12'b000000000000,b_q} : mac_out;
  assign out_e            = a_q;
  assign inst_e           = inst_q;
  assign ififo_loop       = ififo_loop_q;
  assign output_out       = output_psum * output_psum_valid;

always @ (posedge clk) begin
  if (reset) begin
      inst_q <= 2'b00;
      a_q <= {bw{1'b0}};
      b_q <= {bw{1'b0}};
      c_q <= {psum_bw{1'b0}};
      load_ready_q <=1'b1;
      acc_counter <= 5'b0;
      output_psum_valid <= 1'b0;
  end 

  else if (!mac_mode) begin
    // Weight Stationary
    c_q <= in_n;
    inst_q[1] <= inst_w[1];
    if (inst_w[0] || inst_w[1])
      a_q <= in_w; // latch new activation
    if (inst_w[0] && load_ready_q) begin
      b_q <= in_w; //latch new weight
      load_ready_q <=1'b0; // mark not ready
    end
    else if (!load_ready_q)
      inst_q[0] <= inst_w[0]; // keep load instruction until next cycle
  end
  else begin
    // Output Stationary
    inst_q[1] <= inst_w[1];
    if (inst_w[1]) begin
      b_q <= in_n [3:0]; // latch new weight
      a_q <= in_w; // latch new activation
      if (acc_counter != 5'b11011) begin // not yet finish 9 accumulation
        acc_counter <= acc_counter + 1;
        ififo_loop_q <= 1'b0;
        c_q <= mac_out; // feedback psum
        output_psum_valid <= 1'b0;
      end
      else if (acc_counter == 5'b11011) begin // finish 9 accumulation
        acc_counter <= 5'b0;
        ififo_loop_q <= 1'b1; // need to loop the weight
        output_psum <= mac_out;
        output_psum_valid <= 1'b1;
      end
    end
  end
end
  mac #(.bw(bw), .psum_bw(psum_bw)) MAC (
    .out(mac_out),
    .a(a_q),
    .b(b_q),
    .c(c_q),
    .mac_mode(mac_mode)
  );

endmodule