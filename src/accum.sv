/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Accumulator Module                              */
/***************************************************/

module accum # (
    parameter DATAW = 32,
    parameter ACCUMW = 32
)(
    input  clk,
    input  rst,
    input  signed [DATAW-1:0] data,
    input  ivalid,
    input  first,
    input  last,
    output signed [ACCUMW-1:0] result,
    output ovalid
);

/******* Your code starts here *******/
logic signed [ACCUMW-1:0] accum_r;
logic ovalid_r;

assign ovalid = ovalid_r;
assign result = accum_r;

always_ff @(posedge clk) begin
    if (rst) begin
        accum_r <= 'b0;
        ovalid_r <= 'b0;
    end else begin
        ovalid_r <= 1'b0;

        if (ivalid) begin
            if (first) accum_r <= data; 
            else accum_r <= accum_r + data;

            if (last) ovalid_r <= 1'b1;
            else ovalid_r <= 1'b0;
        end
    end
end


/******* Your code ends here ********/

endmodule