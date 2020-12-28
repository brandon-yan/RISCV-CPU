`timescale 1ns / 1ps

`define ZeroWord 32'h00000000
`define ZeroReg 5'b00000

`define Instlen 32
`define Addrlen 32
`define Reglen 32
`define Regnum 32
`define RegAddrlen 5

`define ResetEnable 1'b1
`define ResetDisable 1'b0
`define ChipEnable 1'b1
`define ChipDisable 1'b0
`define WriteEnable 1'b1
`define WriteDisable 1'b0
`define ReadEnable 1'b1
`define ReadDisable 1'b0

`define Stop 1'b1
`define NoStop 1'b0

`define Branch 1'b1
`define NoBranch 1'b0

`define RAM_SIZE 100
`define RAM_SIZELOG2 17

//MemStatus
`define MemStatus 2

`define Init 2'b00
`define Work 2'b01
`define Read 2'b01
`define Write 2'b10
`define Done 2'b11

//OPCODE
`define OPlen    7
`define OPLUI    7'b0110111
`define OPAUIPC  7'b0010111
`define OPJAL    7'b1101111
`define OPJALR   7'b1100111
`define OPBRANCH 7'b1100011
`define OPLOAD   7'b0000011
`define OPSTORE  7'b0100011
`define OPARITHI   7'b0010011
`define OPARITH    7'b0110011

//fun3
`define fun3len   3
`define fun3JALR  3'b000
`define fun3BEQ   3'b000
`define fun3BNE   3'b001
`define fun3BLT   3'b100
`define fun3BGE   3'b101
`define fun3BLTU  3'b110
`define fun3BGEU  3'b111
`define fun3LB    3'b000
`define fun3LH    3'b001
`define fun3LW    3'b010
`define fun3LBU   3'b100
`define fun3LHU   3'b100
`define fun3SB    3'b000
`define fun3SH    3'b001 
`define fun3SW    3'b010
`define fun3ADDI  3'b000
`define fun3SLTI  3'b010   
`define fun3SLTIU 3'b011  
`define fun3XORI  3'b100 
`define fun3ORI   3'b110 
`define fun3ANDI  3'b111 
`define fun3SLLI  3'b001 
`define fun3SRLI  3'b101
`define fun3SRAI  3'b101
`define fun3ADD   3'b000
`define fun3SUB   3'b000
`define fun3SLL   3'b001
`define fun3SLT   3'b010
`define fun3SLTU  3'b011
`define fun3XOR   3'b100
`define fun3SRL   3'b101
`define fun3SRA   3'b101
`define fun3OR    3'b110
`define fun3AND   3'b111

//fun7
`define fun7len   7
`define fun7op1   7'b0000000
`define fun7op2   7'b0100000

//AluSel
`define AluSellen  3
`define EXE_NOP    3'b000
`define EXE_LUI    3'b001
`define EXE_AUIPC  3'b010
`define EXE_JAL    3'b011
`define EXE_ARITH  3'b100
`define EXE_LOAD   3'b101
`define EXE_STORE  3'b110
`define EXE_BRANCH 3'b111

//AluOP
`define AluOPlen 5
`define NOP    5'b00000
`define LUI    5'b00001
`define AUIPC  5'b00010
`define JAL    5'b00011
`define JALR   5'b00100
`define BEQ    5'b00101
`define BNE    5'b00110
`define BLT    5'b00111
`define BGE    5'b01000
`define BLTU   5'b01001
`define BGEU   5'b01010
`define LB     5'b01011
`define LH     5'b01100
`define LW     5'b01101
`define LBU    5'b01110
`define LHU    5'b01111
`define SB     5'b10000
`define SW     5'b10001
`define SH     5'b10010
`define ADD    5'b10011
`define SUB    5'b10100
`define SLL    5'b10101
`define SLT    5'b10110
`define SLTU   5'b10111
`define XOR    5'b11000
`define SRL    5'b11001
`define SRA    5'b11010
`define OR     5'b11011
`define AND    5'b11100
