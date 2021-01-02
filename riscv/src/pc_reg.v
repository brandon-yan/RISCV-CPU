`timescale 1ns / 1ps
`include "config.v"
module pc_reg(
    input wire clk,
    input wire rst,
    input wire rdy,

    //from stall_ctrl
    input wire[5 : 0] stall,

    //from ex
    input wire prediction_res,
    input wire[`Addrlen - 1 : 0] jumpaddr,
    input wire branch_taken,
    input wire branch_flag,
    input wire[`Addrlen - 1 : 0] branch_pc,
    input wire[`Addrlen - 1 : 0] branch_target,

    output reg[`Addrlen - 1 : 0] pc

);
    
reg[31 : 0] BTB[127 : 0];
reg[10 : 0] BHT[127 : 0];
integer i;

always @(posedge clk ) begin
    if (rst == `ResetEnable) begin
        pc <= `ZeroWord;
    end
    else if (rdy == 1'b0) begin
    end
    else if (prediction_res == 1'b0) begin
        pc <= jumpaddr;
    end
    else if (stall[0] == `NoStop) begin
        if ((pc[17 : 9] == BHT[pc[8 : 2]][10 : 2]) && BHT[pc[8 : 2]][1] == 1'b1) begin
            pc <= BTB[pc[8 : 2]];
        end
        else begin
            pc <= pc + 4'h4;
        end
    end
end

always @(posedge clk ) begin
    if (rst == `ResetEnable) begin
        for (i = 0; i < 128; i = i + 1) begin
            BHT[i][10] <= 1'b1;
            BHT[i][1 : 0] <= 2'b01;
        end
    end
    else if (branch_flag) begin
        BTB[branch_pc[8 : 2]] <= branch_target;
        BHT[branch_pc[8 : 2]][10 : 2] <= branch_pc[17 : 9];
        if (branch_taken == 1'b0 && BHT[branch_pc[8 : 2]][1 : 0] != 2'b00) begin
            BHT[branch_pc[8 : 2]][1 : 0] <= BHT[branch_pc[8 : 2]][1 : 0] - 1'b1;
        end
        else if (branch_taken == 1'b1 && BHT[branch_pc[8 : 2]][1 : 0] != 2'b11) begin
            BHT[branch_pc[8 : 2]][1 : 0] <= BHT[branch_pc[8 : 2]][1 : 0] + 1'b1;
        end
    end
end

endmodule