module l0 (clk,
           in,
           out,
           rd,
           wr,
           o_full,
           reset,
           o_ready,
           rd_version);

    parameter row = 8;
    parameter bw  = 4;

    input  clk;
    input  wr;
    input  rd;
    input  reset;
    input  [row*bw-1:0] in;
    input  rd_version;
    output [row*bw-1:0] out;
    output o_full;
    output o_ready;

    wire [row-1:0] empty;
    wire [row-1:0] full;
    reg  [row-1:0] rd_en;

    genvar i;
    assign o_ready = &empty;
    assign o_full  = |full;

    generate
    for (i = 0; i < row; i = i+1) begin : row_num
        fifo_depth64 #(.bw(bw)) fifo_instance (
            .rd_clk(clk),
            .wr_clk(clk),
            .rd(rd_en[i]),
            .wr(wr),
            .o_empty(empty[i]),
            .o_full(full[i]),
            .in(in[bw*(i+1)-1:bw*i]),
            .out(out[bw*(i+1)-1:bw*i]),
            .reset(reset)
        );
    end
    endgenerate

    always @ (posedge clk) begin
        if (reset) begin
            rd_en <= 8'b00000000;
        end
        else begin
            case(rd_version)
                0: begin
                    if (rd)
                        rd_en <= 8'b11111111;
                    else
                        rd_en <= 8'b00000000;
                end
                1: begin
                    rd_en[0] <= rd;
                    rd_en[1] <= rd_en[0];
                    rd_en[2] <= rd_en[1];
                    rd_en[3] <= rd_en[2];
                    rd_en[4] <= rd_en[3];
                    rd_en[5] <= rd_en[4];
                    rd_en[6] <= rd_en[5];
                    rd_en[7] <= rd_en[6];
                end
            endcase
        end
    end
endmodule
