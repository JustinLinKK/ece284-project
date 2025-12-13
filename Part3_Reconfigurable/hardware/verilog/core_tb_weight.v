`timescale 1ns/1ps

module core_tb_weight();
    
    parameter bw       = 4;  
    parameter psum_bw  = 16; 
    parameter len_kij  = 9;  
    parameter len_onij = 16; 
    parameter col      = 8;  
    parameter row      = 8;  
    parameter len_nij  = 36; 
    parameter a_pad_ni_dim = 6; 
    parameter o_ni_dim     = 4; 
    parameter ki_dim       = 3; 
    
    reg clk   = 0;
    reg reset = 1;
    
    
    wire [33:0] inst_q;   
    reg [1:0]  inst_w_q = 0; 
    
    
    reg [bw*row-1:0] D_xmem_q = 0; 
    reg CEN_xmem              = 0;             
    reg WEN_xmem              = 0;             
    reg [10:0] A_xmem         = 0;        
    
    
    reg CEN_xmem_q      = 0;           
    reg WEN_xmem_q      = 0;           
    reg [10:0] A_xmem_q = 0;      
    
    
    reg CEN_pmem      = 0;             
    reg WEN_pmem      = 0;             
    reg [10:0] A_pmem = 0;        
    
    
    reg CEN_pmem_q      = 0;           
    reg WEN_pmem_q      = 0;           
    reg [10:0] A_pmem_q = 0;      
    
    
    reg ofifo_rd_q = 0;           
    reg ififo_wr_q = 0;           
    reg ififo_rd_q = 0;           
    reg l0_rd_q    = 0;              
    reg l0_wr_q    = 0;              
    
    
    reg execute_q = 0;            
    reg load_q    = 0;               
    reg acc_q     = 0;                
    
    reg acc = 0;                  
    
    
    reg [1:0]  inst_w;
    reg [bw*row-1:0] D_xmem;
    reg [psum_bw*col-1:0] answer;
    
    reg ofifo_rd;
    reg ififo_wr;
    reg ififo_rd;
    reg l0_rd;
    reg l0_wr;
    reg execute;
    reg load;
    
    reg [8*256:1] w_file_name;
    
    reg [col*psum_bw-1:0] final_out;
    reg l0_version_q;
    reg l0_version;
    reg mode;

    wire ofifo_valid;
    wire [col*psum_bw-1:0] sfu_out;
    wire [4:0] l0_ofifo_signals;      
    wire OFIFO_o_valid;
    wire OFIFO_o_ready;
    wire OFIFO_o_full;
    wire l0_o_full;
    wire l0_o_ready;
    
    
    integer x_file, x_scan_file;  
    integer w_file, w_scan_file;  
    integer out_file, out_scan_file; 
    
    
    
    
    integer t, i, j, kij;      
    integer error;                
    
    assign inst_q[33]    = acc_q;        
    assign inst_q[32]    = CEN_pmem_q;   
    assign inst_q[31]    = WEN_pmem_q;   
    assign inst_q[30:20] = A_pmem_q;     
    assign inst_q[19]    = CEN_xmem_q;   
    assign inst_q[18]    = WEN_xmem_q;   
    assign inst_q[17:7]  = A_xmem_q;     
    assign inst_q[6]     = ofifo_rd_q;   
    assign inst_q[5]     = ififo_wr_q;   
    assign inst_q[4]     = ififo_rd_q;   
    assign inst_q[3]     = l0_rd_q;      
    assign inst_q[2]     = l0_wr_q;      
    assign inst_q[1]     = execute_q;    
    assign inst_q[0]     = load_q;       
    
    
    assign  OFIFO_o_valid = l0_ofifo_signals[4];
    assign  OFIFO_o_ready = l0_ofifo_signals[3];
    assign  OFIFO_o_full  = l0_ofifo_signals[2];
    assign  l0_o_full     = l0_ofifo_signals[1];
    assign  l0_o_ready    = l0_ofifo_signals[0];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    core  #(.bw(bw), .col(col), .row(row)) core_instance (
    .clk(clk),
    .inst(inst_q),
    .l0_ofifo_signals(l0_ofifo_signals),
    .D_xmem(D_xmem_q),
    .sfu_out(sfu_out),
    .reset(reset),
    .mode(mode),
    .l0_version(l0_version_q));
    
    
    initial begin
        inst_w     = 0;
        D_xmem     = 0;
        CEN_xmem   = 1;
        WEN_xmem   = 1;
        A_xmem     = 0;
        ofifo_rd   = 0;
        ififo_wr   = 0;
        ififo_rd   = 0;
        l0_rd      = 0;
        l0_wr      = 0;
        execute    = 0;
        load       = 0;
        l0_version = 1;
        mode = 0; 
        $dumpfile("core_tb_weight.vcd");
        $dumpvars(0,core_tb_weight);
        
        x_file = $fopen("../datafiles/mode0/activation_tile0.txt", "r");
        
        
        
        
        
        
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
        
        
        
        for (kij = 0; kij<9; kij = kij+1) begin  
            $sformat(w_file_name,
                "../datafiles/mode%0d/weight_itile0_otile0_kij%0d.txt",
                mode, kij);

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
            
            
            
            A_xmem = 11'b10000000000;
            
            for (t = 0; t<col; t = t+1) begin   
                #0.5 clk        = 1'b0;
                w_scan_file     = $fscanf(w_file,"%32b", D_xmem);
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
            
            for (i = 0; i<10 ; i = i+1) begin
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            
            
            A_xmem = 11'b10000000000;
            
            #0.5 clk = 1'b0;
            WEN_xmem = 1;
            CEN_xmem = 0; 
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
            
            for (i = 0; ~l0_o_full&&i<10; i = i+1) begin
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            
            
            
            
            
            
            #0.5 clk = 1'b0;
            l0_rd    = 1;
            #0.5 clk = 1'b1;
            
            for (t = 0; t<col; t = t+1) begin
                #0.5 clk = 1'b0;
                load     = 1;  
                #0.5 clk = 1'b1;
            end
            
            
            
            
            
            #0.5 clk = 1'b0;
            load     = 0;
            l0_rd    = 0;
            #0.5 clk = 1'b1;
            
            
            for (i = 0; i<10 ; i = i+1) begin
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            
            
            
            
            
            A_xmem   = 0;
            #0.5 clk = 1'b0;
            WEN_xmem = 1;
            CEN_xmem = 0; 
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
            
            
            
            
            
            #0.5 clk = 1'b0;
            l0_rd    = 1;
            #0.5 clk = 1'b1;
            
            
            for (t = 0; t<len_nij; t = t+1) begin
                #0.5 clk = 1'b0;
                execute  = 1;
                #0.5 clk = 1'b1;
            end
            
            for (t = 0; t<row+col; t = t+1) begin  
                #0.5 clk = 1'b0;
                #0.5 clk = 1'b1;
            end
            
            #0.5 clk = 1'b0;
            l0_rd    = 0;
            execute  = 0;
            #0.5 clk = 1'b1;

            
            
            
            #0.5 clk = 1'b0;
            ofifo_rd = 1;
            #0.5 clk = 1'b1;

            for (t = 0; t<len_nij; t = t+1) begin   
                #0.5 clk                   = 1'b0;
                WEN_pmem                   = 0;
                CEN_pmem                   = 0; 
                if (t>0 | A_pmem>0) A_pmem = A_pmem + 1;
                #0.5 clk                   = 1'b1;
            end

            #0.5 clk = 1'b0;
            ofifo_rd = 0;
            WEN_pmem = 1;
            CEN_pmem = 1;
            #0.5 clk = 1'b1;
            
                        
            
        end  
        
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;
        
        
        out_file = $fopen("../datafiles/mode0/out.txt", "r");
        
        error = 0;
        
        
        $display("############ Verification Start during accumulation #############");
        
        for (i = 0; i<len_onij+1; i = i+1) begin
            
            #0.5 clk = 1'b0;
            #0.5 clk = 1'b1;
            
            if (i>0) begin
                final_out     = sfu_out;
                out_scan_file = $fscanf(out_file,"%128b", answer);
                if (final_out == answer)
                    $display("%2d-th output featuremap Data matched! :D", i);
                
                else begin
                $display("%2d-th output featuremap Data ERROR!!", i);
                $display("final out: %128b", final_out);
                $display("answer: %128b", answer);
                error = 1;
            end
        end
        
        #0.5 clk = 1'b0; reset = 1;
        #0.5 clk = 1'b1;
        #0.5 clk = 1'b0; reset = 0;
        #0.5 clk = 1'b1;
        
        for (j = 0; j<len_kij+1; j = j+1) begin
            
            #0.5 clk = 1'b0;
            if (j<len_kij) begin
                CEN_pmem = 0;   
                WEN_pmem = 1;
                
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
    
    
    
    
    for (t = 0; t<10; t = t+1) begin
        #0.5 clk = 1'b0;
        #0.5 clk = 1'b1;
    end
    
    #10 $finish;
    
    end
    
    always @ (posedge clk) begin
        inst_w_q     <= inst_w;
        D_xmem_q     <= D_xmem;
        CEN_xmem_q   <= CEN_xmem;
        WEN_xmem_q   <= WEN_xmem;
        A_pmem_q     <= A_pmem;
        CEN_pmem_q   <= CEN_pmem;
        WEN_pmem_q   <= WEN_pmem;
        A_xmem_q     <= A_xmem;
        ofifo_rd_q   <= ofifo_rd;
        acc_q        <= acc;
        ififo_wr_q   <= ififo_wr;
        ififo_rd_q   <= ififo_rd;
        l0_rd_q      <= l0_rd;
        l0_wr_q      <= l0_wr ;
        execute_q    <= execute;
        load_q       <= load;
        l0_version_q <= l0_version;
    end
    
    
endmodule
    
    
    
    
