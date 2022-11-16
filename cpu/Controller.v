module Controller (
    input [4:0] opcode,
    input [2:0] func3,
    input func7,
    input alu_out,
    output next_pc_sel,
    output [3:0] im_w_en,
    output wb_en,
    output alu_op1_sel,
    output alu_op2_sel,
    output jb_op1_sel,
    output [4:0] aopcode,
    output [2:0] afunc3,
    output afunc7,
    output wb_sel,
    output [3:0] dm_w_en
);

// define opcode
parameter LUI = 5'b01101, AUIPC = 5'b00101 ,JAL = 5'b11011 ,JALR = 5'b11001 , 
Btype = 5'b11000, LOAD = 5'b00000, STORE = 5'b01000, Itype = 5'b00100, Rtype = 5'b01100;

assign aopcode = opcode;
assign afunc3 = func3;
assign afunc7 = func7;
// im_w_en always 0
assign im_w_en = 4'b0;

// if (opcode == JAL or JALR ) next_pc_sel = 0
// else if (opcode != Btype) => next_pc_sel = 1
// else if (opcode == Btype) => if alu_out == 1 => jump => next_pc_sel = 0
assign next_pc_sel = (opcode == JAL) ? 0 :
                     (opcode == JALR) ? 0 :
                     (opcode != Btype) ? 1:
                     (alu_out == 1) ? 0 : 1;

// if (opcode == Btype or Store) => wb_en = 0
// else => wb_en = 1
assign wb_en = (opcode == Btype) ? 0 :
               (opcode == STORE) ? 0 : 1;

// if (opcode == AUIPC or JAL or JALR) => alu_op1_sel = 1
// else => alu_op1_sel = 0
assign alu_op1_sel = (opcode == AUIPC) ? 1 :
                     (opcode == JAL) ? 1 : 
                     (opcode == JALR) ? 1:0;

// if(opcode == Btype or Rtype) => alu_op2_sel = 0
// else => alu_op2_sel = 1
assign alu_op2_sel = (opcode == Rtype) ? 0 :
                     (opcode == Btype) ? 0 : 1;

// only JALR use rs1
assign jb_op1_sel = (opcode==JALR) ? 0 : 1;

// only LOAD need to write back from memory
assign wb_sel = (opcode==LOAD) ? 0 : 1;

// if opcode == STORE => 
    // if func3 == 000 => sb => dm_w_en = 0001
    // else if func3 == 001 => sh => dm_w_en = 0011
    // else if func3 == 010 => sw => dm_w_en = 1111
// else dm_w_en = 0000
assign dm_w_en = (opcode != STORE) ? 4'b0000 :
                 (func3 == 3'b000) ? 4'b0001 :
                 (func3 == 3'b001) ? 4'b0011 : 4'b1111;
endmodule