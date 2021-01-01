`include "config.v"

// RISCV32I CPU top module
// port modification allowed for debugging purposes

module cpu(
    input  wire                 clk_in,			// system clock signal
    input  wire                 rst_in,			// reset signal
	  input  wire					        rdy_in,			// ready signal, pause cpu when low

    input  wire [ 7:0]          mem_din,		// data input bus
    output wire [ 7:0]          mem_dout,		// data output bus
    output wire [31:0]          mem_a,			// address bus (only 17:0 is used)
    output wire                 mem_wr,			// write/read signal (1 for write)
	
	input  wire                 io_buffer_full, // 1 if uart buffer is full
	
	output wire [31:0]			dbgreg_dout		// cpu register output (debugging demo)
);

// implementation goes here

// Specifications:
// - Pause cpu(freeze pc, registers, etc.) when rdy_in is low
// - Memory read result will be returned in the next cycle. Write takes 1 cycle(no need to wait)
// - Memory is of size 128KB, with valid address ranging from 0x0 to 0x20000
// - I/O port is mapped to address higher than 0x30000 (mem_a[17:16]==2'b11)
// - 0x30000 read: read a byte from input
// - 0x30000 write: write a byte to output (write 0x00 is ignored)
// - 0x30004 read: read clocks passed since cpu starts (in dword, 4 bytes)
// - 0x30004 write: indicates program stop (will output '\0' through uart tx)

//pc_reg
wire[`Addrlen - 1 : 0] pc;
wire ifjump_o;

//if
wire[`Addrlen - 1 : 0] if_pc;
wire if_readwrite;
wire[`Instlen - 1 : 0] if_inst;
wire if_stall_req;
//wire[`Addrlen - 1 : 0] if_addr;

//if_id
wire[`Addrlen - 1 : 0] id_pc;
wire[`Instlen - 1 : 0] id_inst;

//id
wire[`RegAddrlen - 1 : 0] reg1_addr_o;
wire reg1_read_enable;
wire[`RegAddrlen - 1 : 0] reg2_addr_o;
wire reg2_read_enable;

wire[`Reglen - 1 : 0] id_reg1;
wire[`Reglen - 1 : 0] id_reg2;
wire[`Reglen - 1 : 0] id_Imm;
wire[`RegAddrlen - 1 : 0] id_rd;
wire id_rd_enable;
wire[`AluOPlen - 1 : 0] id_aluop;
wire[`AluSellen - 1 : 0] id_alusel;
wire[`Addrlen - 1 : 0] id_pc_o;
wire id_stall_req;

//id_ex
wire[`Reglen - 1 : 0] ex_reg1;
wire[`Reglen - 1 : 0] ex_reg2;
wire[`Reglen - 1 : 0] ex_Imm;
wire[`RegAddrlen - 1 : 0] ex_rd;
wire ex_rd_enable;
wire[`AluOPlen - 1 : 0] ex_aluop;
wire[`AluSellen - 1 : 0] ex_alusel;
wire[`Addrlen - 1 : 0] ex_pc;

wire isload;
wire [`RegAddrlen - 1 : 0] loadrd;

//ex
wire[`Reglen - 1 : 0] ex_rd_data_o;
wire[`RegAddrlen - 1 : 0] ex_rd_addr_o;
wire[`Addrlen - 1 : 0] ex_mem_addr;
wire[`AluOPlen - 1 : 0] ex_aluop_o;
wire[`AluSellen - 1 : 0] ex_alusel_o;
wire ex_rd_enable_o;
wire ifjump;
wire[`Addrlen - 1 : 0] jumpaddr;

//ex_mem
wire[`Reglen - 1 : 0] mem_rd_data;
wire[`RegAddrlen - 1 : 0] mem_rd_addr;
wire mem_rd_enable;
wire[`AluOPlen - 1 : 0] mem_aluop;
wire[`AluSellen - 1 : 0] mem_alusel;
wire[`Addrlen - 1 : 0] mem_mem_addr;

//mem
wire[`Reglen - 1 : 0] mem_rd_data_o;
wire[`RegAddrlen - 1 : 0] mem_rd_addr_o;
wire mem_rd_enable_o;

wire[`Addrlen - 1 : 0] mem_addr_o;
wire[`Reglen - 1 : 0] data_to_mem;
wire[2 : 0] mem_times;
wire[1 : 0] mem_readwrite;
wire mem_stall_req;

//mem_wb
wire[`Reglen - 1 : 0] wb_rd_data;
wire[`RegAddrlen - 1 : 0] wb_rd_addr;
wire wb_rd_enable;

//stall_ctrl
wire[5 : 0] stall;

//mem_ctrl
wire[`Reglen - 1 : 0] mem_data_o;
wire[1 : 0] if_status;
wire[1 : 0] mem_status;
wire[7 : 0] data_to_out;
wire out_readwrite;
wire[`Addrlen - 1 : 0] addr_to_out;
wire jumpstall;

//register
wire[`Reglen - 1 : 0] read_data1;
wire[`Reglen - 1 : 0] read_data2;

pc_reg _pc_reg (
  .rst(rst_in), .clk(clk_in), .stall(stall), 
  .ifjump(ifjump), .jumpaddr(jumpaddr), .pc(pc), .ifjump_o(ifjump_o)
);

ifetch _ifetch (
  .rst(rst_in), .clk(clk_in), .pc_i(pc), .pc_o(if_pc), 
  .if_status(if_status), .data_from_mem(mem_data_o),
  .if_readwrite(if_readwrite), .inst(if_inst),
  .if_stall_req(if_stall_req)
);

if_id _if_id (
  .rst(rst_in), .clk(clk_in), .stall(stall),
  .ifjump(ifjump), .if_pc(if_pc), .if_inst(if_inst),
  .id_pc(id_pc), .id_inst(id_inst)
);

id _id (
  .rst(rst_in), .pc(id_pc), .inst(id_inst),
  .reg1_data_i(read_data1), .reg2_data_i(read_data2), 
  .reg1_addr_o(reg1_addr_o), .reg2_addr_o(reg2_addr_o),
  .reg1_read_enable(reg1_read_enable), .reg2_read_enable(reg2_read_enable),
  .reg1(id_reg1), .reg2(id_reg2), .Imm(id_Imm), .rd(id_rd),
  .rd_enable(id_rd_enable), .aluop(id_aluop), .alusel(id_alusel), .pc_o(id_pc_o),
  .ex_rd_enable(ex_rd_enable_o), .ex_rd_data(ex_rd_data_o),
  .ex_rd_addr(ex_rd_addr_o),  .mem_rd_enable(mem_rd_enable_o),
  .mem_rd_data(mem_rd_data_o), .mem_rd_addr(mem_rd_addr_o),
  .isload(isload), .loadrd(loadrd), .id_stall_req(id_stall_req)
);

id_ex _id_ex (
  .clk(clk_in), .rst(rst_in), .stall(stall), .ifjump(ifjump), 
  .id_reg1(id_reg1), .id_reg2(id_reg2), .id_Imm(id_Imm), .id_rd(id_rd),
  .id_rd_enable(id_rd_enable), .id_aluop(id_aluop), .id_alusel(id_alusel), .pc(id_pc_o),
  .ex_reg1(ex_reg1), .ex_reg2(ex_reg2), .ex_Imm(ex_Imm), .ex_rd(ex_rd), .pc_o(ex_pc),
  .ex_rd_enable(ex_rd_enable), .ex_aluop(ex_aluop), .ex_alusel(ex_alusel),
  .isload(isload), .loadrd(loadrd)
);

ex _ex (
  .rst(rst_in), .reg1(ex_reg1), .reg2(ex_reg2), .Imm(ex_Imm),
  .rd(ex_rd), .pc(ex_pc), .rd_enable(ex_rd_enable), 
  .aluop(ex_aluop), .alusel(ex_alusel), .rd_data_o(ex_rd_data_o),
  .rd_addr(ex_rd_addr_o), .mem_addr(ex_mem_addr), .aluop_o(ex_aluop_o),
  .alusel_o(ex_alusel_o), .rd_enable_o(ex_rd_enable_o), 
  .ifjump(ifjump), .jumpaddr(jumpaddr)
);

ex_mem _ex_mem (
  .clk(clk_in), .rst(rst_in), .stall(stall), 
  .ex_rd_data(ex_rd_data_o), .ex_rd_addr(ex_rd_addr_o), .ex_rd_enable(ex_rd_enable_o),
  .ex_aluop(ex_aluop_o), .ex_alusel(ex_alusel_o), .ex_mem_addr(ex_mem_addr),
  .mem_rd_data(mem_rd_data), .mem_rd_addr(mem_rd_addr), .mem_rd_enable(mem_rd_enable),
  .mem_aluop(mem_aluop), .mem_alusel(mem_alusel), .mem_mem_addr(mem_mem_addr)
);

mem _mem (
  .rst(rst_in), .clk(clk_in), .rd_data_i(mem_rd_data),
  .rd_addr_i(mem_rd_addr), .mem_addr_i(mem_mem_addr),
  .rd_enable_i(mem_rd_enable), .aluop_i(mem_aluop), .alusel_i(mem_alusel),
  .rd_data_o(mem_rd_data_o), .rd_addr_o(mem_rd_addr_o), 
  .rd_enable_o(mem_rd_enable_o), .data_from_mem(mem_data_o),
  .mem_status(mem_status), .mem_addr_o(mem_addr_o),
  .data_to_mem(data_to_mem), .mem_times(mem_times), 
  .mem_readwrite(mem_readwrite), .stall(stall), .mem_stall_req(mem_stall_req)
);

mem_wb _mem_wb (
  .clk(clk_in), .rst(rst_in), .mem_rd_data(mem_rd_data_o),
  .mem_rd_addr(mem_rd_addr_o), .mem_rd_enable(mem_rd_enable_o),
  .wb_rd_data(wb_rd_data), .wb_rd_addr(wb_rd_addr), 
  .wb_rd_enable(wb_rd_enable), .stall(stall)
);

stall_ctrl _stall_ctrl (
  .rst(rst_in), .stallreq_from_id(id_stall_req),
  .stallreq_from_if(if_stall_req), .stallreq_from_mem(mem_stall_req),
  .stall(stall), .jumpstall(jumpstall)
);

mem_ctrl _mem_ctrl (
  .clk(clk_in), .rst(rst_in), .if_addr(if_pc),
  .mem_addr(mem_addr_o), .mem_data_i(data_to_mem), .mem_data_o(mem_data_o), 
  .if_readwrite(if_readwrite), .mem_readwrite(mem_readwrite), .mem_times(mem_times),
  .if_status(if_status), .mem_status(mem_status),
  .data_from_out(mem_din), .data_to_out(mem_dout), 
  .out_readwrite(mem_wr), .addr_to_out(mem_a), .ifjump(ifjump_o), .jumpstall(jumpstall)
);

register _register (
  .clk(clk_in), .rst(rst_in), .write_enable(wb_rd_enable),
  .write_addr(wb_rd_addr), .write_data(wb_rd_data),
  .read_enable1(reg1_read_enable), .read_enable2(reg2_read_enable),
  .read_addr1(reg1_addr_o), .read_addr2(reg2_addr_o),
  .read_data1(read_data1), .read_data2(read_data2)
);

always @(posedge clk_in)
  begin
    if (rst_in)
      begin
      
      end
    else if (!rdy_in)
      begin
      
      end
    else
      begin
      
      end
  end

endmodule