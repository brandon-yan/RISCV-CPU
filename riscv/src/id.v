`timescale 1ns / 1ps
`include "config.v"
module id(
    input wire rst,
    
    input wire[`Addrlen - 1 : 0] pc,
    input wire[`Instlen - 1 : 0] inst,
    input wire[`Reglen - 1 : 0] reg1_data_i,
    input wire[`Reglen - 1 : 0] reg2_data_i,

    //to register
    output reg[`RegAddrlen - 1 : 0] reg1_addr_o,
    output reg reg1_read_enable,
    output reg[`RegAddrlen - 1 : 0] reg2_addr_o,
    output reg reg2_read_enable,

    //to next stage
    output reg[`Reglen - 1 : 0] reg1,
    output reg[`Reglen - 1 : 0] reg2,
    output reg[`Reglen - 1 : 0] Imm,
    output reg[`RegAddrlen - 1 : 0] rd,
    output reg rd_enable,
    output reg[`AluOPlen - 1 : 0] aluop,
    output reg[`AluSellen - 1 : 0] alusel,
    output reg[`Addrlen - 1 : 0] pc_o,

    //from ex forwarding
    input wire ex_rd_enable,
    input wire[`Reglen - 1 : 0] ex_rd_data,
    input wire[`RegAddrlen - 1 : 0] ex_rd_addr,

    //from mem forwarding
    input wire mem_rd_enable,
    input wire[`Reglen - 1 : 0] mem_rd_data,
    input wire[`RegAddrlen - 1 : 0] mem_rd_addr,

    //from id_ex read after load
    input wire isload,
    input wire[`RegAddrlen - 1 : 0] loadrd,
    output reg id_stall_req  

);

wire [`OPlen - 1 : 0] opcode;
wire [`fun3len - 1 : 0] fun3;
wire [`fun7len - 1 : 0] fun7;
reg useImminstead;
assign opcode[`OPlen - 1 : 0]  = inst[`OPlen - 1 : 0];
assign fun3[`fun3len - 1 : 0]  = inst[14 : 12];
assign fun7[`fun7len - 1 : 0]  = inst[31 : 25];

//decode
always @(*) begin
    if (rst == `ResetEnable) begin
        reg1_addr_o = `ZeroReg;
        reg2_addr_o = `ZeroReg;
    end
    else begin
        reg1_addr_o = inst[19 : 15];
        reg2_addr_o = inst[24 : 20];
    end
end

always @(*) begin
    Imm = `ZeroWord;
    rd_enable = `WriteDisable;
    reg1_read_enable = `ReadDisable;
    reg2_read_enable = `ReadDisable;
    rd = `ZeroReg;
    reg1 = `ZeroReg;
    reg2 = `ZeroReg;
    aluop = `NOP;
    alusel = `EXE_NOP;
    pc_o = pc;
    useImminstead = 1'b0;
    id_stall_req = 1'b0;
    case (opcode)
        `OPLUI: begin
            Imm = {inst[31 : 12], {12{1'b0}}};
            rd_enable = `WriteEnable;
            rd = inst[11 : 7];
            aluop = `LUI;
            alusel = `EXE_LUI;
        end 
        `OPAUIPC: begin
            Imm = {inst[31 : 12], {12{1'b0}}};
            rd_enable = `WriteEnable;
            rd = inst[11 : 7];
            aluop = `AUIPC;
            alusel = `EXE_AUIPC;
        end 
        `OPJAL: begin
            Imm = {{12{inst[31]}}, inst[19 : 12], inst[20], inst[30 : 21], 1'b0};
            rd_enable = `WriteEnable;
            rd = inst[11 : 7];
            aluop = `JAL;
            alusel = `EXE_JAL;
        end
        `OPJALR: begin
            Imm = {{20{inst[31]}}, inst[31 : 20]};
            rd_enable = `WriteEnable;
            reg1_read_enable = `ReadEnable;
            rd = inst[11 : 7];
            aluop = `JALR;
            alusel = `EXE_JAL;
        end 
        `OPBRANCH: begin
            Imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            rd_enable = `WriteDisable;
            reg1_read_enable = `ReadEnable;
            reg2_read_enable = `ReadEnable;
            alusel = `EXE_BRANCH;
            case (fun3)
                `fun3BEQ: begin
                    aluop = `BEQ;
                end 
                `fun3BNE: begin
                    aluop = `BNE;
                end
                `fun3BLT: begin
                    aluop = `BLT;
                end
                `fun3BGE: begin
                    aluop = `BGE;
                end
                `fun3BLTU: begin
                    aluop = `BLTU;
                end
                `fun3BGEU: begin
                    aluop = `BGEU;
                end
                default: begin
                end 
            endcase
        end 
        `OPLOAD: begin
            Imm = {{20{inst[31]}} ,inst[31:20]};
            rd_enable = `WriteEnable;
            rd = inst[11 : 7];
            reg1_read_enable = `ReadEnable;
            reg2_read_enable = `ReadDisable;
            useImminstead = 1'b1;
            alusel = `EXE_LOAD;
            case (fun3)
                `fun3LB: begin
                    aluop = `LB;
                end 
                `fun3LH: begin
                    aluop = `LH;
                end
                `fun3LW: begin
                    aluop = `LW;
                end
                `fun3LBU: begin
                    aluop = `LBU;
                end
                `fun3LHU: begin
                    aluop = `LHU;
                end
                default: begin
                end 
            endcase
        end
        `OPSTORE: begin
            Imm = {{20{inst[31]}} ,inst[31:25], inst[11:7]};
            rd_enable = `WriteDisable;
            reg1_read_enable = `ReadEnable;
            reg2_read_enable = `ReadEnable;
            alusel = `EXE_STORE;
            case (fun3)
                `fun3SB: begin
                    aluop = `SB;
                end 
                `fun3SH: begin
                    aluop = `SH;
                end
                `fun3SW: begin
                    aluop = `SW;
                end
                default: begin
                end 
            endcase
        end 
        `OPARITHI: begin
            Imm = {{20{inst[31]}} ,inst[31:20]};
            rd_enable = `WriteEnable;
            rd = inst[11 : 7];
            reg1_read_enable = `ReadEnable;
            reg2_read_enable = `ReadDisable;
            useImminstead = 1'b1;
            alusel = `EXE_ARITH;
            case (fun3)
                `fun3ADDI: begin
                    aluop = `ADD;
                end 
                `fun3SLTI: begin
                    aluop = `SLT;
                end
                `fun3SLTIU: begin
                    aluop = `SLTU;
                end
                `fun3XORI: begin
                    aluop = `XOR;
                end
                `fun3ORI: begin
                    aluop = `OR;
                end
                `fun3ANDI: begin
                    aluop = `AND;
                end
                `fun3SLLI: begin
                    aluop = `SLL;
                    Imm = {{27{1'b0}}, inst[24:20]};
                end
                `fun3SRLI: begin
                    case (fun7)
                        `fun7op1: begin
                            aluop = `SRL;
                            Imm = {{27{1'b0}}, inst[24:20]};
                        end 
                        `fun7op2: begin
                            aluop = `SRA;
                            Imm = {{27{1'b0}}, inst[24:20]};
                        end
                        default: begin
                        end 
                    endcase
                end
                default: begin
                end
            endcase
        end 
        `OPARITH: begin
            rd_enable = `WriteEnable;
            rd = inst[11 : 7];
            reg1_read_enable = `ReadEnable;
            reg2_read_enable = `ReadEnable;
            useImminstead = 1'b0;
            alusel = `EXE_ARITH;
            case (fun7)
                `fun7op1: begin
                    case (fun3)
                        `fun3ADD: begin
                            aluop = `ADD;
                        end 
                        `fun3SLL: begin
                            aluop = `SLL;
                        end
                        `fun3SLT: begin
                            aluop = `SLT;
                        end
                        `fun3SLTU: begin
                            aluop = `SLTU;
                        end
                        `fun3XOR: begin
                            aluop = `XOR;
                        end
                        `fun3SRL: begin
                            aluop = `SRL;
                        end
                        `fun3OR: begin
                            aluop = `OR;
                        end
                        `fun3AND: begin
                            aluop = `AND;
                        end
                        default: begin
                        end 
                    endcase
                end 
                `fun7op2: begin
                    case (fun3)
                        `fun3SUB: begin
                            aluop = `SUB;
                        end 
                        `fun3SRA: begin
                            aluop = `SRA;
                        end
                        default: begin
                        end 
                    endcase
                end
                default: begin
                end 
            endcase
        end
        default: begin
        end
    endcase
end

//Get rs1
always @ (*) begin
    if (rst == `ResetEnable) begin
        reg1 = `ZeroWord;
    end
    else if ((reg1_read_enable == `ReadEnable) && (ex_rd_enable == `WriteEnable) && (ex_rd_addr == reg1_addr_o)) begin
        reg1 = ex_rd_data;
    end
    else if ((reg1_read_enable == `ReadEnable) && (mem_rd_enable == `WriteEnable) && (mem_rd_addr == reg1_addr_o)) begin
        reg1 = mem_rd_data;
    end
    else if (reg1_read_enable == `ReadDisable) begin
        reg1 = `ZeroWord;
    end
    else begin
        reg1 = reg1_data_i;
    end
end

//Get rs2
always @ (*) begin
    if (rst == `ResetEnable) begin
        reg2 = `ZeroWord;
    end
    else if ((reg2_read_enable == `ReadEnable) && (ex_rd_enable == `WriteEnable) && (ex_rd_addr == reg2_addr_o)) begin
        reg2 = ex_rd_data;
    end
    else if ((reg2_read_enable == `ReadEnable) && (mem_rd_enable == `WriteEnable) && (mem_rd_addr == reg2_addr_o)) begin
        reg2 = mem_rd_data;
    end
    else if (reg2_read_enable == `ReadDisable) begin
        if (useImminstead == 1'b0) begin
            reg2 = `ZeroWord;
        end
        else begin
            reg2 = Imm;
        end
    end
    else begin
        reg2 = reg2_data_i;
    end
end

//read after load
always @(*) begin
    if (isload == 1'b1 && ((reg1_addr_o ==  loadrd) || (reg2_addr_o == loadrd))) begin
        id_stall_req = 1'b1;
    end
    else begin
        id_stall_req = 1'b0;
    end
end
endmodule