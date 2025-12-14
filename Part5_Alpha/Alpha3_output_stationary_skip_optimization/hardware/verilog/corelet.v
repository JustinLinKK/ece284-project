module corelet (clk,
                reset,
                ofifo_valid,
                sfu_in,
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
                ififo_signals,
                l0_version,
                mode);

    parameter row     = 8;
    parameter col     = 8;
    parameter bw      = 4;
    parameter psum_bw = 16;

    input clk;
    input reset;                       
    input [33:0] inst;                 
    input [row*bw-1:0] l0_in;          
    input l0_version;                  
    input [psum_bw*col-1:0] sfu_in;    
    input [col*bw-1:0] ififo_in;
    input mode;

    output l0_o_full;
    output l0_o_ready;
    output ofifo_o_full;
    output ofifo_o_ready;
    output ofifo_valid;
    output [col*psum_bw-1:0] ofifo_out;
    output [psum_bw*col-1:0] final_out;
    output ififo_o_full;
    output ififo_o_ready;
    output ififo_signals;

    wire [psum_bw*col-1:0] Array2ofifo_out;
    wire [psum_bw*col-1:0] Array2ofifo_out_WS;
    wire [psum_bw*col-1:0] Array2ofifo_out_OS;
    wire [psum_bw*col-1:0] sfu_out;
    assign final_out = mode ? ofifo_out : sfu_out;
    assign Array2ofifo_out = mode ? Array2ofifo_out_OS : Array2ofifo_out_WS;

    wire [row*bw-1:0] l02Array_in_w;
    wire [col-1:0] Array2ofifo_valid;
    wire [col*bw-1:0] l02Array_in_n;
    wire [col*bw-1:0] ififo2Array_in_n;
    wire [col*psum_bw-1:0] ififo2Array_in_n_padded;
    wire [col*psum_bw-1:0] Array_in_n;
    

    assign ififo2Array_in_n_padded = 
    {
        12'b000000000000, ififo2Array_in_n[31:28],
        12'b000000000000, ififo2Array_in_n[27:24],
        12'b000000000000, ififo2Array_in_n[23:20],
        12'b000000000000, ififo2Array_in_n[19:16],
        12'b000000000000, ififo2Array_in_n[15:12],
        12'b000000000000, ififo2Array_in_n[11:8],
        12'b000000000000, ififo2Array_in_n[7:4],
        12'b000000000000, ififo2Array_in_n[3:0]
    };
    assign Array_in_n = mode ? ififo2Array_in_n_padded : 0;

    wire [col-1:0] loop;

    l0 #(
    .row(row),
    .bw(bw)
    ) l0_instance (
    .clk(clk),
    .wr(inst[2]),
    .rd(inst[3]),
    .reset(reset),
    .in(l0_in),
    .out(l02Array_in_w),
    .o_full(l0_o_full),
    .o_ready(l0_o_ready),
    .l0_version(l0_version)
    );

    mac_array #(
    .bw(bw),
    .psum_bw(psum_bw),
    .col(col),
    .row(row)
    ) mac_array_instance (
    .clk(clk),
    .reset(reset),
    .out_s(Array2ofifo_out_WS),       
    .in_w(l02Array_in_w),             
    .inst_w(inst[1:0]),               
    .in_n(Array_in_n),          
    .mode(mode),  
    .OS_out(Array2ofifo_out_OS),       
    .loop(loop),       
    .valid(Array2ofifo_valid)        
    );


    
    
    ofifo #(
    .col(col),
    .bw(psum_bw)
    ) ofifo_instance (
    .clk(clk),
    .wr(Array2ofifo_valid),           
    .rd(inst[6]),                     
    .reset(reset),                    
    .in(Array2ofifo_out),             
    .out(ofifo_out),                  
    .o_full(ofifo_o_full),            
    .o_ready(ofifo_o_ready),          
    .o_valid(ofifo_valid)            
    );


    
    
    ififo #(
    .col(col),
    .bw(bw)
    ) ififo_instance (
    .clk(clk),
    .wr(inst[5]),                     
    .rd(inst[4]),                     
    .reset(reset),                    
    .in(ififo_in),             
    .out(ififo2Array_in_n),                  
    .o_full(ififo_o_full),            
    .o_ready(ififo_o_ready),          
    .loop_flag(loop),
    .o_valid(ififo_signals)            
    );


    
    
    sfu #(
    .psum_bw(psum_bw),
    .col(col)
    ) sfu_instance (
    .clk(clk),
    .reset(reset),
    .acc_q(inst[33]),                  
    .sfu_in(sfu_in),                   
    .sfu_out(sfu_out)                 
    
    );


endmodule
