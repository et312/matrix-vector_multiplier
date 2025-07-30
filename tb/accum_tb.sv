`timescale 1 ns / 1 ps

module accum_tb(); 
// Define clock period to be used in simulation
localparam CLK_PERIOD = 4; 				 
// DUT parameters
localparam IWIDTH = 8;
localparam OWIDTH = 32;
localparam MEM_DATAW = IWIDTH * 8;
localparam VEC_DATAW = IWIDTH * 8;
localparam MAT_DATAW = IWIDTH * 8;
localparam NUM_OLANES = 8;
// Test parameters
localparam M = 128; // matrix height
localparam N = 128; // matrix width or vector length
localparam M_PADDED = $rtoi($ceil(1.0 * M / NUM_OLANES) * NUM_OLANES);
localparam N_PADDED = $rtoi($ceil(1.0 * N / 8) * 8);
localparam VEC_MEM_DEPTH = ((N_PADDED / 8) > 256)? N_PADDED / 8 : 256;
localparam VEC_ADDRW = $clog2(VEC_MEM_DEPTH);
localparam MAT_MEM_DEPTH = ((N_PADDED * M_PADDED / 8 / NUM_OLANES) > 512)? N_PADDED * M_PADDED / 8 / NUM_OLANES : 512;
localparam MAT_ADDRW = $clog2(MAT_MEM_DEPTH);

logic clk;
logic rst;
logic signed [OWIDTH-1:0] data;
logic ivalid;
logic first;
logic last;
logic signed [OWIDTH-1:0] result;
logic ovalid;

logic sim_failed;

accum #(.DATAW(OWIDTH), .ACCUMW(OWIDTH)) accum_inst (.clk(clk), .rst(rst), .data(data), .ivalid(ivalid), .first(first), .last(last), .result(result), .ovalid(ovalid));

initial begin
    clk = 1'b0;
    forever #1 clk = ~clk;
end

initial begin
    rst = 1'b1;
    data = 32'h0000;
    ivalid = 1'b0;
    first = 1'b0;
    last = 1'b1;
    sim_failed = 1'b0;

    #3;
    rst = 1'b0;

    #2;
    data = 32'h4000;
    first = 1'b1;
    ivalid = 1'b1;

    #2;
    data = 32'h0010;
    first = 1'b0;

    #2;
    data = 32'h0001;

    #2; 
    data = 32'h0002;

    #2; 
    data = 32'h1000;
    ivalid = 1'b0;

    #2;
    data = 32'h0004;
    ivalid = 1'b1;
    last = 1'b1;

    #2; 
    ivalid = 1'b0;
    if (result != 32'h4017) begin
        $display("Result incorrect");
        sim_failed = 1'b1;
    end else if (~ovalid) begin
        $display("ovalid not asserted");
        sim_failed = 1'b1;
    end

    #2;
    ivalid = 1'b0;
    last = 1'b0;
    
    #2;
    if (result != 32'h4017) begin
        $display("Result changed after deasserting ivalid");
        sim_failed = 1'b1;
    end 

    #2;
    data = 32'h4000;
    ivalid = 1'b1;
    first = 1'b1;
    
    #2;
    ivalid = 1'b0;
    if (result != 32'h4000) begin
        $display("Result did not reset to data");
        sim_failed = 1'b1;
    end else if (ovalid) begin
        $display("ovalid did not deassert");
        sim_failed = 1'b1;
    end

    #2;
    rst = 1'b1;
    
    #2;
    if (result != 32'h0000) begin
        $display("Result did not reset to 0");
        sim_failed = 1'b1;
    end else if (ovalid) begin
        $display("ovalid did not deassert");
        sim_failed = 1'b1;
    end


    if (sim_failed) begin
        $display("TEST FAILED!");
    end else begin
        $display("TEST PASSED!");
    end
end

endmodule