module core (clk,
             reset,
             inst,
             D_xmem,
             ofifo_valid,
             ofifo_ready,
             ofifo_full,
             l0_ready,
             l0_full,
             l0_version,
             sfu_out,
             mode
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
    input mode;
    output ofifo_valid;
    output [127:0] sfu_out;

    wire [127:0] sfu_in;
    wire [31:0] sram2l0_in;
    wire [127:0] ofifo2sram_out;
    output l0_full;
    output l0_ready;
    output ofifo_full;
    output ofifo_ready;

    // Decode inst
    // wire acc = inst[33];
    // wire CEN_pmem = inst[32];
    // wire WEN_pmem = inst[31];
    // wire [10:0] A_pmem = inst[30:20];
    // wire CEN_xmem = inst[19];
    // wire WEN_xmem = inst[18];
    // wire [10:0] A_xmem = inst[17:7];
    // wire ofifo_rd = inst[6];
    // wire l0_rd = inst[3]; 
    // wire l0_wr = inst[2];
    // wire execute = inst[1];
    // wire load = inst[0];

    corelet #(.row(row), .col(col), .bw(bw), .psum_bw(psum_bw)) corelet_instance(
        .clk(clk),
        .reset(reset),
        .l0_in(sram2l0_in),
        .inst(inst),
        .l0_full(l0_full), 
        .l0_ready(l0_ready), 
        .ofifo_out(ofifo2sram_out),
        .ofifo_full(ofifo_full), 
        .ofifo_ready(ofifo_ready), 
        .ofifo_valid(ofifo_valid),
        .sfu_in(sfu_in),
        .sfu_out(sfu_out),
        .l0_version(l0_version),
        .mode(mode)
    );

    sram_32b_w2048 input_sram(
        .CLK(clk),
        .D(D_xmem),
        .Q(sram2l0_in),
        .CEN(inst[19]),
        .WEN(inst[18]),
        .A(inst[17:7])
    );

    sram_128b_w2048 psum_sram(
        .CLK(clk),
        .D(ofifo2sram_out),
        .Q(sfu_in),
        .CEN(inst[32]),
        .WEN(inst[31]),
        .A(inst[30:20])
    );


endmodule
