/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* Matrix Vector Multiplication (MVM) Module       */
/***************************************************/

module mvm # (
    parameter IWIDTH = 8,
    parameter OWIDTH = 32,
    parameter MEM_DATAW = IWIDTH * 8,
    parameter VEC_MEM_DEPTH = 256,
    parameter VEC_ADDRW = $clog2(VEC_MEM_DEPTH),
    parameter MAT_MEM_DEPTH = 512,
    parameter MAT_ADDRW = $clog2(MAT_MEM_DEPTH),
    parameter NUM_OLANES = 8
)(
    input clk,
    input rst,
    input [MEM_DATAW-1:0] i_vec_wdata,
    input [VEC_ADDRW-1:0] i_vec_waddr,
    input i_vec_wen,
    input [MEM_DATAW-1:0] i_mat_wdata,
    input [MAT_ADDRW-1:0] i_mat_waddr,
    input [NUM_OLANES-1:0] i_mat_wen,
    input i_start,
    input [VEC_ADDRW-1:0] i_vec_start_addr,
    input [VEC_ADDRW:0] i_vec_num_words,
    input [MAT_ADDRW-1:0] i_mat_start_addr,
    input [MAT_ADDRW:0] i_mat_num_rows_per_olane,
    output o_busy,
    output [OWIDTH-1:0] o_result [0:NUM_OLANES-1],
    output o_valid
);

/******* Your code starts here *******/

logic signed [MEM_DATAW-1:0] vec_rdata;
logic signed [MEM_DATAW-1:0] mat_rdata [0:NUM_OLANES-1];
logic signed [OWIDTH-1:0] dot_product [0:NUM_OLANES-1];
logic dot_acc_valid [0:NUM_OLANES-1];

logic [VEC_ADDRW-1:0] vec_raddr;
logic [MAT_ADDRW-1:0] mat_raddr;
logic accum_first;
logic accum_last;
logic ovalid; // Control signal to dot8, not o_valid

// Each word is 8 bits
mem #(.DATAW(MEM_DATAW), .DEPTH(VEC_MEM_DEPTH), .ADDRW(VEC_ADDRW)) vec_mem_inst (.clk(clk), .waddr(i_vec_waddr), .wdata(i_vec_wdata), .wen(i_vec_wen), .raddr(vec_raddr), .rdata(vec_rdata));
accum #(.DATAW(OWIDTH), .ACCUMW(OWIDTH)) accum_inst0 (.clk(clk), .rst(rst), .data(dot_product[0]), .ivalid(dot_acc_valid[0]), .first(accum_first), .last(accum_last), .result(o_result[0]), .ovalid(o_valid));

genvar i;
generate
    for (i=0; i<NUM_OLANES; i++) begin
        mem #(.DATAW(MEM_DATAW), .DEPTH(MAT_MEM_DEPTH), .ADDRW(MAT_ADDRW)) mat_mem_inst (.clk(clk), .waddr(i_mat_waddr), .wdata(i_mat_wdata), .wen(i_mat_wen[i]), .raddr(mat_raddr), .rdata(mat_rdata[i]));
        dot8 #(.IWIDTH(IWIDTH), .OWIDTH(OWIDTH)) dot_inst (.clk(clk), .rst(rst), .vec0(vec_rdata), .vec1(mat_rdata[i]), .ivalid(ovalid), .result(dot_product[i]), .ovalid(dot_acc_valid[i]));
    end
    
    for (i=1; i<NUM_OLANES; i++) begin
        accum #(.DATAW(OWIDTH), .ACCUMW(OWIDTH)) accum_inst (.clk(clk), .rst(rst), .data(dot_product[i]), .ivalid(dot_acc_valid[i]), .first(accum_first), .last(accum_last), .result(o_result[i]), .ovalid());
    end
endgenerate

ctrl #(.VEC_ADDRW(VEC_ADDRW), .MAT_ADDRW(MAT_ADDRW)) ctrl_inst (.clk(clk), .rst(rst), .start(i_start), .vec_start_addr(i_vec_start_addr), .vec_num_words(i_vec_num_words), .mat_start_addr(i_mat_start_addr), .mat_num_rows_per_olane(i_mat_num_rows_per_olane), .vec_raddr(vec_raddr), .mat_raddr(mat_raddr), .accum_first(accum_first), .accum_last(accum_last), .ovalid(ovalid), .busy(o_busy));
/******* Your code ends here ********/

endmodule