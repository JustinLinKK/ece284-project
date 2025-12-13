//Enhabced by Jingbin Lin
module mac_tile (clk, out_s, in_w, out_e, in_n, inst_w, inst_e, reset, WeightOrOutput, OS_out, IFIFO_loop, OS_out_valid, n_zero, w_zero, zero_s, zero_e);

parameter bw = 4;
parameter psum_bw = 16;
parameter acc_kij = 9;
parameter input_ch = 3;

input  [bw-1:0] in_w;
input  [1:0] inst_w;
input  [psum_bw-1:0] in_n;
input  clk;
input  reset;
input  WeightOrOutput;
input n_zero;
input w_zero;

output [1:0] inst_e;
output [bw-1:0] out_e;
output [psum_bw-1:0] out_s;
output IFIFO_loop;
output [psum_bw-1:0] OS_out;
output OS_out_valid;
output zero_s;
output zero_e;

wire [psum_bw-1:0] mac_out;
reg  [bw-1:0] b_q;
reg  [bw-1:0] a_q;
reg  [psum_bw-1:0] c_q;
reg  [1:0] inst_q;
reg  load_ready_q;

reg [4:0] acc_counter;
reg IFIFO_loop_q;
reg [psum_bw-1:0] OS_tile0;
reg [psum_bw-1:0] OS_tile1;
reg choose_tile;
reg tile0_out_valid;
reg tile1_out_valid;
reg s_zero;
reg e_zero;

assign OS_out_valid = tile0_out_valid | tile1_out_valid;
assign out_s = WeightOrOutput ? {12'b000000000000, b_q} : mac_out;
assign out_e = a_q;
assign inst_e = inst_q;
assign IFIFO_loop = IFIFO_loop_q;
assign OS_out = OS_tile0 * tile0_out_valid;
assign zero_s = s_zero;
assign zero_e = e_zero;

// Clock Gating Logic
wire a_clk;
wire b_clk;
wire c_clk;

assign a_clk = (WeightOrOutput && !reset) ? (clk & ~w_zero) : clk;
assign b_clk = (WeightOrOutput && !reset) ? (clk & ~n_zero) : clk;
assign c_clk = (WeightOrOutput && !reset) ? (clk & ~(n_zero | w_zero)) : clk;

// Control Logic (Ungated)
always @(posedge clk) begin
  if (reset) begin
    inst_q[1:0]      <= 2'b00;
    load_ready_q     <= 1;
    acc_counter      <= 0;
    choose_tile      <= 0;
    tile0_out_valid  <= 0;
    tile1_out_valid  <= 0;
    s_zero           <= 1;
    e_zero           <= 1;
    OS_tile0         <= 0;
    OS_tile1         <= 0;
    IFIFO_loop_q     <= 0;
  end else begin
    case (WeightOrOutput)
      0: begin // WS Mode
        inst_q[1] <= inst_w[1];
        s_zero    <= n_zero;
        e_zero    <= w_zero;
        if (inst_w[0] && load_ready_q) begin
          load_ready_q <= 0;
        end
        if (!load_ready_q) begin
          inst_q[0] <= inst_w[0];
        end
      end

      1: begin // OS Mode
        inst_q[1] <= inst_w[1];
        s_zero    <= n_zero;
        e_zero    <= w_zero;
        if (inst_w[1]) begin
          if (acc_counter != 5'b11011) begin
            acc_counter     <= acc_counter + 1;
            IFIFO_loop_q    <= 0;
            tile0_out_valid <= 0;
          end else if (acc_counter == 5'b11011) begin
            acc_counter     <= 0;
            OS_tile0        <= $signed(mac_out) > 0 ? mac_out : 0;
            tile0_out_valid <= 1;
          end
        end
      end
    endcase
  end
end

// a_q Logic (Gated by a_clk)
always @(posedge a_clk) begin
  if (reset) begin
    a_q <= 0;
  end else begin
    case (WeightOrOutput)
      0: begin // WS Mode
        if (inst_w[1:0] != 2'b00) begin
          a_q <= in_w;
        end
      end
      1: begin // OS Mode
        if (inst_w[1]) begin
          a_q <= in_w;
        end
      end
    endcase
  end
end

// b_q Logic (Gated by b_clk)
always @(posedge b_clk) begin
  if (reset) begin
    b_q <= 0;
  end else begin
    case (WeightOrOutput)
      0: begin // WS Mode
        if (inst_w[0] && load_ready_q) begin
          b_q <= in_w;
        end
      end
      1: begin // OS Mode
        if (inst_w[1]) begin
          b_q <= in_n[3:0];
        end
      end
    endcase
  end
end

// c_q Logic (Gated by c_clk)
always @(posedge c_clk) begin
  if (reset) begin
    c_q <= 0;
  end else begin
    case (WeightOrOutput)
      0: begin // WS Mode
        c_q <= in_n;
      end
      1: begin // OS Mode
        if (inst_w[1]) begin
           if (acc_counter != 5'b11011) begin
             c_q <= mac_out;
           end
        end
      end
    endcase
  end
end

mac #(.bw(bw), .psum_bw(psum_bw)) mac_instance (
  .WeightOrOutput(WeightOrOutput),
  .a(a_q),
  .b(b_q),
  .c(c_q),
  .out(mac_out)
);

endmodule
