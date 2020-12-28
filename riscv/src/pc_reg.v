`timescale 1ns / 1ps
`include "config.v"
module pc_reg(
    input wire clk,
    input wire rst,

    //from stall_ctrl
    input wire[5 : 0] stall,

    //from ex
    input wire ifjump,
    input wire[`Addrlen - 1 : 0] jumpaddr,

    output reg[`Addrlen - 1 : 0] pc,
    output reg ifjump_o
    //output reg chip_enable

);
    
//always @(posedge clk ) begin
//    if (rst == `ResetEnable) begin
//        chip_enable <= `ChipDisable;
//    end
//    else begin
//        chip_enable <= `ChipEnable;
//    end
//end

always @(posedge clk ) begin
    //if (chip_enable == `ChipDisable) begin
    if (rst == `ResetEnable) begin
        pc <= `ZeroWord;
        ifjump_o <= ifjump;
    end
    else if (ifjump == `Branch) begin
        pc <= jumpaddr;
        ifjump_o <= ifjump;
    end
    else if (stall[0] == `NoStop) begin
        pc <= pc + 4'h4;
        ifjump_o <= ifjump;
    end
end


endmodule