/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* 8-Lane Dot Product Module                       */
/***************************************************/

module dot8 # (
    parameter IWIDTH = 8,
    parameter OWIDTH = 32
)(
    input clk,
    input rst,
    input signed [8*IWIDTH-1:0] vec0,
    input signed [8*IWIDTH-1:0] vec1,
    input ivalid,
    output signed [OWIDTH-1:0] result,
    output ovalid
);

/******* Your code starts here *******/

  logic v0,v1,v2,v3,v4;
  logic signed [IWIDTH-1:0] a0,a1,a2,a3,a4,a5,a6,a7;
  logic signed [IWIDTH-1:0] b0,b1,b2,b3,b4,b5,b6,b7;
  logic signed [2*IWIDTH-1:0] p0,p1,p2,p3,p4,p5,p6,p7;
  logic signed [2*IWIDTH:0] s0,s1,s2,s3;
  logic signed [2*IWIDTH+1:0] t0,t1;
  logic signed [2*IWIDTH+2:0] sum_final;
  
  logic signed [OWIDTH-1:0] result_r;
  logic ovalid_r;
  
  always_ff @(posedge clk) begin
    
    // Clear registers on reset
    if (rst) begin
      // clear all pipeline registers
      {a0,a1,a2,a3,a4,a5,a6,a7} <= '0;
      {b0,b1,b2,b3,b4,b5,b6,b7} <= '0;
      {p0,p1,p2,p3,p4,p5,p6,p7} <= '0;
      {s0,s1,s2,s3}             <= '0;
      {t0,t1}                   <= '0;
      sum_final                 <= '0;
      {v0,v1,v2,v3,v4}          <= '0;
      result_r                    <= 0;
      ovalid_r                    <= 1'b0;
    end else begin
      // Stage 0: latch inputs and valid
      {a0,a1,a2,a3,a4,a5,a6,a7} <= vec0;
      {b0,b1,b2,b3,b4,b5,b6,b7} <= vec1;
      v0                         <= ivalid;

      // Stage 1: products and valid
      p0 <= a0 * b0; p1 <= a1 * b1;
      p2 <= a2 * b2; p3 <= a3 * b3;
      p4 <= a4 * b4; p5 <= a5 * b5;
      p6 <= a6 * b6; p7 <= a7 * b7;
      v1 <= v0;
      
      // Stage 2: first-level sums and valid
      s0 <= p0 + p1;
      s1 <= p2 + p3;
      s2 <= p4 + p5;
      s3 <= p6 + p7;
      v2 <= v1;

      // Stage 3: second-level sums and valid
      t0 <= s0 + s1;
      t1 <= s2 + s3;
      v3 <= v2;

      // Stage 4: register the final third-level sum
      sum_final <= t0 + t1;
      v4 <= v3;

      // Final outputs
      result_r    <= sum_final;
      ovalid_r    <= v4;
    end
  end
  
  assign result = result_r;
  assign ovalid = ovalid_r;

/******* Your code ends here ********/

endmodule
