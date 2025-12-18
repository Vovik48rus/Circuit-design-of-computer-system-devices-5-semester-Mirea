`timescale 1ns / 1ps

module simple_unsigned_divider (
    input wire        clk,
    input wire        rst,
    input wire [7:0]  a,
    input wire [7:0]  b,
    input wire        start,
    output reg [7:0]  res,
    output reg        done
);

reg [1:0] state;
reg [7:0] dividend, divisor;
reg [3:0] count;
reg [7:0] quotient;

localparam S_IDLE = 0;
localparam S_DIV  = 1;
localparam S_DONE = 2;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state <= S_IDLE;
        done <= 0;
        res <= 0;
        quotient <= 0;
    end else begin
        case (state)
            S_IDLE: begin
                done <= 0;
                quotient <= 0;
                if (start) begin
                    if (b == 0) begin
                        res <= 8'hFF;
                        done <= 1;
                    end else begin
                        dividend <= a;
                        divisor <= b;
                        count <= 8;
                        state <= S_DIV;
                    end
                end
            end
            
            S_DIV: begin
                if (count > 0) begin
                    if (dividend >= divisor) begin
                        dividend <= dividend - divisor;
                        quotient <= (quotient << 1) | 1'b1;
                    end else begin
                        quotient <= quotient << 1;
                    end
                    dividend <= dividend << 1;
                    count <= count - 1;
                end else begin
                    res <= quotient;
                    done <= 1;
                    state <= S_DONE;
                end
            end
            
            S_DONE: begin
                done <= 0;
                state <= S_IDLE;
            end
        endcase
    end
end

endmodule