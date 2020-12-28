`timescale 1ns / 1ps
`include "config.v"
module mem_ctrl(
    input wire clk,
    input wire rst,
    
    input wire ifjump,

    //input wire[`Addrlen - 1 : 0] pc,
    input wire[`Addrlen - 1 : 0] if_addr,
    input wire[`Addrlen - 1 : 0] mem_addr,

    input wire[`Reglen - 1 : 0] mem_data_i,
    output reg[`Reglen - 1 : 0] mem_data_o,

    input wire if_readwrite,
    input wire[1 : 0] mem_readwrite,
    input wire[2 : 0] mem_times,

    output reg[1 : 0] if_status,
    output reg[1 : 0] mem_status,

    //to out
    input wire[7 : 0] data_from_out,
    output reg[7 : 0] data_to_out,
    output reg out_readwrite,
    output reg[`Addrlen - 1 : 0] addr_to_out
);

reg[2 : 0] times;
reg[2 : 0] cnt;
reg[1 : 0] status;

always @(*) begin
    if (ifjump == 1'b1 && mem_readwrite == 2'b00) begin
        status = `Init;
    end
end
always @(posedge clk ) begin
    if (rst == `ResetEnable) begin
        status <= `Init;
        mem_data_o <= `ZeroWord;
        if_status <= `Init;
        mem_status <= `Init;
        out_readwrite <= 1'b0;
        data_to_out <= `ZeroWord;
        addr_to_out <= `ZeroWord;
        times <= 3'b000;
        cnt <= 3'b000;
    end
    else begin
        case (status)
            `Init: begin
                mem_data_o <= `ZeroWord;
                if_status <= `Init;
                mem_status <= `Init;
                out_readwrite <= 1'b0;
                data_to_out <= `ZeroWord;
                addr_to_out <= `ZeroWord;
                cnt <= 3'b000;
                if (mem_readwrite != 2'b00) begin
                    if (mem_readwrite == 2'b01) begin
                        out_readwrite <= 1'b0;
                        status <= `Read;
                    end
                    else begin
                        out_readwrite <= 1'b1;
                        status <= `Write;
                        data_to_out <= mem_data_i[7 : 0];
                    end
                    addr_to_out <= mem_addr;
                    mem_status <= `Work;
                    times <= mem_times;
                end
                else if (if_readwrite != 1'b0) begin
                    out_readwrite <= 1'b0;
                    addr_to_out <= if_addr;
                    if_status <= `Work;
                    status <= `Read;
                    times <= 3'b100;
                end
            end
            `Read: begin
                if (cnt == 3'b001) begin
                    mem_data_o[7 : 0] <= data_from_out;
                end
                else if (cnt == 3'b010) begin
                    mem_data_o[15 : 8] <= data_from_out;
                end
                else if (cnt == 3'b011) begin
                    mem_data_o[23 : 16] <= data_from_out;
                end
                else if (cnt == 3'b100) begin
                    mem_data_o[31 : 24] <= data_from_out;
                end
                if (cnt <= 3'b011 && times >= 3'b001) begin
                    addr_to_out <= addr_to_out + 1'b1;
                end
                cnt <= cnt + 1'b1;
                times <= times - 1'b1;
                if (times == 3'b000 || cnt == 3'b100) begin
                    status <= `Init;
                    addr_to_out <= 0;
                    if (if_status == `Work) begin
                        if_status <= `Done;
                    end
                    else begin
                        mem_status <= `Done;
                    end
                end
            end 
            `Write: begin 
                if (cnt == 3'b000) begin
                    data_to_out <= mem_data_i[15 : 8];
                end
                else if (cnt == 3'b001) begin
                    data_to_out <= mem_data_i[23 : 16];
                end
                else if (cnt == 3'b010) begin
                    data_to_out <= mem_data_i[31 : 24];
                end
                cnt <= cnt + 1'b1;
                times <= times - 1'b1;
                addr_to_out <= addr_to_out + 1'b1;
                if (cnt == 3'b010 || times <= 3'b010) begin
                    mem_status <= `Done;
                    status <= `Init;
                end
            end   
            default: begin
            end
        endcase
    end
end 

endmodule
