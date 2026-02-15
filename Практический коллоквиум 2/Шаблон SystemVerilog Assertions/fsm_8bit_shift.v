module fsm_8bit_shift ( 
    input clk, 
    input reset, 
    input [7:0] data_in1, 
    input [7:0] data_in2, 
    output reg [15:0] data_out 
); 
 
    reg [1:0] state, next_state; 
 
    localparam IDLE = 2'b00, SHIFT = 2'b01, COMBINE = 2'b10; 
 
    always @(posedge clk) begin 
        if (reset) state <= IDLE; 
        else state <= next_state; 
    end 
 
    always @(state or data_in1 or data_in2) begin 
        case (state) 
            IDLE: next_state = SHIFT; 
            SHIFT: next_state = COMBINE; 
            COMBINE: next_state = IDLE; 
            default: next_state = IDLE; 
        endcase 
    end 
 
    always @(state or data_in1 or data_in2) begin 
        case (state) 
            IDLE: data_out = 16'b0; 
            SHIFT: data_out = data_in1 << 2; 
            COMBINE: data_out = {data_in1, data_in2}; 
            default: data_out = 16'b0; 
        endcase 
    end 
 
endmodule 