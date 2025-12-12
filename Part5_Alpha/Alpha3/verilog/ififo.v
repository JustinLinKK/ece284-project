module ififo (clk,
           in,
           out,
           rd,
           wr,
           o_full,
           reset,
           o_ready,
           ififo_loop,
           o_valid);

  parameter col  = 8;
  parameter bw = 4;

  input  clk;
  input  wr;
  input  rd;
  input  reset;
  input  [col*bw-1:0] in;
  output [col*bw-1:0] out;
  output o_full;
  output o_ready;
  output o_valid;
  input [col-1:0] ififo_loop;
  wire [col-1:0] empty;
  wire [col-1:0] full;
  reg  [col-1:0] rd_en;
  
  genvar i;

  assign o_ready = !o_full ;
  assign o_full  = |full ;
  assign o_valid = !(|empty) ;

   generate
   for (i = 0; i<col ; i = i+1) begin : col_num
   fifo_depth64 #(.bw(bw)) fifo_instance (
   .rd_clk(clk),
   .wr_clk(clk),
   .rd(rd_en[i]),
   .wr(wr),
   .o_empty(empty[i]),
   .o_full(full[i]),
   .in(in[bw*(i+1)-1:bw*i]),
   .out(out[bw*(i+1)-1:bw*i]),
   .rd_ptr_reset(ififo_loop[i]),
   .reset(reset));
   end
   endgenerate


  always @ (posedge clk) begin
   if (reset) begin
      rd_en <= 0;
   end
   else begin
      rd_en <= {col{rd}};
   end
  end

endmodule