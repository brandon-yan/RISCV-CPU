`timescale 1ns / 1ps
`include "config.v"
module ex(
    input wire rst,

    input wire[`Reglen - 1 : 0] reg1,
    input wire[`Reglen - 1 : 0] reg2,
    input wire[`Reglen - 1 : 0] Imm,
    input wire[`RegAddrlen - 1 : 0] rd,
    input wire[`Addrlen - 1 : 0] pc,
    input wire rd_enable,
    input wire[`AluOPlen - 1 : 0] aluop,
    input wire[`AluSellen - 1 : 0] alusel,

    output reg[`Reglen - 1 : 0] rd_data_o,
    output reg[`RegAddrlen - 1 : 0] rd_addr,
    output reg[`Addrlen - 1 : 0] mem_addr,
    output reg[`AluOPlen - 1 : 0] aluop_o,
    output reg[`AluSellen - 1 : 0] alusel_o,
    output reg rd_enable_o,

    output reg ifjump,
    output reg[`Addrlen - 1 : 0] jumpaddr
);

reg[`Reglen - 1 : 0] res;

//do the calculation
always @(*) begin
    if (rst == `ResetEnable) begin
        res = `ZeroWord;
    end
    else begin
        case(aluop) 
            `AUIPC: begin
                res = pc + Imm;
            end
            `ADD: begin
                res = reg1 + reg2;
            end
            `SUB: begin
                res = reg1 - reg2;
            end
            `SLL: begin
                res = reg1 << reg2[4 : 0];
            end
            `SLT: begin
                res = $signed(reg1) < $signed(reg2);
            end
            `SLTU: begin
                res = reg1 < reg2;
            end
            `XOR: begin
                res = reg1 ^ reg2;
            end
            `SRL: begin
                res = reg1 >> reg2[4 : 0];
            end
            `SRA: begin
                res = reg1 >>> reg2[4 : 0];
            end
            `OR: begin
                res = reg1 | reg2;
            end
            `AND: begin
                res = reg1 & reg2;
            end
            default: begin
                res = 0;
            end 
        endcase
    end
end

//determine the output
always @(*) begin
    if (rst == `ResetEnable) begin
        rd_data_o = `ZeroWord;
        mem_addr = `ZeroWord;
        rd_addr = `ZeroReg;
        rd_enable_o = `WriteDisable;
        aluop_o = `NOP;
        alusel_o = `EXE_NOP;
    end
    else begin
        mem_addr = `ZeroWord;
        rd_addr = rd;
        rd_enable_o = rd_enable;
        aluop_o = aluop;
        alusel_o = alusel;
        case (alusel)
            `EXE_LUI: begin
                rd_data_o = Imm;
            end
            `EXE_AUIPC: begin
                rd_data_o = res;
            end
            `EXE_ARITH: begin
                rd_data_o = res;
            end
            `EXE_LOAD: begin
                rd_data_o = reg1 + reg2;
            end
            `EXE_STORE: begin
                rd_data_o = reg2;
                mem_addr = reg1 + Imm;
            end
            default: begin
                rd_data_o = `ZeroWord;
            end
        endcase
    end
end

always @(*) begin
    if (rst == `ResetEnable) begin
        ifjump = 1'b0;
        jumpaddr = `ZeroWord;
    end
    else begin
        ifjump = 1'b0;
        jumpaddr = `ZeroWord;
        case (aluop)
            `BEQ: begin
                if (reg1 == reg2) begin
                    ifjump = 1'b1;
                    jumpaddr = pc + Imm;
                end
                else begin
                    ifjump = 1'b0;
                    jumpaddr = pc + 4;
                end
            end 
            `BNE: begin
                if (reg1 != reg2) begin
                    ifjump = 1'b1;
                    jumpaddr = pc + Imm;
                end
                else begin
                    ifjump = 1'b0;
                    jumpaddr = pc + 4;
                end
            end
            `BLT: begin
                if (($signed(reg1)) < ($signed(reg2))) begin
                    ifjump = 1'b1;
                    jumpaddr = pc + Imm;
                end
                else begin
                    ifjump = 1'b0;
                    jumpaddr = pc + 4;
                end
            end
            `BLTU: begin
                if  (reg1 < reg2) begin
                    ifjump = 1'b1;
                    jumpaddr = pc + Imm;
                end
                else begin
                    ifjump = 1'b0;
                    jumpaddr = pc + 4;
                end
            end
            `BGE: begin
                if (($signed(reg1)) >= ($signed(reg2))) begin
                    ifjump = 1'b1;
                    jumpaddr = pc + Imm;
                end
                else begin
                    ifjump = 1'b0;
                    jumpaddr = pc + 4;
                end
            end
            `BGEU: begin
                if (reg1 >= reg2) begin
                    ifjump = 1'b1;
                    jumpaddr = pc + Imm;
                end
                else begin
                    ifjump = 1'b0;
                    jumpaddr = pc + 4;
                end
            end
            `JAL: begin
                ifjump = 1'b1;
                jumpaddr = pc + Imm;
                rd_data_o = pc + 4;
            end
            `JALR: begin
                ifjump = 1'b1;
                jumpaddr = (reg1 + Imm) & 32'hfffffffe;
                rd_data_o = pc + 4;
            end
            default: begin
            end
        endcase
    end
end
endmodule