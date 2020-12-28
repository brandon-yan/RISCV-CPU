`timescale 1ns / 1ps
`include "config.v"
module mem(
    input wire rst,
    input wire clk,
    
    input wire[`Reglen - 1 : 0] rd_data_i,
    input wire[`RegAddrlen - 1 : 0] rd_addr_i,
    input wire[`Addrlen - 1 : 0] mem_addr_i,
    input wire rd_enable_i,
    input wire [`AluOPlen - 1 : 0] aluop_i,
    input wire [`AluSellen - 1 : 0] alusel_i,

    output reg[`Reglen - 1 : 0] rd_data_o,
    output reg[`RegAddrlen - 1 : 0] rd_addr_o,
    output reg rd_enable_o,

    // to mem_ctrl
    input wire[`Reglen - 1 : 0] data_from_mem,
    input wire[`MemStatus - 1 : 0] mem_status,

    output reg[`Addrlen - 1 : 0] mem_addr_o,
    output reg[`Reglen - 1 : 0] data_to_mem,
    output reg[2 : 0] mem_times,
    output reg[1 : 0] mem_readwrite,

    // to stall_ctrl
    input wire[5 : 0] stall,
    output reg mem_stall_req
);


always @(*) begin
    if (rst == `ResetEnable) begin
        rd_data_o = `ZeroWord;
        rd_addr_o = `ZeroReg;
        rd_enable_o = `WriteDisable;
        mem_addr_o = `ZeroWord;
        data_to_mem = `ZeroWord;
        mem_times = 0;
        mem_readwrite = 0;
        mem_stall_req = 1'b0;
    end
    else if (alusel_i == `EXE_LOAD) begin
        rd_data_o = `ZeroWord;
        rd_addr_o = rd_addr_i;
        rd_enable_o = `WriteEnable;
        mem_addr_o = rd_data_i;
        data_to_mem = `ZeroWord;
        mem_readwrite = 2'b01;
        case (aluop_i)
                `LB: begin
                    mem_times = 3'b001;
                end 
                `LH: begin
                    mem_times = 3'b010;
                end
                `LW: begin
                    mem_times = 3'b100;
                end
                `LBU: begin
                    mem_times = 3'b001;
                end
                `LHU: begin
                    mem_times = 3'b010;
                end
                default: begin
                end
            endcase
        if (mem_status == `Done) begin
            mem_stall_req = 1'b0;
            case (aluop_i)
            `LB: begin
                rd_data_o = $signed(data_from_mem[7 : 0]);
            end 
            `LH: begin
                rd_data_o = $signed(data_from_mem[15 : 0]);
            end
            `LW: begin
                rd_data_o = $signed(data_from_mem[31 : 0]);
            end
            `LBU: begin
                rd_data_o = {{24{1'b0}}, data_from_mem[7 : 0]};
            end
            `LHU: begin
                rd_data_o = {{16{1'b0}}, data_from_mem[15 : 0]};
            end
            default: begin
            end
        endcase
        end
        else if (mem_status == `Init) begin
            mem_stall_req = 1'b1;
        end
        else begin
            mem_stall_req = 1'b1;
        end
    end
    else if (alusel_i == `EXE_STORE) begin
        rd_data_o = `ZeroWord;
        rd_addr_o = rd_addr_i;
        rd_enable_o = `WriteDisable;
        mem_addr_o = mem_addr_i;
        data_to_mem = rd_data_i;
        mem_readwrite = 2'b10;
        case (aluop_i)
            `SB: begin
                mem_times = 3'b001;
            end 
            `SH: begin
                mem_times = 3'b010;
            end
            `SW: begin
                mem_times = 3'b100;
            end
            default: begin
            end
        endcase
        if (mem_status == `Done) begin
            mem_stall_req = 1'b0;
            mem_readwrite = 2'b00;
        end
        else if (mem_status == `Init) begin
            mem_stall_req = 1'b1;
        end
        else begin
            mem_stall_req = 1'b1;
        end
    end
    else begin
        rd_data_o = rd_data_i;
        rd_addr_o = rd_addr_i;
        rd_enable_o = rd_enable_i;
        mem_addr_o = `ZeroWord;
        data_to_mem = `ZeroWord;
        mem_times = 3'b000;
        mem_readwrite = 1'b0;
        mem_stall_req = 1'b0;
    end
end

endmodule