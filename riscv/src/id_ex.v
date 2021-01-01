`timescale 1ns / 1ps
`include "config.v"
module id_ex(
    input wire clk,
    input wire rst,
    input wire rdy,
    
    input wire[5 : 0] stall,
    input wire ifjump,

    input wire[`Reglen - 1 : 0] id_reg1,
    input wire[`Reglen - 1 : 0] id_reg2,
    input wire[`Reglen - 1 : 0] id_Imm,
    input wire[`RegAddrlen - 1 : 0] id_rd,
    input wire id_rd_enable,
    input wire[`AluOPlen - 1 : 0] id_aluop,
    input wire[`AluSellen - 1 : 0] id_alusel,
    input wire[`Addrlen - 1 : 0] pc,

    output reg[`Reglen - 1 : 0] ex_reg1,
    output reg[`Reglen - 1 : 0] ex_reg2,
    output reg[`Reglen - 1 : 0] ex_Imm,
    output reg[`RegAddrlen - 1 : 0] ex_rd,
    output reg ex_rd_enable,
    output reg[`AluOPlen - 1 : 0] ex_aluop,
    output reg[`AluSellen - 1 : 0] ex_alusel,
    output reg[`Addrlen - 1 : 0] pc_o,

    //read after load
    output reg isload,
    output reg[`RegAddrlen - 1 : 0] loadrd
);

always @(posedge clk ) begin
    if (rst == `ResetEnable) begin
        ex_reg1 <= `ZeroReg;
        ex_reg2 <= `ZeroReg;
        ex_Imm <= `ZeroWord;
        ex_rd <= `ZeroReg;
        ex_rd_enable <= 1'b0;
        ex_alusel <= `EXE_NOP;
        ex_aluop <= `NOP;
        isload <= 1'b0;
        loadrd <= `ZeroReg;
        pc_o <= pc;
    end
    else if(rdy == 1'b0 || stall[3] == 1'b1) begin
    end
    else if (stall[2] == 1'b1 || ifjump) begin
        ex_reg1 <= `ZeroReg;
        ex_reg2 <= `ZeroReg;
        ex_Imm <= `ZeroWord;
        ex_rd <= `ZeroReg;
        ex_rd_enable <= 1'b0;
        ex_alusel <= `EXE_NOP;
        ex_aluop <= `NOP;
        isload <= 1'b0;
        loadrd <= `ZeroReg;
        pc_o <= pc;
    end
    else if(stall[2] == 1'b0) begin
        ex_reg1 <= id_reg1;
        ex_reg2 <= id_reg2;
        ex_Imm <= id_Imm;
        ex_rd <= id_rd;
        ex_rd_enable <= id_rd_enable;
        ex_alusel <= id_alusel;
        ex_aluop <= id_aluop;
        pc_o <= pc;
        if (id_alusel == `EXE_LOAD) begin
            isload <= 1'b1;
            loadrd <= id_rd;
        end
        else begin
            isload <= 1'b0;
            loadrd <= id_rd;
        end
    end
    
end
endmodule