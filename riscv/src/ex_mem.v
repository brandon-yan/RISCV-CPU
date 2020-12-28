`timescale 1ns / 1ps
`include "config.v"
module ex_mem(
    input wire clk,
    input wire rst,

    input wire[5 : 0] stall,

    input wire[`Reglen - 1 : 0] ex_rd_data,
    input wire[`RegAddrlen - 1 : 0] ex_rd_addr,
    input wire ex_rd_enable,
    input wire[`AluOPlen - 1 : 0] ex_aluop,
    input wire[`AluSellen - 1 : 0] ex_alusel,
    input wire[`Addrlen - 1 : 0] ex_mem_addr,

    output reg[`Reglen - 1 : 0] mem_rd_data,
    output reg[`RegAddrlen - 1 : 0] mem_rd_addr,
    output reg mem_rd_enable,
    output reg[`AluOPlen - 1 : 0] mem_aluop,
    output reg[`AluSellen - 1 : 0] mem_alusel,
    output reg[`Addrlen - 1 : 0] mem_mem_addr
);

always @ (posedge clk) begin
    if (rst == `ResetEnable) begin
        mem_rd_data <= `ZeroWord;
        mem_rd_addr <= `ZeroReg;
        mem_rd_enable <= 1'b0;
        mem_aluop <= `NOP;
        mem_alusel <= `EXE_NOP;
        mem_mem_addr <= `ZeroWord;
    end
    else if (stall[3] == 1'b0) begin
        mem_rd_data <= ex_rd_data;
        mem_rd_addr <= ex_rd_addr;
        mem_rd_enable <= ex_rd_enable;
        mem_aluop <= ex_aluop;
        mem_alusel <= ex_alusel;
        mem_mem_addr <= ex_mem_addr;
    end
end

endmodule