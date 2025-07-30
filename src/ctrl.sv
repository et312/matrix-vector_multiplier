/***************************************************/
/* ECE 327: Digital Hardware Systems - Spring 2025 */
/* Lab 4                                           */
/* MVM Control FSM                                 */
/***************************************************/

module ctrl # (
    parameter VEC_ADDRW = 8,
    parameter MAT_ADDRW = 9,
    parameter VEC_SIZEW = VEC_ADDRW + 1,
    parameter MAT_SIZEW = MAT_ADDRW + 1
    
)(
    input  clk,
    input  rst,
    input  start,
    input  [VEC_ADDRW-1:0] vec_start_addr,
    input  [VEC_SIZEW-1:0] vec_num_words,
    input  [MAT_ADDRW-1:0] mat_start_addr,
    input  [MAT_SIZEW-1:0] mat_num_rows_per_olane,
    output [VEC_ADDRW-1:0] vec_raddr,
    output [MAT_ADDRW-1:0] mat_raddr,
    output accum_first,
    output accum_last,
    output ovalid,
    output busy
);

/******* Your code starts here *******/

enum {IDLE, COMPUTE} state, next_state;

// Internal values
logic [VEC_ADDRW-1:0] vec_start_addr_r;
logic [VEC_SIZEW-1:0] vec_num_words_r;
logic [MAT_ADDRW-1:0] mat_start_addr_r;
logic [MAT_SIZEW-1:0] mat_num_rows_per_olane_r;

logic [VEC_ADDRW-1:0] vec_raddr_r;
logic [MAT_ADDRW-1:0] mat_raddr_r;
logic [6:0] accum_first_r;
logic [6:0] accum_last_r;
logic [1:0] ovalid_r;

logic accum_first_val;
logic accum_last_val;
logic ovalid_val;
logic busy_val;

logic [VEC_ADDRW-1:0] vec_raddr_count;
logic [MAT_ADDRW-1:0] mat_raddr_count;

assign accum_first = accum_first_r[6];
assign accum_last = accum_last_r[6];
assign ovalid = ovalid_r[1];
assign busy = busy_val;

assign vec_raddr = vec_raddr_r;
assign mat_raddr = mat_raddr_r;

always_ff @(posedge clk) begin
    if (rst) begin 
        state <= IDLE;
        vec_raddr_r <= 'b0;
        mat_raddr_r <= 'b0;
        accum_first_r <= 'b0;
        accum_last_r <= 'b0;
        ovalid_r <= 'b0;
    end else begin
        state <= next_state;
        accum_first_r[6] <= accum_first_r[5];
        accum_first_r[5] <= accum_first_r[4];
        accum_first_r[4] <= accum_first_r[3];
        accum_first_r[3] <= accum_first_r[2];
        accum_first_r[2] <= accum_first_r[1];
        accum_first_r[1] <= accum_first_r[0];
        accum_first_r[0] <= accum_first_val;
        
        accum_last_r[6] <= accum_last_r[5]; 
        accum_last_r[5] <= accum_last_r[4];
        accum_last_r[4] <= accum_last_r[3];
        accum_last_r[3] <= accum_last_r[2];
        accum_last_r[2] <= accum_last_r[1];
        accum_last_r[1] <= accum_last_r[0];
        accum_last_r[0] <= accum_last_val;
        
        ovalid_r[1] <= ovalid_r[0];
        ovalid_r[0] <= ovalid_val;
    end
end 

always_ff @(posedge clk) begin
    if (rst) begin
        vec_start_addr_r <= 'b0;
        vec_num_words_r <= 'b0;
        mat_start_addr_r <= 'b0;
        mat_num_rows_per_olane_r <= 'b0;
        
        vec_raddr_count <= 'b0;
        mat_raddr_count <= 'b0;
    end else begin
        case (state) 
            IDLE: begin
                vec_start_addr_r <= vec_start_addr;
                vec_num_words_r <= vec_num_words;
                mat_start_addr_r <= mat_start_addr;
                mat_num_rows_per_olane_r <= mat_num_rows_per_olane;
                
                vec_raddr_count <= 'b0;
                mat_raddr_count <= 'b0;
            end
            COMPUTE: begin
                if (vec_raddr_count < vec_num_words_r) begin
                    vec_raddr_r <= vec_start_addr_r + vec_raddr_count;
                    vec_raddr_count <= vec_raddr_count + 1;
                end else begin
                    vec_raddr_r <= vec_start_addr_r;
                    vec_raddr_count <= 'b1;
                end
                
                if (mat_raddr_count < vec_num_words_r * mat_num_rows_per_olane_r) begin 
                    mat_raddr_r <= mat_start_addr_r + mat_raddr_count;
                end else begin 
                    // All matrix elements inputted into engine
                end
                mat_raddr_count <= mat_raddr_count + 1;
            end
        endcase
    end
end

always_comb begin : state_decoder
    case (state) 
        IDLE: begin
            if (start) next_state = COMPUTE;
            else next_state = IDLE;
        end 
        COMPUTE: begin
            if (mat_raddr_count >= vec_num_words_r * mat_num_rows_per_olane_r + 8) next_state = IDLE; 
            else next_state = COMPUTE;
        end
        default: next_state = IDLE;
    endcase
end

always_comb begin : output_decoder
    case (state)
        IDLE: begin
            accum_first_val = 1'b0;
            accum_last_val = 1'b0;
            ovalid_val = 1'b0;
            busy_val = 1'b0;
        end
        COMPUTE: begin
            ovalid_val = 1'b1;
            busy_val = 1'b1;
            if (vec_raddr_r == vec_start_addr_r) accum_first_val = 1'b1;
            else accum_first_val = 1'b0;
            
            if (vec_raddr_r == vec_start_addr_r + vec_num_words_r - 1) accum_last_val = 1'b1;
            else accum_last_val = 1'b0;
            
            if (mat_raddr_count <= vec_num_words_r * mat_num_rows_per_olane_r) begin
                ovalid_val = 1'b1; 
            end else begin
                ovalid_val = 1'b0;
                accum_first_val = 1'b0;
                accum_last_val = 1'b0;
            end
        end
        default: begin
            accum_first_val = 1'b0;
            accum_last_val = 1'b0;
            ovalid_val = 1'b0;
            busy_val = 1'b0;
        end
    endcase
end

/******* Your code ends here ********/

endmodule