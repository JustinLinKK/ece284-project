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
             sfu_out
             );

    parameter bw      = 4;
    parameter psum_bw = 16;
    parameter col     = 8;
    parameter row     = 8;
    parameter num_corelet_row = 4;
    parameter num_corelet_col = 4;

    input clk;
    input reset;
    input [33:0] inst;
    input [511:0] D_xmem;
    input l0_version;
    output ofifo_valid;
    output [2047:0] sfu_out;

    wire [2047:0] sfu_in;
    wire [511:0] sram2l0_in;
    wire [2047:0] ofifo2sram_out;
    output l0_valid;
    output l0_full;
    output l0_ready;
    output ofifo_full;
    output ofifo_ready;

    wire [15:0] l0_full_temp;
    wire [15:0] l0_ready_temp;
    wire [15:0] ofifo_full_temp;
    wire [15:0] ofifo_ready_temp;
    wire [15:0] ofifo_valid_temp;

    assign l0_full = |l0_full_temp;
    assign l0_ready = &l0_ready_temp;
    assign ofifo_full = |ofifo_full_temp;
    assign ofifo_ready = &ofifo_ready_temp;
    assign ofifo_valid = &ofifo_valid_temp;

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

    genvar i, j;
    generate
        for (i=0; i<num_corelet_row; i=i+1) begin : corelet_row
            for (j=0; j<num_corelet_col; j=j+1) begin : corelet_col
                corelet #(.row(row), .col(col), .bw(bw), .psum_bw(psum_bw)) corelet_instance(
                    .clk(clk),
                    .reset(reset),
                    .l0_in(sram2l0_in[(i*num_corelet_col+j+1)*row*bw-1:(i*num_corelet_col+j)*row*bw]),
                    .inst(inst),
                    .l0_full(l0_full_temp[i*num_corelet_col+j]), 
                    .l0_ready(l0_ready_temp[i*num_corelet_col+j]), 
                    .ofifo_out(ofifo2sram_out[(i*num_corelet_col+j+1)*col*psum_bw-1:(i*num_corelet_col+j)*col*psum_bw]),
                    .ofifo_full(ofifo_full_temp[i*num_corelet_col+j]), 
                    .ofifo_ready(ofifo_ready_temp[i*num_corelet_col+j]), 
                    .ofifo_valid(ofifo_valid_temp[i*num_corelet_col+j]),
                    .sfu_in(sfu_in[(i*num_corelet_col+j+1)*col*psum_bw-1:(i*num_corelet_col+j)*col*psum_bw]),
                    .sfu_out(sfu_out[(i*num_corelet_col+j+1)*col*psum_bw-1:(i*num_corelet_col+j)*col*psum_bw]),
                    .l0_version(l0_version)
                );
            end
        end
    endgenerate

    sram_512b_w2048 input_sram(
        .CLK(clk),
        .D(D_xmem),
        .Q(sram2l0_in),
        .CEN(inst[19]),
        .WEN(inst[18]),
        .A(inst[17:7])
    );

    sram_2048b_w2048 psum_sram(
        .CLK(clk),
        .D(ofifo2sram_out),
        .Q(sfu_in),
        .CEN(inst[32]),
        .WEN(inst[31]),
        .A(inst[30:20])
    );


endmodule
