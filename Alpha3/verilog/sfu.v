module sfu (clk, reset, mode, sfu_in, sfu_out);

  parameter psum_bw = 16;
  parameter col = 8;
  parameter signed thres = 8'b00000000;

  input  clk, reset;
  input  mode; // 0: ReLU/Overwrite, 1: accumulate
  input  signed [psum_bw*col-1:0] sfu_in; // From SRAM
  output reg signed [psum_bw*col-1:0] sfu_out;  // To SRAM

  always @(posedge clk) begin
    if (reset) begin
      sfu_out <= 0;
    end
    else begin
      if (mode) begin
        // Accumulation
        sfu_out[psum_bw*1-1:psum_bw*0] <= $signed(sfu_out[psum_bw*1-1:psum_bw*0]) + $signed(sfu_in[psum_bw*1-1:psum_bw*0]);
        sfu_out[psum_bw*2-1:psum_bw*1] <= $signed(sfu_out[psum_bw*2-1:psum_bw*1]) + $signed(sfu_in[psum_bw*2-1:psum_bw*1]);
        sfu_out[psum_bw*3-1:psum_bw*2] <= $signed(sfu_out[psum_bw*3-1:psum_bw*2]) + $signed(sfu_in[psum_bw*3-1:psum_bw*2]);
        sfu_out[psum_bw*4-1:psum_bw*3] <= $signed(sfu_out[psum_bw*4-1:psum_bw*3]) + $signed(sfu_in[psum_bw*4-1:psum_bw*3]);
        sfu_out[psum_bw*5-1:psum_bw*4] <= $signed(sfu_out[psum_bw*5-1:psum_bw*4]) + $signed(sfu_in[psum_bw*5-1:psum_bw*4]);
        sfu_out[psum_bw*6-1:psum_bw*5] <= $signed(sfu_out[psum_bw*6-1:psum_bw*5]) + $signed(sfu_in[psum_bw*6-1:psum_bw*5]);
        sfu_out[psum_bw*7-1:psum_bw*6] <= $signed(sfu_out[psum_bw*7-1:psum_bw*6]) + $signed(sfu_in[psum_bw*7-1:psum_bw*6]);
        sfu_out[psum_bw*8-1:psum_bw*7] <= $signed(sfu_out[psum_bw*8-1:psum_bw*7]) + $signed(sfu_in[psum_bw*8-1:psum_bw*7]);
      end
      else begin
        // ReLU
        sfu_out[psum_bw*1-1:psum_bw*0] <= ($signed(sfu_out[psum_bw*1-1:psum_bw*0]) > thres) ? sfu_out[psum_bw*1-1:psum_bw*0]: 0;
        sfu_out[psum_bw*2-1:psum_bw*1] <= ($signed(sfu_out[psum_bw*2-1:psum_bw*1]) > thres) ? sfu_out[psum_bw*2-1:psum_bw*1] : 0;
        sfu_out[psum_bw*3-1:psum_bw*2] <= ($signed(sfu_out[psum_bw*3-1:psum_bw*2]) > thres) ? sfu_out[psum_bw*3-1:psum_bw*2] : 0;
        sfu_out[psum_bw*4-1:psum_bw*3] <= ($signed(sfu_out[psum_bw*4-1:psum_bw*3]) > thres) ? sfu_out[psum_bw*4-1:psum_bw*3] : 0;
        sfu_out[psum_bw*5-1:psum_bw*4] <= ($signed(sfu_out[psum_bw*5-1:psum_bw*4]) > thres) ? sfu_out[psum_bw*5-1:psum_bw*4] : 0;
        sfu_out[psum_bw*6-1:psum_bw*5] <= ($signed(sfu_out[psum_bw*6-1:psum_bw*5]) > thres) ? sfu_out[psum_bw*6-1:psum_bw*5] : 0;
        sfu_out[psum_bw*7-1:psum_bw*6] <= ($signed(sfu_out[psum_bw*7-1:psum_bw*6]) > thres) ? sfu_out[psum_bw*7-1:psum_bw*6] : 0;
        sfu_out[psum_bw*8-1:psum_bw*7] <= ($signed(sfu_out[psum_bw*8-1:psum_bw*7]) > thres) ? sfu_out[psum_bw*8-1:psum_bw*7] : 0;
      end
    end
  end

endmodule
