`timescale 1ns / 1ps
`include "config.v"
module if_id(
    input wire clk,
    input wire rst,
    input wire rdy,

    input wire[5 : 0] stall,
    input wire prediction_res,
    input wire[`Addrlen - 1 : 0] if_pc,
    input wire[`Instlen - 1 : 0] if_inst,
    output reg[`Addrlen - 1 : 0] id_pc,
    output reg[`Instlen - 1 : 0] id_inst
);

always @(posedge clk ) begin
    if (rst == `ResetEnable) begin
        id_pc <= `ZeroWord;
        //id_pc <= if_pc;
        id_inst <= `ZeroWord;
    end
    else if(rdy == 1'b0 || stall[2] == 1'b1) begin
    end
    else if (stall[1] == 1'b1 || prediction_res == 1'b0)  begin
        id_pc <= `ZeroWord;
        id_inst <= `ZeroWord;
    end
    else if (stall[1] == 1'b0) begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end
endmodule