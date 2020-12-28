`timescale 1ns / 1ps
`include "config.v"

module stall_ctrl(
    input wire rst,

    input wire stallreq_from_if,
    input wire stallreq_from_id,
    input wire stallreq_from_mem,
    output reg[5 : 0] stall
);

always @(*) begin
    if (rst == `ResetEnable) begin
        stall = 6'b000000;
    end
    else if (stallreq_from_mem == `Stop) begin
        stall = 6'b011111;
    end
    else if (stallreq_from_id == `Stop) begin
        stall = 6'b000111;
    end
    else if (stallreq_from_if == `Stop) begin
        stall = 6'b000011;
    end
    else begin
        stall = 6'b000000;
    end
end

endmodule 