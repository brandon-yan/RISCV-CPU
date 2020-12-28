`timescale 1ns / 1ps
`include "config.v"
module if_id(
    input wire clk,
    input wire rst,

    input wire[5 : 0] stall,
    input wire ifjump,
    input wire[`Addrlen - 1 : 0] if_pc,
    input wire[`Instlen - 1 : 0] if_inst,
    output reg[`Addrlen - 1 : 0] id_pc,
    output reg[`Instlen - 1 : 0] id_inst
);

always @(posedge clk ) begin
    if (rst == `ResetEnable || stall[1] || ifjump) begin
        //id_pc <= `ZeroWord;
        id_pc <= if_pc;
        id_inst <= `ZeroWord;
    end
    else  begin
        id_pc <= if_pc;
        id_inst <= if_inst;
    end
end
endmodule