 module core (
      clk,
      reset,
      inst,
      D_xmem,
      l0_ofifo_valid,
      ififo_valid,
      sfp_out,
      WeightOrOutput,
      rd_version
  );

      parameter bw      = 4;
      parameter psum_bw = 16;
      parameter col     = 8;
      parameter row     = 8;

      input clk;
      input reset;
      input [33:0] inst;
      input [31:0] D_xmem;
      input rd_version;
      input WeightOrOutput;

      output [4:0] l0_ofifo_valid;
      output [127:0] sfp_out;
      output [2:0] ififo_valid;

      wire [127:0] buf_sfp_in;
      wire [31:0]  buf_l0_in;
      wire [127:0] buf_ofifo_out;

      corelet #(
          .row(row),
          .col(col),
          .bw(bw),
          .psum_bw(psum_bw)
      ) corelet_inst (
          .clk(clk),
          .reset(reset),
          .inst(inst),
          .WeightOrOutput(WeightOrOutput),
          .rd_version(rd_version),

          .ofifo_valid(l0_ofifo_valid[4]),
          .l0_o_ready(l0_ofifo_valid[0]),
          .l0_o_full(l0_ofifo_valid[1]),

          .ififo_valid(ififo_valid[2]),
          .ififo_o_ready(ififo_valid[1]),
          .ififo_o_full(ififo_valid[0]),
          .ififo_in(buf_l0_in),

          .sfp_in(buf_sfp_in),
          .final_out(sfp_out),

          .l0_in(buf_l0_in),
          .ofifo_out(buf_ofifo_out),
          .ofifo_o_full(l0_ofifo_valid[2]),
          .ofifo_o_ready(l0_ofifo_valid[3])
      );

      sram_32b_w2048 xmem_sram (
          .CLK(clk),
          .D(D_xmem),
          .Q(buf_l0_in),
          .CEN(inst[19]),
          .WEN(inst[18]),
          .A(inst[17:7])
      );

      sram_128b_w2048 pmem_sram (
          .CLK(clk),
          .D(buf_ofifo_out),
          .Q(buf_sfp_in),
          .CEN(inst[32]),
          .WEN(inst[31]),
          .A(inst[30:20])
      );

  endmodule
