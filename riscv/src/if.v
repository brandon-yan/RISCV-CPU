`timescale 1ns / 1ps
`include "config.v"
module ifetch (
    input wire rst,
    input wire clk,
    
    input wire[`Addrlen - 1 : 0] pc_i,
    output reg[`Addrlen - 1 : 0] pc_o,

    input wire[1 : 0] if_status,
    input wire[`Instlen - 1 : 0] data_from_mem,
    //output reg[`Addrlen - 1 : 0] if_addr,
    output reg if_readwrite,
    output reg[`Instlen - 1 : 0] inst,

    //input wire[5 : 0] stall,
    output reg if_stall_req

);

integer i;
reg[40 : 0] icache[127 : 0];


always @(posedge clk) begin
    if (rst == `ResetEnable) begin
        for (i = 0; i < 128; i = i + 1) begin
            icache[i][40] <= 1'b1;
        end
    end
    else begin
        if (if_status == `Done) begin
            icache[pc_o[8 : 2]] <= {1'b0, pc_o[16 : 9], inst};
        end
        else begin
        end
    end
end

always @(*) begin
    if (rst == `ResetEnable) begin
        pc_o = `ZeroWord;
        if_readwrite = 1'b0;
        inst = `ZeroWord;
        if_stall_req = 1'b0;
    end
    else if ((icache[pc_i[8 : 2]][39 : 32] == pc_i[16 : 9]) && icache[pc_i[8 : 2]][40] == 1'b0) begin
            pc_o = pc_i;
            if_readwrite = 1'b0;
            inst = icache[pc_i[8 : 2]][31 : 0];
            if_stall_req = 1'b0;
        end
    else begin
        if (if_status == `Done) begin
            pc_o = pc_i;
            if_readwrite = 1'b0;
            inst = data_from_mem;
            if_stall_req = 1'b0;
        end
        else if (if_status == `Init) begin
            pc_o = pc_i;
            if_readwrite = 1'b1;
            inst = `ZeroWord;
            if_stall_req = 1'b1;
        end
        else begin
            pc_o = pc_i;
            if_readwrite = 1'b1;
            inst = `ZeroWord;
            if_stall_req = 1'b1;
        end
    end
end    

endmodule