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
parameter num_corelet_row = 4;
parameter num_corelet_col = 4;

reg clk = 0;
reg reset = 1;

wire [33:0] inst_q; 

reg [1:0]  inst_w_q = 0; 
reg [bw*row*num_corelet_row*num_corelet_col-1:0] D_xmem_q = 0;

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

reg [1:0]  inst_w; 
reg [bw*row*num_corelet_row*num_corelet_col-1:0] D_xmem;
reg [psum_bw*col*num_corelet_row*num_corelet_col-1:0] answer;


reg ofifo_rd;
reg ififo_wr;
reg ififo_rd;
reg l0_rd;
reg l0_wr;
reg execute;
reg load;
reg [8*30:1] stringvar;
reg [8*256:1] w_file_name;
reg [8*256:1] x_file_name;
reg l0_version_q;
wire ofifo_valid;
wire ofifo_ready;
wire ofifo_full;
wire l0_ready;
wire l0_full;
wire [col*psum_bw*num_corelet_row*num_corelet_col-1:0] sfu_out;


integer x_file [0:num_corelet_row*num_corelet_col-1]; 
integer x_scan_file;
integer w_file; 
integer w_scan_file;
integer acc_file, acc_scan_file ; // file_handler
integer out_file [0:num_corelet_row*num_corelet_col-1]; // file_handler
integer out_scan_file ; // file_handler
integer out_write_file [0:num_corelet_row*num_corelet_col-1];
reg [8*256:1] out_write_file_name;
reg [8*256:1] out_read_file_name;
integer captured_data; 
integer t, i, j, k, kij;
integer error;
integer r, c;
reg [31:0] temp_data;
reg [127:0] temp_data_128;

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


core  #(.bw(bw), .col(col), .row(row), .num_corelet_row(num_corelet_row), .num_corelet_col(num_corelet_col)) core_instance (
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

  // Open activation files
  for (r=0; r<num_corelet_row; r=r+1) begin
      for (c=0; c<num_corelet_col; c=c+1) begin
          $sformat(x_file_name, "../datafiles/activation_tile%0d.txt", r*num_corelet_col+c);
          x_file[r*num_corelet_col+c] = $fopen(x_file_name, "r");
      end
  end

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
      
      for (r=0; r<num_corelet_row; r=r+1) begin
          for (c=0; c<num_corelet_col; c=c+1) begin
              x_scan_file = $fscanf(x_file[r*num_corelet_col+c], "%32b", temp_data);
              D_xmem[(r*num_corelet_col+c+1)*32-1 -: 32] = temp_data;
          end
      end

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
  
  for (r=0; r<num_corelet_row; r=r+1) begin
      for (c=0; c<num_corelet_col; c=c+1) begin
          $fclose(x_file[r*num_corelet_col+c]);
      end
  end
  /////////////////////////////////////////////////
  

  for (kij=0; kij<9; kij=kij+1) begin  // kij loop

    $sformat(w_file_name, "../datafiles/weight_kij%0d.txt", kij);
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
    for (t = 0; t<col; t = t+1) begin   // load into xmem
        #0.5 clk        = 1'b0;
        
        w_scan_file = $fscanf(w_file, "%32b", temp_data);
        for (r=0; r<num_corelet_row; r=r+1) begin
            for (c=0; c<num_corelet_col; c=c+1) begin
                D_xmem[(r*num_corelet_col+c+1)*32-1 -: 32] = temp_data;
            end
        end

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
    /////////////////////////////////////
    for (i = 0; i<10 ; i = i+1) begin
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;
    end
    
    $fclose(w_file);


    /////// Kernel data writing to L0 ///////
     A_xmem = 11'b10000000000;
            
    #0.5 clk = 1'b0;
    WEN_xmem = 1;
    CEN_xmem = 0; // xmem read operation
    #0.5 clk = 1'b1;
    
    for (t = 0; t<col; t = t+1) begin
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
    
    for (t = 0; t<col; t = t+1) begin
        #0.5 clk = 1'b0;
        load     = 1;  // load weight into mac_array
        #0.5 clk = 1'b1;
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
        WEN_pmem                   = 0;
        CEN_pmem                   = 0; //PMEM read enable
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
  // out_file = $fopen("../datafiles/out.txt", "r");  

  // Open output files for writing and reading
  for (k=0; k<num_corelet_row*num_corelet_col; k=k+1) begin
      $sformat(out_write_file_name, "sim_out%0d.txt", k);
      out_write_file[k] = $fopen(out_write_file_name, "w");

      $sformat(out_read_file_name, "../datafiles/out%0d.txt", k);
      out_file[k] = $fopen(out_read_file_name, "r");
  end

  // Following three lines are to remove the first three comment lines of the file
  // out_scan_file = $fscanf(out_file,"%s", answer); 
  // out_scan_file = $fscanf(out_file,"%s", answer); 
  // out_scan_file = $fscanf(out_file,"%s", answer); 

  error = 0;



  $display("############ Verification Start during accumulation #############"); 

  for (i=0; i<len_onij+1; i=i+1) begin 

    #0.5 clk = 1'b0; 
    #0.5 clk = 1'b1; 

    if (i>0) begin
       
       // Write to individual files and compare
       for (k=0; k<num_corelet_row*num_corelet_col; k=k+1) begin
           $fdisplay(out_write_file[k], "%128b", sfu_out[(k+1)*128-1 -: 128]);
           
           out_scan_file = $fscanf(out_file[k], "%128b", temp_data_128);
           if (sfu_out[(k+1)*128-1 -: 128] !== temp_data_128) begin
               $display("%2d-th output featuremap Data ERROR at corelet %d!!", i, k); 
               $display("sfuout: %128b", sfu_out[(k+1)*128-1 -: 128]);
               $display("answer: %128b", temp_data_128);
               error = 1;
           end
       end

       if (error == 0)
         $display("%2d-th output featuremap Data matched! :D", i); 
    end
   
 
    #0.5 clk = 1'b0; reset = 1;
    #0.5 clk = 1'b1;  
    #0.5 clk = 1'b0; reset = 0; 
    #0.5 clk = 1'b1;

    for (j = 0; j<len_kij+1; j = j+1) begin
            
        #0.5 clk = 1'b0;
        if (j<len_kij) begin
            CEN_pmem = 0;   // PMEM read enable, psum move from PMEM to SFP
            WEN_pmem = 1;
            //calculate the address of data that conv needs
            A_pmem = (i / o_ni_dim) * a_pad_ni_dim + (i % o_ni_dim) + (j / ki_dim) * a_pad_ni_dim + (j % ki_dim) + (j * len_nij);

        end
        else  begin
            CEN_pmem = 1;
            WEN_pmem = 1;
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


  if (error == 0) begin
  	$display("############ No error detected ##############"); 
  	$display("########### Project Completed !! ############"); 

  end

  for (k=0; k<num_corelet_row*num_corelet_col; k=k+1) begin
      $fclose(out_write_file[k]);
      $fclose(out_file[k]);
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
end


endmodule
