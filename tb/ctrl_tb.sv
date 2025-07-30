`timescale 1 ns / 1 ps

module ctrl_tb();

// Define clock period to be used in simulation
localparam CLK_PERIOD = 4;
  
// DUT parameters
localparam VEC_ADDRW = 8;
localparam VEC_SIZEW = 9;
localparam MAT_ADDRW = VEC_ADDRW + 1;
localparam MAT_SIZEW = MAT_ADDRW + 1;

// Test parameters

// Declare logic signals for the DUT's inputs and outputs
logic clk;
logic rst;
logic start;
logic [VEC_ADDRW-1:0] vec_start_addr;
logic [VEC_SIZEW-1:0] vec_num_words;
logic [MAT_ADDRW-1:0] mat_start_addr;
logic [MAT_SIZEW-1:0] mat_num_rows_per_olane;
logic [VEC_ADDRW-1:0] vec_raddr;
logic [MAT_ADDRW-1:0] mat_raddr;
logic accum_first;
logic accum_last;
logic ovalid;
logic busy;

// Instantiate the design under test (dut) and connect its input/output ports to the declared signals.
ctrl # (.VEC_ADDRW(VEC_ADDRW),.MAT_ADDRW(MAT_ADDRW), .VEC_SIZEW(VEC_SIZEW), .MAT_SIZEW(MAT_SIZEW)) controller
(
    .clk(clk),
    .rst(rst),
    .start(start),
    .vec_start_addr(vec_start_addr),
    .vec_num_words(vec_num_words), 
    .mat_start_addr(mat_start_addr), 
    .mat_num_rows_per_olane(mat_num_rows_per_olane), 
    .vec_raddr(vec_raddr), 
    .mat_raddr(mat_raddr), 
    .accum_first(accum_first), 
    .accum_last(accum_last), 
    .ovalid(ovalid), 
    .busy(busy)   
);    

// Since the DUT tested here needs a clock signal, this initial block generates a clock signal with
// period 4ns and 50% duty cycle (i.e., 2ns high and 2ns low)
initial begin
    clk = 1'b0;
    // The forever keyword means this keeps happening until the end of time (wait for half a clock
    // period, and flip its state)
    forever #(CLK_PERIOD/2) clk = ~clk; 
end

// Initial block to generate test inputs and calculate their golden results
initial begin
    $monitor("vec_raddr = %0d, mat_raddr = %0d, accum_first = %0d, accum_last = %0d, busy = %0d, ovalid = %0d", vec_raddr, mat_raddr, accum_first, accum_last, busy, ovalid);

    /*IDLE STATE*/
    rst = 1'b1;
    vec_start_addr = 0;
    vec_num_words = 16;
    mat_start_addr = 0;
    mat_num_rows_per_olane = 16;
    #(5*CLK_PERIOD)
    
    /*COMPUTE STATE*/
    rst = 1'b0;
    #(5*CLK_PERIOD)
    start = 1'b1;    
    #(5*CLK_PERIOD)
    start = 1'b0;       

    #(100*CLK_PERIOD)
    
    $stop;
    
end

endmodule