// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array (clk, reset, out_s, in_w, in_n, inst_w, mac_mode, valid, out_output, ififo_loop, out_output_valid, out_output);

  parameter bw = 4;
  parameter psum_bw = 16;
  parameter col = 8;
  parameter row = 8;

  input  clk, reset;
  output [psum_bw*col-1:0] out_s;
  input  [row*bw-1:0] in_w; // inst[1]:execute, inst[0]: kernel loading
  input  [1:0] inst_w;
  input  [psum_bw*col-1:0] in_n;
  output [col-1:0] valid;
  input  mac_mode;
  output [psum_bw*col-1:0] out_output;
  output [col-1:0] ififo_loop;
  output reg [col-1:0] out_output_valid;

  reg    [2*row-1:0] inst_w_temp;
  wire   [psum_bw*col*(row+1)-1:0] temp;
  wire   [row*col-1:0] valid_temp;
  wire   [row*col-1:0] ififo_loop_temp;
  wire   [psum_bw*col*row-1:0] out_output_temp;
  wire   [row*col-1:0] out_output_valid_temp;

  reg [psum_bw-1:0] out_output_col0;
  reg [psum_bw-1:0] out_output_col1;
  reg [psum_bw-1:0] out_output_col2;
  reg [psum_bw-1:0] out_output_col3;
  reg [psum_bw-1:0] out_output_col4;
  reg [psum_bw-1:0] out_output_col5;
  reg [psum_bw-1:0] out_output_col6;
  reg [psum_bw-1:0] out_output_col7;

  assign out_output = {out_output_col7, out_output_col6, out_output_col5, out_output_col4, out_output_col3, out_output_col2, out_output_col1, out_output_col0};

  wire [row-1:0] out_output_valid_col0;
  wire [row-1:0] out_output_valid_col1;
  wire [row-1:0] out_output_valid_col2;
  wire [row-1:0] out_output_valid_col3;
  wire [row-1:0] out_output_valid_col4;
  wire [row-1:0] out_output_valid_col5;
  wire [row-1:0] out_output_valid_col6;
  wire [row-1:0] out_output_valid_col7;
 
  assign out_output_valid_col0 = {out_output_valid_temp[56], out_output_valid_temp[48], out_output_valid_temp[40], out_output_valid_temp[32], out_output_valid_temp[24], out_output_valid_temp[16], out_output_valid_temp[8], out_output_valid_temp[0]};
  assign out_output_valid_col1 = {out_output_valid_temp[57], out_output_valid_temp[49], out_output_valid_temp[41], out_output_valid_temp[33], out_output_valid_temp[25], out_output_valid_temp[17], out_output_valid_temp[9], out_output_valid_temp[1]};
  assign out_output_valid_col2 = {out_output_valid_temp[58], out_output_valid_temp[50], out_output_valid_temp[42], out_output_valid_temp[34], out_output_valid_temp[26], out_output_valid_temp[18], out_output_valid_temp[10], out_output_valid_temp[2]};
  assign out_output_valid_col3 = {out_output_valid_temp[59], out_output_valid_temp[51], out_output_valid_temp[43], out_output_valid_temp[35], out_output_valid_temp[27], out_output_valid_temp[19], out_output_valid_temp[11], out_output_valid_temp[3]};
  assign out_output_valid_col4 = {out_output_valid_temp[60], out_output_valid_temp[52], out_output_valid_temp[44], out_output_valid_temp[36], out_output_valid_temp[28], out_output_valid_temp[20], out_output_valid_temp[12], out_output_valid_temp[4]};
  assign out_output_valid_col5 = {out_output_valid_temp[61], out_output_valid_temp[53], out_output_valid_temp[45], out_output_valid_temp[37], out_output_valid_temp[29], out_output_valid_temp[21], out_output_valid_temp[13], out_output_valid_temp[5]};
  assign out_output_valid_col6 = {out_output_valid_temp[62], out_output_valid_temp[54], out_output_valid_temp[46], out_output_valid_temp[38], out_output_valid_temp[30], out_output_valid_temp[22], out_output_valid_temp[14], out_output_valid_temp[6]};
  assign out_output_valid_col7 = {out_output_valid_temp[63], out_output_valid_temp[55], out_output_valid_temp[47], out_output_valid_temp[39], out_output_valid_temp[31], out_output_valid_temp[23], out_output_valid_temp[15], out_output_valid_temp[7]};

  assign out_s = temp[psum_bw*col-1:0];
  assign temp[psum_bw*col-1:0] = in_n;
  assign valid = mac_mode? out_output_valid : valid_temp[col*row-1:col*row-8];
  assign ififo_loop = ififo_loop_temp[col-1:0];

  genvar i;
  for (i=1; i < row+1 ; i=i+1) begin : row_num
      mac_row #(.bw(bw), .psum_bw(psum_bw)) mac_row_instance (
        .clk(clk),
        .reset(reset),
        .in_w(in_w[bw*i-1:bw*(i-1)]),
        .inst_w(inst_w_temp[2*i-1:2*(i-1)]),
        .in_n(temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),
        .valid(valid_temp[col*i-1:col*(i-1)]),
        .out_s(temp[psum_bw*col*(i+1)-1:psum_bw*col*(i)]),
        .mac_mode(mac_mode),
        .out_output(out_output_temp[psum_bw*col*i-1:psum_bw*col*(i-1)]),
        .ififo_loop(ififo_loop_temp[col*i-1:col*(i-1)]),
        .out_output_valid(out_output_valid_temp[col*i-1:col*(i-1)])
      );
  end

  always @(posedge clk) begin
    out_output_valid <= {|out_output_valid_col7, |out_output_valid_col6, |out_output_valid_col5, |out_output_valid_col4, |out_output_valid_col3, |out_output_valid_col2, |out_output_valid_col1, |out_output_valid_col0};
    case(out_output_valid_col0)
      8'b00000001: out_output_col0 <= out_output_temp[15:0];
      8'b00000010: out_output_col0 <= out_output_temp[143:128];
      8'b00000100: out_output_col0 <= out_output_temp[271:256];
      8'b00001000: out_output_col0 <= out_output_temp[399:384];
      8'b00010000: out_output_col0 <= out_output_temp[527:512];
      8'b00100000: out_output_col0 <= out_output_temp[655:640];
      8'b01000000: out_output_col0 <= out_output_temp[783:768];
      8'b10000000: out_output_col0 <= out_output_temp[911:896];
    endcase

    case(out_output_valid_col1)
      8'b00000001: out_output_col1 <= out_output_temp[31:16];
      8'b00000010: out_output_col1 <= out_output_temp[159:144];
      8'b00000100: out_output_col1 <= out_output_temp[287:272];
      8'b00001000: out_output_col1 <= out_output_temp[415:400];
      8'b00010000: out_output_col1 <= out_output_temp[543:528];
      8'b00100000: out_output_col1 <= out_output_temp[671:656];
      8'b01000000: out_output_col1 <= out_output_temp[799:784];
      8'b10000000: out_output_col1 <= out_output_temp[927:912];
    endcase

    case(out_output_valid_col2)
      8'b00000001: out_output_col2 <= out_output_temp[47:32];
      8'b00000010: out_output_col2 <= out_output_temp[175:160];
      8'b00000100: out_output_col2 <= out_output_temp[303:288];
      8'b00001000: out_output_col2 <= out_output_temp[431:416];
      8'b00010000: out_output_col2 <= out_output_temp[559:544];
      8'b00100000: out_output_col2 <= out_output_temp[687:672];
      8'b01000000: out_output_col2 <= out_output_temp[815:800];
      8'b10000000: out_output_col2 <= out_output_temp[943:928];
    endcase

    case(out_output_valid_col3)
      8'b00000001: out_output_col3 <= out_output_temp[63:48];
      8'b00000010: out_output_col3 <= out_output_temp[191:176];
      8'b00000100: out_output_col3 <= out_output_temp[319:304];
      8'b00001000: out_output_col3 <= out_output_temp[447:432];
      8'b00010000: out_output_col3 <= out_output_temp[575:560];
      8'b00100000: out_output_col3 <= out_output_temp[703:688];
      8'b01000000: out_output_col3 <= out_output_temp[831:816];
      8'b10000000: out_output_col3 <= out_output_temp[959:944];
    endcase

    case(out_output_valid_col4)
      8'b00000001: out_output_col4 <= out_output_temp[79:64];
      8'b00000010: out_output_col4 <= out_output_temp[207:192];
      8'b00000100: out_output_col4 <= out_output_temp[335:320];
      8'b00001000: out_output_col4 <= out_output_temp[463:448];
      8'b00010000: out_output_col4 <= out_output_temp[591:576];
      8'b00100000: out_output_col4 <= out_output_temp[719:704];
      8'b01000000: out_output_col4 <= out_output_temp[847:832];
      8'b10000000: out_output_col4 <= out_output_temp[975:960];
    endcase

    case(out_output_valid_col5)
      8'b00000001: out_output_col5 <= out_output_temp[95:80];
      8'b00000010: out_output_col5 <= out_output_temp[223:208];
      8'b00000100: out_output_col5 <= out_output_temp[351:336];
      8'b00001000: out_output_col5 <= out_output_temp[479:464];
      8'b00010000: out_output_col5 <= out_output_temp[607:592];
      8'b00100000: out_output_col5 <= out_output_temp[735:720];
      8'b01000000: out_output_col5 <= out_output_temp[863:848];
      8'b10000000: out_output_col5 <= out_output_temp[991:976];
    endcase

    case(out_output_valid_col6)
      8'b00000001: out_output_col6 <= out_output_temp[111:96];
      8'b00000010: out_output_col6 <= out_output_temp[239:224];
      8'b00000100: out_output_col6 <= out_output_temp[367:352];
      8'b00001000: out_output_col6 <= out_output_temp[495:480];
      8'b00010000: out_output_col6 <= out_output_temp[623:608];
      8'b00100000: out_output_col6 <= out_output_temp[751:736];
      8'b01000000: out_output_col6 <= out_output_temp[879:864];
      8'b10000000: out_output_col6 <= out_output_temp[1007:992];
    endcase

    case(out_output_valid_col7)
      8'b00000001: out_output_col7 <= out_output_temp[127:112];
      8'b00000010: out_output_col7 <= out_output_temp[255:240];
      8'b00000100: out_output_col7 <= out_output_temp[383:368];
      8'b00001000: out_output_col7 <= out_output_temp[511:496];
      8'b00010000: out_output_col7 <= out_output_temp[639:624];
      8'b00100000: out_output_col7 <= out_output_temp[767:752];
      8'b01000000: out_output_col7 <= out_output_temp[895:880];
      8'b10000000: out_output_col7 <= out_output_temp[1023:1008];
    endcase
end
  always @ (posedge clk) begin


    //valid <= valid_temp[row*col-1:row*col-8];
    inst_w_temp[1:0]   <= inst_w; 
    inst_w_temp[3:2]   <= inst_w_temp[1:0]; 
    inst_w_temp[5:4]   <= inst_w_temp[3:2]; 
    inst_w_temp[7:6]   <= inst_w_temp[5:4]; 
    inst_w_temp[9:8]   <= inst_w_temp[7:6]; 
    inst_w_temp[11:10] <= inst_w_temp[9:8]; 
    inst_w_temp[13:12] <= inst_w_temp[11:10]; 
    inst_w_temp[15:14] <= inst_w_temp[13:12]; 
  end


endmodule
