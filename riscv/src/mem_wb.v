`timescale 1ns / 1ps
`include "config.v"
module mem_wb(
    input wire clk,
    input wire rst,
    input wire rdy,
    
    input wire[`Reglen - 1 : 0] mem_rd_data,
    input wire[`RegAddrlen - 1 : 0] mem_rd_addr,
    input wire mem_rd_enable,
    input wire[5 : 0] stall,

    output reg[`Reglen - 1 : 0] wb_rd_data,
    output reg[`RegAddrlen - 1 : 0] wb_rd_addr,
    output reg wb_rd_enable
);

always @ (posedge clk) begin
    if (rst == `ResetEnable || (stall[4] == 1'b1)) begin
        wb_rd_data <= `ZeroWord;
        wb_rd_addr <= `ZeroReg;
        wb_rd_enable <= `WriteDisable;
    end
    else if (rdy == 1'b0) begin
    end
    else if (stall[4] == 1'b0) begin
        wb_rd_data <= mem_rd_data;
        wb_rd_addr <= mem_rd_addr;
        wb_rd_enable <= mem_rd_enable;
    end
end

endmodule