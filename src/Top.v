`include "./src/Adder.v"
`include "./src/Controller.v"
`include "./src/Decoder.v"
`include "./src/Imme_Ext.v"
`include "./src/JB_Unit.v"
`include "./src/LD_Filter.v"
`include "./src/Mux.v"
`include "./src/Reg_PC.v"
`include "./src/RegFile.v"
`include "./src/SRAM.v"

module Top (
    input clk,
    input rst
);

Reg_PC pc(
    .clk(clk),
    .rst(rst),
    .next_pc(pcmux.result)
);

SRAM im (
    .clk(clk),
    .w_en(ctlr.im_w_en),
    .address(pc.current_pc[15:0])
);

Decoder decoder(
    .inst(im.read_data)
);

RegFile regfile(
    .clk(clk),
    .wb_en(ctlr.wb_en),
    .wb_data(lstmux.result),
    .rs1_index(decoder.dc_out_rs1_index),
    .rs2_index(decoder.dc_out_rs2_index),
    .rd_index(decoder.dc_out_rd_index)
);

Imm_Ext ime(
    .inst(im.read_data)// , jb.operand2
);

Controller ctlr(
    .opcode(decoder.dc_out_opcode),
    .func3(decoder.dc_out_func3),
    .func7(decoder.dc_out_func7),
    .alu_out(alu.alu_out[0])
);

Mux pcmux(
    .in1(jb.jb_out),
    .in2(pc.current_pc + 32'd4),
    .sel(ctlr.next_pc_sel)
);


SRAM dm (
    .clk(clk),
    .w_en(ctlr.dm_w_en),
    .address(alu.alu_out[15:0]),
    .write_data(regfile.rs2_data_out)
);


JB_Unit jb (
    .operand1(jbmux.result),
    .operand2(ime.imm_ext_out)
);

LD_Filter ld (
    .func3(ctlr.afunc3),
    .ld_data(dm.read_data)
);

Adder alu(
    .opcode(ctlr.aopcode),
    .func3(ctlr.afunc3),
    .func7(ctlr.afunc7),
    .operand1(aluonemux.result),
    .operand2(alutwomux.result)
);

Mux lstmux(
    .sel(ctlr.wb_sel),
    .in1(ld.ld_data_f),
    .in2(alu.alu_out)
);

Mux aluonemux(
    .sel(ctlr.alu_op1_sel),
    .in1(regfile.rs1_data_out),
    .in2(pc.current_pc)
);

Mux alutwomux(
    .sel(ctlr.alu_op2_sel),
    .in1(regfile.rs2_data_out),
    .in2(ime.imm_ext_out)
);

Mux jbmux(
    .sel(ctlr.jb_op1_sel),
    .in1(regfile.rs1_data_out),
    .in2(pc.current_pc)
);


endmodule