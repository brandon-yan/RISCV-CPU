`timescale 1ns / 1ps
`include "config.v"
module register(
    input wire clk,
    input wire rst,
    //write
    input wire write_enable,
    input wire[`RegAddrlen - 1 : 0] write_addr,
    input wire[`Reglen - 1 : 0] write_data,
    //read 1
    input wire read_enable1,   
    input wire[`RegAddrlen - 1 : 0] read_addr1,
    output reg[`Reglen - 1 : 0] read_data1,
    //read 2
    input wire read_enable2,   
    input wire[`RegAddrlen - 1 : 0] read_addr2,
    output reg[`Reglen - 1 : 0] read_data2
);
reg[`Reglen - 1 : 0] regs[`Regnum - 1 : 0];
integer i;
//write 1
always @(posedge clk) begin
    if (rst == `ResetEnable) begin
        for (i = 0; i < 32; i = i + 1)
            regs[i] = `ZeroWord;
        end
    else if (rst == `ResetDisable && write_enable == `WriteEnable) begin
        if (write_addr != `ZeroReg)  begin //not zero register
            regs[write_addr] <= write_data;
        end
    end
end

//read 1
always @ (*) begin
    if (rst == `ResetDisable && read_enable1 == `ReadEnable) begin
        if (read_addr1 == `ZeroReg) begin
            read_data1 = `ZeroWord;
        end
        else if (read_addr1 == write_addr && write_enable == `WriteEnable) begin
            read_data1 = write_data;
        end
        else begin
            read_data1 = regs[read_addr1];
        end 
    end
    else begin
        read_data1 = `ZeroWord;
    end
end

//read 2
always @ (*) begin
    if (rst == `ResetDisable && read_enable2 == `ReadEnable) begin
        if (read_addr2 == `ZeroReg) begin
            read_data2 = `ZeroWord;
        end
        else if (read_addr2 == write_addr && write_enable == `WriteEnable) begin
            read_data2 = write_data;
        end
        else begin
            read_data2 = regs[read_addr2];
        end
    end
    else begin
        read_data2 = `ZeroWord;
    end
end

endmodule