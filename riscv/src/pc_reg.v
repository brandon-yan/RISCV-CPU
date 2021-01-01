`timescale 1ns / 1ps
`include "config.v"
module pc_reg(
    input wire clk,
    input wire rst,
    input wire rdy,

    //from stall_ctrl
    input wire[5 : 0] stall,

    //from ex
    input wire ifjump,
    input wire[`Addrlen - 1 : 0] jumpaddr,

    output reg[`Addrlen - 1 : 0] pc
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
    end
    else if (rdy == 1'b0) begin
    end
    else if (ifjump == `Branch) begin
        pc <= jumpaddr;
    end
    else if (stall[0] == `NoStop) begin
        pc <= pc + 4'h4;
    end
end


endmodule