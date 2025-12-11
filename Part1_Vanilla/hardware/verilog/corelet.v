module corelet (clk, reset, l0_in, l0_full, l0_ready, inst, ofifo_out, ofifo_full, ofifo_ready, ofifo_valid, sfu_in, sfu_out, l0_version);

  parameter row = 8;
  parameter col = 8;
  parameter bw = 4;
  parameter psum_bw = 16;

  input  clk;
  input  reset;
  
  // L0 interface
  input  [row*bw-1:0] l0_in;
  input  [33:0] inst;
  input  l0_version;
  output l0_full;
  output l0_ready;
  
  // Core control
  wire   [1:0] inst_w;
  wire   acc_mode;
  wire   l0_wr;
  
  // OFIFO interface
  wire   ofifo_rd;
  output [col*psum_bw-1:0] ofifo_out;
  output ofifo_full;
  output ofifo_ready;
  output ofifo_valid;

  // SFU interface
  input  [col*psum_bw-1:0] sfu_in;
  output [col*psum_bw-1:0] sfu_out;

  wire [row*bw-1:0] l0_out;
  wire l0_rd; 
  
  wire [col*psum_bw-1:0] mac_out;
  wire [col-1:0] mac_valid;

  assign ofifo_rd = inst[6];
  assign l0_wr    = inst[2];
  assign inst_w   = inst[1:0];
  assign l0_rd = inst[3]; 

  l0 #(.row(row), .bw(bw)) l0_instance (
    .clk(clk),
    .in(l0_in),
    .out(l0_out),
    .rd(l0_rd),
    .wr(l0_wr),
    .o_full(l0_full),
    .reset(reset),
    .o_ready(l0_ready),
    .l0_version(l0_version)
  );

  mac_array #(.bw(bw), .psum_bw(psum_bw), .col(col), .row(row)) mac_array_instance (
    .clk(clk), 
    .reset(reset), 
    .out_s(mac_out), 
    .in_w(l0_out), 
    .in_n({col*psum_bw{1'b0}}), 
    .inst_w(inst_w), 
    .valid(mac_valid)
  );

  sfu #(.psum_bw(psum_bw), .col(col)) sfu_instance (
    .clk(clk),
    .reset(reset),
    .mode(inst[33]),               
    .sfu_in(sfu_in),                   
    .sfu_out(sfu_out)
  );

  ofifo #(.col(col), .bw(psum_bw)) ofifo_instance (
    .clk(clk),
    .in(mac_out),
    .out(ofifo_out),
    .rd(ofifo_rd),
    .wr(mac_valid),
    .o_full(ofifo_full),
    .reset(reset),
    .o_ready(ofifo_ready),
    .o_valid(ofifo_valid)
  );

endmodule
