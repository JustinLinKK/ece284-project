module corelet (
    clk,
    reset,
    ofifo_valid,
    sfp_in,
    final_out,
    inst,
    l0_in,
    l0_o_full,
    l0_o_ready,
    ofifo_out,
    ofifo_o_full,
    ofifo_o_ready,
    ififo_in,
    ififo_o_full,
    ififo_o_ready,
    ififo_valid,
    rd_version,
    WeightOrOutput
);

    parameter row     = 8;
    parameter col     = 8;
    parameter bw      = 4;
    parameter psum_bw = 16;

    input clk;
    input reset;
    input [33:0] inst;
    input [row*bw-1:0] l0_in;
    input rd_version;
    input [psum_bw*col-1:0] sfp_in;
    input [col*bw-1:0] ififo_in;
    input WeightOrOutput;

    output l0_o_full;
    output l0_o_ready;
    output ofifo_o_full;
    output ofifo_o_ready;
    output ofifo_valid;
    output [col*psum_bw-1:0] ofifo_out;
    output [psum_bw*col-1:0] final_out;
    output ififo_o_full;
    output ififo_o_ready;
    output ififo_valid;

    wire [psum_bw*col-1:0] w_array_os;
    wire [psum_bw*col-1:0] w_array_ws;
    wire [psum_bw*col-1:0] w_sfp_out;
    wire [psum_bw*col-1:0] w_array_mux;
    wire [row*bw-1:0] w_l0_to_array;
    wire [col-1:0] w_mac_valid;
    wire [col*bw-1:0] w_ififo_raw;
    wire [col*psum_bw-1:0] w_ififo_pad;
    wire [col*psum_bw-1:0] w_array_in_n;
    wire [col-1:0] w_ififo_loop;

    assign final_out     = WeightOrOutput ? ofifo_out : w_sfp_out;
    assign w_array_mux   = WeightOrOutput ? w_array_os : w_array_ws;

    assign w_ififo_pad = {
        12'b0, ififo_in[31:28],
        12'b0, ififo_in[27:24],
        12'b0, ififo_in[23:20],
        12'b0, ififo_in[19:16],
        12'b0, ififo_in[15:12],
        12'b0, ififo_in[11:8],
        12'b0, ififo_in[7:4],
        12'b0, ififo_in[3:0]
    };

    assign w_array_in_n = WeightOrOutput ? w_ififo_pad : {col*psum_bw{1'b0}};

    l0 #(
        .row(row),
        .bw(bw)
    ) u_l0 (
        .clk(clk),
        .wr(inst[2]),
        .rd(inst[3]),
        .reset(reset),
        .in(l0_in),
        .out(w_l0_to_array),
        .o_full(l0_o_full),
        .o_ready(l0_o_ready),
        .rd_version(rd_version)
    );

    mac_array #(
        .bw(bw),
        .psum_bw(psum_bw),
        .col(col),
        .row(row)
    ) u_mac (
        .clk(clk),
        .reset(reset),
        .out_s(w_array_ws),
        .in_w(w_l0_to_array),
        .inst_w(inst[1:0]),
        .in_n(w_array_in_n),
        .WeightOrOutput(WeightOrOutput),
        .OS_out(w_array_os),
        .IFIFO_loop(w_ififo_loop),
        .valid(w_mac_valid)
    );

    ofifo #(
        .col(col),
        .bw(psum_bw)
    ) u_ofifo (
        .clk(clk),
        .wr(w_mac_valid),
        .rd(inst[6]),
        .reset(reset),
        .in(w_array_mux),
        .out(ofifo_out),
        .o_full(ofifo_o_full),
        .o_ready(ofifo_o_ready),
        .o_valid(ofifo_valid)
    );

    ififo #(
        .col(col),
        .bw(bw)
    ) u_ififo (
        .clk(clk),
        .wr(inst[5]),
        .rd(inst[4]),
        .reset(reset),
        .in(ififo_in),
        .out(w_ififo_raw),
        .o_full(ififo_o_full),
        .o_ready(ififo_o_ready),
        .loop_flag(w_ififo_loop),
        .o_valid(ififo_valid)
    );

    sfp #(
        .psum_bw(psum_bw),
        .col(col)
    ) u_sfp (
        .clk(clk),
        .reset(reset),
        .acc_q(inst[33]),
        .sfp_in(sfp_in),
        .sfp_out(w_sfp_out)
    );

endmodule
