`timescale 1ns/1ps

module dot8_tb;
  // Parameters
  localparam int IWIDTH = 8;
  localparam int OWIDTH = 32;
  localparam int VECW   = IWIDTH * 8;

  // Signals
  logic                 clk;
  logic                 rst;
  logic [VECW-1:0]      vec0, vec1;
  logic                 ivalid, ovalid;
  logic [OWIDTH-1:0]    result;

  // DUT instantiation
  dot8 #(.IWIDTH(IWIDTH), .OWIDTH(OWIDTH)) dut (
    .clk(clk), .rst(rst),
    .vec0(vec0), .vec1(vec1),
    .ivalid(ivalid), .result(result), .ovalid(ovalid)
  );

  // Pack helper
  function automatic logic [VECW-1:0] pack(input logic signed [IWIDTH-1:0] arr[7:0]);
    logic [VECW-1:0] tmp;
    for (int i = 0; i < 8; i++)
      tmp[i*IWIDTH +: IWIDTH] = arr[i];
    return tmp;
  endfunction

  // Declare arrays outside the initial block
  logic signed [IWIDTH-1:0] A[7:0];
  logic signed [IWIDTH-1:0] B[7:0];
  int expected;
  
  initial begin
     clk = 1'b0;
    forever #1 clk = ~clk;
  
  end

  initial begin
    // Reset
    rst    = 1'b1;
    ivalid = 1'b0;
    #20;
    rst = 1'b0;
    
    // Test 1

    // Initialize A, B, and expected outside initial block
    A = '{1,1,2,3,4,5,6,7};
    B = '{1,2,3,4,5,6,7,8};
    vec0 = pack(A);
    vec1 = pack(B);
    
    // Compute expected result
    expected = 0;
    for (int i = 0; i < 8; i++)
      expected += A[i] * B[i];

    // Assert ivalid
    ivalid <= 1'b1;

//    wait (ovalid);
    #12;
    if (result !== expected) begin
      $display("TEST 1 FAILED: result=%0d, expected=%0d", result, expected);
    end else begin
      $display("TEST 1 PASSED: result=%0d", result);
    end
    
    $finish;
  end
endmodule
