module core (clk,
             reset,
             inst,
             D_xmem,
             l0_ofifo_signals,
             ififo_signals,
             sfu_out,
             mode,
             l0_version
             );

    parameter bw      = 4;
    parameter psum_bw = 16;
    parameter col     = 8;
    parameter row     = 8;

    input clk;
    input reset;
    input [33:0] inst;
    input [31:0] D_xmem;
    input l0_version;
    input mode;       // mode 0: weight stationary; mode 1: output stationsary
    output [4:0] l0_ofifo_signals;
    output [127:0] sfu_out;
    output [2:0] ififo_signals;
    wire [127:0] sfu_in;
    wire [31:0] sram2l0_in;
    wire [127:0] ofifo2sram_out;
    wire [31:0] sram2ififo_in;

    corelet #(.row(row), .col(col), .bw(bw), .psum_bw(psum_bw)) corelet_instance(
    .clk(clk),
    .reset(reset),
    .ofifo_valid(l0_ofifo_signals[4]),
    .sfu_in(sfu_in),
    .final_out(sfu_out),
    .inst(inst),
    .l0_in(sram2l0_in),
    .l0_o_full(l0_ofifo_signals[1]),
    .l0_o_ready(l0_ofifo_signals[0]),
    .ofifo_out(ofifo2sram_out),
    .ofifo_o_full(l0_ofifo_signals[2]),
    .ofifo_o_ready(l0_ofifo_signals[3]),
    .l0_version(l0_version),
    .mode(mode),
    .ififo_in(sram2l0_in),
    .ififo_o_full(ififo_signals[0]),
    .ififo_o_ready(ififo_signals[1]),
    .ififo_signals(ififo_signals[2])
    );

    sram_32b_w2048 input_sram(
    .CLK(clk),
    .D(D_xmem),
    .Q(sram2l0_in),
    .CEN(inst[19]),
    .WEN(inst[18]),
    .A(inst[17:7]));

    sram_128b_w2048 psum_sram(
    .CLK(clk),
    .D(ofifo2sram_out),
    .Q(sfu_in),
    .CEN(inst[32]),
    .WEN(inst[31]),
    .A(inst[30:20]));


endmodule
