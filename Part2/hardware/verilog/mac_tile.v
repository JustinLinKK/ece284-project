// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, mode);

parameter bw = 4;
parameter psum_bw = 16;

output [psum_bw-1:0] out_s;
input  [bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
output [bw-1:0] out_e; 
input  [1:0] inst_w;
output [1:0] inst_e;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input  mode;

reg [1:0] inst_q;
reg [1:0] a_q0; // activation MSB
reg [1:0] a_q1; // activation LSB
reg [bw-1:0] b_q0; // weight 0
reg [bw-1:0] b_q1; // weight 1
reg [psum_bw-1:0] c_q; // psum 
reg load_cnt;

assign out_e = {a_q0, a_q1};
assign inst_e = inst_q;

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
        .a0(a_q0), 
        .a1(a_q1), 
        .b0(b_q0),
        .b1(b_q1),
        .c(c_q),
        .out(out_s),
        .mode(mode)
); 

always @ (posedge clk) begin
  if (reset) begin
     inst_q <= 2'b00;
     a_q0 <= 2'b0;
     a_q1 <= 2'b0;
     b_q0 <= {bw{1'b0}};
     b_q1 <= {bw{1'b0}};
     c_q <= {psum_bw{1'b0}};
     load_cnt <= 0;
  end 
  else begin
    c_q <= in_n;
    inst_q[1] <= inst_w[1];
    if (inst_w[0] || inst_w[1]) begin
      a_q0 <= in_w[3:2]; // latch new activation MSB
      a_q1 <= in_w[1:0]; // latch new activation LSB
    end
    
    if (inst_w[0]) begin // load enabled
        if (mode) begin // 2-bit mode: 2 cycles
            if (load_cnt == 0) begin
                b_q0 <= in_w;
                load_cnt <= 1;
                inst_q[0] <= 0;
            end else begin
                b_q1 <= in_w;
                load_cnt <= 0;
                inst_q[0] <= 1; // Pass load signal after 2nd weight
            end
        end else begin // 4-bit mode: 1 cycle
            b_q0 <= in_w;
            b_q1 <= in_w;
            inst_q[0] <= 1;
        end
    end else begin
        inst_q[0] <= 0;
        load_cnt <= 0;
    end
  end
end

endmodule
