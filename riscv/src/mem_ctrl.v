`timescale 1ns / 1ps
`include "config.v"
module mem_ctrl(
    input wire clk,
    input wire rst,
    input wire rdy,
    
    input wire ifjump,

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
    output reg[`Addrlen - 1 : 0] out_addr
    
);

reg[2 : 0] times;
reg[2 : 0] cnt;
reg[1 : 0] status;

// always @(*) begin
//     if (ifjump == 1'b1 && mem_status != `Work) begin
//         status = `Init;
//         jumpstall = 1'b0;
//     end
//     else begin
//         jumpstall = ifjump;
//     end
// end

always @(posedge clk ) begin
    if (rst == `ResetEnable) begin
        status <= `Init;
        mem_data_o <= `ZeroWord;
        if_status <= `Init;
        mem_status <= `Init;
        out_readwrite <= 1'b0;
        data_to_out <= `ZeroWord;
        out_addr <= `ZeroWord;
        times <= 3'b000;
        cnt <= 3'b000;
    end
    else if (rdy == 1'b0) begin
    end
    else begin
        case (status)
            `Init: begin
                mem_data_o <= `ZeroWord;
                if_status <= `Init;
                mem_status <= `Init;
                out_readwrite <= 1'b0;
                data_to_out <= `ZeroWord;
                out_addr <= `ZeroWord;
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
                    out_addr <= mem_addr;
                    mem_status <= `Work;
                    times <= mem_times;
                end
                else if (if_readwrite != 1'b0 && mem_status != `Work) begin
                    out_readwrite <= 1'b0;
                    out_addr <= if_addr;
                    if (ifjump == 1'b1) begin
                        if_status <= `Init;
                        status <= `Init;
                    end
                    else begin
                        if_status <= `Work;
                        status <= `Read;
                    end
                    times <= 3'b100;
                end
            end
            `Read: begin
                if (ifjump == 1'b1 && mem_status != `Work) begin
                    if_status <= `Init;
                    status <= `Init;
                    mem_data_o <= `ZeroWord;
                end
                else begin
                    case (cnt)
                        `Read0: begin
                            mem_data_o[7 : 0] <= data_from_out;
                            cnt <= cnt + 1'b1;
                            out_addr <= out_addr + 1'b1;
                        end 
                        `Read1: begin
                            mem_data_o[15 : 8] <= data_from_out;
                            cnt <= cnt + 1'b1;
                            out_addr <= out_addr + 1'b1;
                        end
                        `Read2: begin
                            mem_data_o[23 : 16] <= data_from_out;
                            cnt <= cnt + 1'b1;
                            out_addr <= out_addr + 1'b1;
                        end
                        `Read3: begin
                            mem_data_o[31 : 24] <= data_from_out;
                            cnt <= cnt + 1'b1;
                        end
                        default: begin
                            cnt <= cnt + 1'b1;
                            out_addr <= out_addr + 1'b1;
                        end
                    endcase
                    if (cnt == times) begin
                        status <= `Init;
                        out_addr <= `ZeroWord;
                        if (if_status == `Work) begin
                            if_status <= `Done;
                        end
                        else begin
                            mem_status <= `Done;
                        end
                    end
                end
            end 
            `Write: begin 
                case (cnt)
                    `Write0: begin
                        data_to_out <= mem_data_i[15 : 8];
                        cnt <= cnt + 1'b1;
                        times <= times - 1'b1;
                        out_addr <= out_addr + 1'b1;
                    end 
                    `Write1: begin
                        data_to_out <= mem_data_i[23 : 16];
                        cnt <= cnt + 1'b1;
                        times <= times - 1'b1;
                        out_addr <= out_addr + 1'b1;
                    end
                    `Write2: begin
                        data_to_out <= mem_data_i[31 : 24];
                        cnt <= cnt + 1'b1;
                        times <= times - 1'b1;
                        out_addr <= out_addr + 1'b1;
                    end
                    default: begin
                        cnt <= cnt + 1'b1;
                        times <= times - 1'b1;
                        out_addr <= out_addr + 1'b1;
                    end
                endcase
                if (cnt == 3'b010 || times <= 3'b001) begin
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
