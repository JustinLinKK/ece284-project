module corelet (clk,
                reset,
                ofifo_valid,
                sfu_in,
                core_out,
                inst,
                l0_in,
                l0_full,
                l0_ready,
                ofifo_out,
                ofifo_full,
                ofifo_ready,
                ififo_in,
                ififo_full,
                ififo_ready,
                ififo_valid,
                l0_version,
                mac_mode);

    // Parameters for corelet configuration
    parameter row     = 8;   // Number of rows in the L0 buffer and MAC array
    parameter col     = 8;   // Number of columns in the MAC array and OFIFO
    parameter bw      = 4;   // Bit-width of input weights and activations
    parameter psum_bw = 16;  // Bit-width of partial sums

  input  clk;
  input  reset;
  
  // L0 interface
  input  [row*bw-1:0] l0_in;
  wire [col*bw-1:0] l02mac_in_n;
  wire [col*bw-1:0] l02mac_in_w;
  input  [33:0] inst;
  input  l0_version;
  output l0_full;
  output l0_ready;
  
  // Core control
  wire   [1:0] inst_w;
  wire   acc_mode;
  wire   l0_wr;
  output [psum_bw*col-1:0] core_out;
  
  // OFIFO interface
  wire   ofifo_rd;
  output [col*psum_bw-1:0] ofifo_out;
  output ofifo_full;
  output ofifo_ready;
  output ofifo_valid;

  //IFIFO interface
  wire   [col*psum_bw-1:0] ififo2mac_in_w;
  input  mac_mode;
  input [col*bw-1:0] ififo_in;
  output ififo_valid;
  output ififo_ready;
  output ififo_full;
  wire [col-1:0] ififo_loop;


  // PMEM interface
  input  [col*psum_bw-1:0] sfu_in;
  output [col*psum_bw-1:0] sfu_out;

  wire [row*bw-1:0] l0_out;
  wire l0_rd; 

  wire [psum_bw*col-1:0] mac_in_n;
  wire [col*psum_bw-1:0] mac2ofifo_out; // Data from MAC array to OFIFO
  wire [col*psum_bw-1:0] mac2ofifo_out_weight; // Data from MAC array to OFIFO in Weight Stationary mode
  wire [col*psum_bw-1:0] mac2ofifo_out_output; // Data from MAC array to OFIFO in Output Stationary mode
  wire [col*psum_bw-1:0] sfu_out_wire;
  wire [col-1:0] mac_valid;
  wire [col*bw-1:0] ififo2mac_in_n;
  wire [col*psum_bw-1:0] ififo2mac_in_n_padded;

  

  assign acc_mode = inst[33];
  assign ofifo_rd = inst[6];
  assign l0_wr    = inst[2];
  assign inst_w   = inst[1:0];
  
  assign l0_rd = (inst_w[0] || inst_w[1]); 

  assign ififo2mac_in_n_padded = 
    {
        12'b000000000000, ififo2mac_in_n[31:28],
        12'b000000000000, ififo2mac_in_n[27:24],
        12'b000000000000, ififo2mac_in_n[23:20],
        12'b000000000000, ififo2mac_in_n[19:16],
        12'b000000000000, ififo2mac_in_n[15:12],
        12'b000000000000, ififo2mac_in_n[11:8],
        12'b000000000000, ififo2mac_in_n[7:4],
        12'b000000000000, ififo2mac_in_n[3:0]
    };
  assign mac_in_n = mac_mode ? ififo2mac_in_n_padded : 0;
  assign final_out = mac_mode ? ofifo_out : sfu_out;
  assign mac2ofifo_out = mac_mode ? mac2ofifo_out_output : mac2ofifo_out_weight;



  l0 #(.row(row), .bw(bw)) l0_instance (
    .clk(clk),
    .reset(reset),
    .o_ready(l0_ready),
    .l0_version(l0_version),
    .in(l0_in),
    .out(l0_out),
    .rd(l0_rd),
    .wr(l0_wr),
    .o_full(l0_full)
  );

  mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance (
    .clk(clk), 
    .reset(reset), 
    .out_s(mac2ofifo_out_weight), 
    .in_w(l0_out), 
    .in_n(mac_in_n), 
    .inst_w(inst_w),
    .mac_mode(mac_mode), 
    .out_output(mac2ofifo_out_output),
    .ififo_loop(ififo_loop),
    .valid(mac_valid)
  );

  sfu #(.psum_bw(psum_bw), .col(col)) sfu_instance (
    .clk(clk),
    .reset(reset),
    .mode(inst[33]),               
    .sfu_in(sfu_in),                   
    .sfu_out(sfu_out_wire)
  );

  ofifo #(.col(col), .bw(psum_bw)) ofifo_instance (
    .clk(clk),
    .in(mac2ofifo_out),
    .out(ofifo_out),
    .rd(ofifo_rd),
    .wr(mac_valid),
    .o_full(ofifo_full),
    .reset(reset),
    .o_ready(ofifo_ready),
    .o_valid(ofifo_valid)
  );

  ififo #(.col(row), .bw(bw)) ififo_instance (
    .clk(clk),
    .reset(reset),
    .o_ready(ififo_ready),
    .o_valid(ififo_valid),
    .in(ififo_in),
    .out(ififo2mac_in_n),
    .rd(inst[4]),
    .wr(inst[5]),
    .o_full(ififo_full),
    .ififo_loop(ififo_loop)
  );

endmodule
