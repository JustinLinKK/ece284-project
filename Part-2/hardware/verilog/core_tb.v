// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
`timescale 1ns/1ps

module core_tb;

parameter bw = 4;
parameter psum_bw = 16;
parameter len_kij = 9;
parameter len_onij = 16;
parameter col = 8;
parameter row = 8;
parameter len_nij = 36;
parameter a_pad_ni_dim = 6;
parameter o_ni_dim     = 4;
parameter ki_dim       = 3;

reg clk = 0;
reg reset = 1;

wire [33:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row-1:0] D_xmem_q = 0;

// activation memory
reg CEN_xmem = 0;
reg WEN_xmem = 0;
reg [10:0] A_xmem = 0;
reg CEN_xmem_q = 0;
reg WEN_xmem_q = 0;
reg [10:0] A_xmem_q = 0;

// psum memory
reg CEN_pmem = 0;
reg WEN_pmem = 0;
reg [10:0] A_pmem = 0;
reg CEN_pmem_q = 0;
reg WEN_pmem_q = 0;
reg [10:0] A_pmem_q = 0;

reg ofifo_rd_q = 0;
reg ififo_wr_q = 0;
reg ififo_rd_q = 0;
reg l0_rd_q = 0;
reg l0_wr_q = 0;
reg execute_q = 0;
reg load_q = 0;
reg acc_q = 0;
reg acc = 0;
reg l0_version = 1;
reg mode = 1; // 1: 2-bit mode, 0: 4-bit mode

reg [1:0]  inst_w; 
reg [bw*row-1:0] D_xmem;
reg [psum_bw*col*2-1:0] answer;




reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*256:1] w_file_name;
reg l0_version_q;
reg mode_q;
wire ofifo_valid;
wire ofifo_ready;
wire ofifo_full;
wire l0_ready;
wire l0_full;
wire [col*psum_bw-1:0] sfu_out;


integer x_file, x_scan_file ; // file_handler
integer w_file, w_scan_file ; // file_handler
integer acc_file, acc_scan_file ; // file_handler
integer out_file, out_scan_file ; // file_handler
integer captured_data; 
integer t, i, j, k, kij, oc, otile, max_otiles;
integer error;

assign inst_q[33] = acc_q;
assign inst_q[32] = CEN_pmem_q;
assign inst_q[31] = WEN_pmem_q;
assign inst_q[30:20] = A_pmem_q;
assign inst_q[19]   = CEN_xmem_q;
assign inst_q[18]   = WEN_xmem_q;
assign inst_q[17:7] = A_xmem_q;
assign inst_q[6]   = ofifo_rd_q;
assign inst_q[5]   = ififo_wr_q;
assign inst_q[4]   = ififo_rd_q;
assign inst_q[3]   = l0_rd_q;
assign inst_q[2]   = l0_wr_q;
assign inst_q[1]   = execute_q; 
assign inst_q[0]   = load_q; 
assign answer_tile0 = answer[psum_bw*col*1-1:0];
assign answer_tile1 = answer[psum_bw*col*2-1:psum_bw*col*1];


core  #(.bw(bw), .col(col), .row(row)) core_instance (
	.clk(clk), 
	.inst(inst_q),
	.ofifo_valid(ofifo_valid),
  .ofifo_ready(ofifo_ready),
  .ofifo_full(ofifo_full),
  .l0_ready(l0_ready),
  .l0_full(l0_full),
  .D_xmem(D_xmem_q), 
  .sfu_out(sfu_out), 
  .l0_version(l0_version_q),
  .mode(mode_q),
	.reset(reset)
  ); 


initial begin 

  inst_w   = 0; 
  D_xmem   = 0;
  CEN_xmem = 1;
  WEN_xmem = 1;
  A_xmem   = 0;
  ofifo_rd = 0;
  ififo_wr = 0;
  ififo_rd = 0;
  l0_rd    = 0;
  l0_wr    = 0;
  execute  = 0;
  load     = 0;
  l0_version = 1;

  $dumpfile("core_tb.vcd");
  $dumpvars(0,core_tb);

  x_file = $fopen($sformatf("./mode%d/activation_tile0.txt", mode), "r");

  //////// Reset /////////
  #0.5 clk = 1'b0;   reset = 1;
  #0.5 clk = 1'b1;
  
  for (i = 0; i<10 ; i = i+1) begin
      #0.5 clk = 1'b0;
      #0.5 clk = 1'b1;
  end
  
  #0.5 clk = 1'b0;   reset = 0;
  #0.5 clk = 1'b1;
  
  #0.5 clk = 1'b0;
  #0.5 clk = 1'b1;   
  /////////////////////////

  /////// Activation data writing to memory ///////
  for (t = 0; t<len_nij; t = t+1) begin
      #0.5 clk        = 1'b0;
      x_scan_file     = $fscanf(x_file,"%32b", D_xmem);
      WEN_xmem        = 0;
      CEN_xmem        = 0;
      if (t>0) A_xmem = A_xmem + 1;
      #0.5 clk        = 1'b1;
  end
  #0.5 clk = 1'b0;
  WEN_xmem = 1;
  CEN_xmem = 1;
  A_xmem   = 0;
  #0.5 clk = 1'b1;
  
  $fclose(x_file);
  /////////////////////////////////////////////////

  // output channel tiles in different modes

  if (mode == 0) begin
    $display("######################## 4-bit mode running #########################");
    max_otiles = 1;  // 4-bit mode: no need to tile
  end
  else begin
    $display("######################## 2-bit mode running #########################");
    max_otiles = 2; // 2bit mode: need to tile 2 times for 8 output channels
  end


  for (otile=0; otile<max_otiles; otile=otile+1) begin
    for (kij=0; kij<9; kij=kij+1) begin  // kij loop
        $sformat(w_file_name,
                "./mode%0d/weight_itile0_otile%0d_kij%0d.txt",
                mode, otile, kij);
        w_file = $fopen(w_file_name, "r");

        #0.5 clk = 1'b0;
        reset    = 1;
        #0.5 clk = 1'b1;
        
        for (i = 0; i<10 ; i = i+1) begin
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end
        
        #0.5 clk = 1'b0;
        reset    = 0;
        #0.5 clk = 1'b1;
        
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;  

        /////// Kernel data writing to memory ///////

        A_xmem = 11'b10000000000;
        if (mode == 0) begin
        for (t = 0; t<col; t = t+1) begin   // load into xmem
            #0.5 clk        = 1'b0;
            w_scan_file     = $fscanf(w_file,"%32b", D_xmem);
            WEN_xmem        = 0;
            CEN_xmem        = 0;
            if (t>0) A_xmem = A_xmem + 1;
            #0.5 clk        = 1'b1;
        end
        end
        else begin
        for (t = 0; t<col*2; t = t+1) begin   // load into xmem
            #0.5 clk        = 1'b0;
            w_scan_file     = $fscanf(w_file,"%32b", D_xmem);
            WEN_xmem        = 0;
            CEN_xmem        = 0;
            if (t>0) A_xmem = A_xmem + 1;
            #0.5 clk        = 1'b1;
        end
        end

        
        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 1;
        A_xmem   = 0;
        #0.5 clk = 1'b1;
        /////////////////////////////////////
        for (i = 0; i<10 ; i = i+1) begin
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end


        /////// Kernel data writing to L0 ///////
        A_xmem = 11'b10000000000;
                
        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 0; // xmem read operation
        #0.5 clk = 1'b1;
        if (mode == 0) begin
        // 4bit mode loading structure:
        // l0 col1: input channel1 W1, W2, W3....W8
        // l0 col2: input channel2 W1, W2, W3....W8
        // ...
        // l0 col8: ...
        // In this case: PE mac = W1 x A1
        for (t = 0; t<col; t = t+1) begin
            #0.5 clk        = 1'b0;
            l0_wr           = 1;
            if (t>0) A_xmem = A_xmem + 1;
            #0.5 clk        = 1'b1;
        end
        end
        else begin
        // 2bit mode loading structure:
        // l0 col1: input channel1 W1, W3, W5....W15
        // l0 col2: input channel1 W2, W4, W6....W16
        // l0 col3: input channel2 W1, W3, W5....W15
        // l0 col4: input channel2 W2, W4, W6....W16
        // ...
        // l0 col6: ...
        // In thise case: PE mac = W1 x A1 + W2 x A2
        for (t = 0; t<col*2; t = t+1) begin
            #0.5 clk        = 1'b0;
            l0_wr           = 1;
            if (t>0) A_xmem = A_xmem + 1;
            #0.5 clk        = 1'b1;
        end
        end
        
        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 1;
        A_xmem   = 0;
        #0.5 clk = 1'b1;
        #0.5 clk = 1'b0;
        l0_wr    = 0;
        #0.5 clk = 1'b1;
        
        for (i = 0; ~l0_full&&i<10; i = i+1) begin
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end
        /////////////////////////////////////


        /////// Kernel loading to PEs ///////
        
        // From LO to PE
        #0.5 clk = 1'b0;
        l0_rd    = 1;
        #0.5 clk = 1'b1;
        
        if (mode == 0) begin
            for (t = 0; t<col; t = t+1) begin
                #0.5 clk = 1'b0;
                load     = 1;  // load weight into mac_array
                #0.5 clk = 1'b1;
            end
        end
        else begin
            for (t = 0; t<2*col; t = t+1) begin
                #0.5 clk = 1'b0;
                load     = 1;  // load weight into mac_array
                #0.5 clk = 1'b1;
            end
        end

        /////////////////////////////////////

        ////// provide some intermission to clear up the kernel loading ///
        #0.5 clk = 1'b0;  
        load = 0; 
        l0_rd = 0;
        #0.5 clk = 1'b1;  

        for (i=0; i<10 ; i=i+1) begin
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;
        end
        /////////////////////////////////////



        /////// Activation data writing to L0 ///////
        A_xmem   = 0;
        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 0; // xmem read operation
        #0.5 clk = 1'b1;
        
        for (t = 0; t<len_nij; t = t+1) begin
            #0.5 clk        = 1'b0;
            l0_wr           = 1;
            if (t>0) A_xmem = A_xmem + 1;
            #0.5 clk        = 1'b1;
        end
        
        #0.5 clk = 1'b0;
        WEN_xmem = 1;
        CEN_xmem = 1;
        A_xmem   = 0;
        #0.5 clk = 1'b1;
        #0.5 clk = 1'b0;
        l0_wr    = 0;
        #0.5 clk = 1'b1;

        /////////////////////////////////////

        /////// Execution ///////
        /////////////////////////////////////
        #0.5 clk = 1'b0;
        l0_rd    = 1;
        #0.5 clk = 1'b1;
        
        
        for (t = 0; t<len_nij; t = t+1) begin
            #0.5 clk = 1'b0;
            execute  = 1;
            #0.5 clk = 1'b1;
        end
        
        for (t = 0; t<row+col; t = t+1) begin  //  drain cycles to let the final computations complete
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
        end
        
        #0.5 clk = 1'b0;
        l0_rd    = 0;
        execute  = 0;
        #0.5 clk = 1'b1;

        //////// OFIFO READ ////////
        // Ideally, OFIFO should be read while execution, but we have enough ofifo
        // depth so we can fetch out after execution.
        #0.5 clk = 1'b0;
        ofifo_rd = 1;
        #0.5 clk = 1'b1;

        for (t = 0; t<len_nij; t = t+1) begin   // Store to pmem
            #0.5 clk                   = 1'b0;
            WEN_pmem                   = 0; //PMEM read enable
            CEN_pmem                   = 0; 
            if (t>0 | A_pmem>0) A_pmem = A_pmem + 1;
            #0.5 clk                   = 1'b1;
        end

        #0.5 clk = 1'b0;
        ofifo_rd = 0;
        WEN_pmem = 1;
        CEN_pmem = 1;
        #0.5 clk = 1'b1;
        /////////////////////////////////////


    end  // end of kij loop

    ////////// Accumulation /////////

    out_file = $fopen($sformatf("./mode%d/out.txt", mode), "r");

    error = 0;

    if (otile == 0)
        $display("############ Verification Start during accumulation for Output Channel 1 - 8  #############"); 
    else
        $display("############ Verification Start during accumulation for Output Channel 9 - 16  #############");
    // $display("############ Verification Start during accumulation #############"); 

    for (i=0; i<len_onij+1; i=i+1) begin 

        #0.5 clk = 1'b0; 
        #0.5 clk = 1'b1; 

        if (i>0) begin
        out_scan_file = $fscanf(out_file,"%256b", answer); // reading from out file to answer

        if (otile == 0) begin
            if (sfu_out == answer[psum_bw*col*1-1:0])
                $display("%2d-th output featuremap Data matched! :D", i); 
            else begin
                $display("%2d-th output featuremap Data ERROR!!", i); 
                $display("sfuout: %128b", sfu_out);
                $display("answer: %128b", answer[psum_bw*col*1-1:0]);
                error = 1;
            end
        end
        else begin
            if (sfu_out == answer[psum_bw*col*2-1:psum_bw*col*1])
                $display("%2d-th output featuremap Data matched! :D", i); 
            else begin
                $display("%2d-th output featuremap Data ERROR!!", i); 
                $display("sfuout: %128b", sfu_out);
                $display("answer: %128b", answer[psum_bw*col*2-1:psum_bw*col*1]);
                error = 1;
            end
        end

        // if (sfu_out == answer)
        //     $display("%2d-th output featuremap Data matched! :D", i); 
        // else begin
        //     $display("%2d-th output featuremap Data ERROR!!", i); 
        //     $display("sfuout: %128b", sfu_out);
        //     $display("answer: %128b", answer);
        //     error = 1;
        // end


        end
    
        #0.5 clk = 1'b0; reset = 1;
        #0.5 clk = 1'b1;  
        #0.5 clk = 1'b0; reset = 0; 
        #0.5 clk = 1'b1;

        for (j = 0; j<len_kij+1; j = j+1) begin
                
            #0.5 clk = 1'b0;
            if (j<len_kij) begin
                CEN_pmem = 0;   
                WEN_pmem = 1;  // PMEM read enable, psum move from PMEM to SFU
                //calculate the address of data that conv needs
                A_pmem = (i / o_ni_dim) * a_pad_ni_dim + (i % o_ni_dim) + (j / ki_dim) * a_pad_ni_dim + (j % ki_dim) + (j * len_nij);
            end
            else  begin
                CEN_pmem = 1;
                WEN_pmem = 1;
                A_pmem = 0;
            end

            if (j>0)  acc = 1;
            #0.5 clk      = 1'b1;
        end

        #0.5 clk = 1'b0;
        acc      = 0;
        #0.5 clk = 1'b1;

        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;

        end

  end

if (error == 0) begin
    $display("######################## No error detected ##########################"); 
    $display("######################## Project Completed !! ########################"); 

end

// $fclose(acc_file);
//////////////////////////////////

for (t=0; t<10; t=t+1) begin  
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;  
end


#10 $finish;


end

always @ (posedge clk) begin
   inst_w_q   <= inst_w; 
   D_xmem_q   <= D_xmem;
   CEN_xmem_q <= CEN_xmem;
   WEN_xmem_q <= WEN_xmem;
   A_pmem_q   <= A_pmem;
   CEN_pmem_q <= CEN_pmem;
   WEN_pmem_q <= WEN_pmem;
   A_xmem_q   <= A_xmem;
   ofifo_rd_q <= ofifo_rd;
   acc_q      <= acc;
   ififo_wr_q <= ififo_wr;
   ififo_rd_q <= ififo_rd;
   l0_rd_q    <= l0_rd;
   l0_wr_q    <= l0_wr ;
   execute_q  <= execute;
   load_q     <= load;
   l0_version_q <= l0_version;
   mode_q <= mode;
end


endmodule