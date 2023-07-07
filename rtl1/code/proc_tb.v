`timescale 1ns/1ns
`include "proc.v"

module top_tb;
wire [15:0]dout;
reg clock,reset;
reg [15:0]din;


parameter stop_time = 500;
integer i = 0;

top m2(dout,din,clock,reset);

initial #stop_time $finish;

initial begin
    $dumpfile("proc.vcd");
    $dumpvars(0,top_tb);
end

initial begin
    for(i=0;i<32;i = i + 1)
    begin
        m2.gpr[i] = 2;
    end

end

initial begin 
    m2.ir = 0;
    m2.`oper_type = 2; //opcode
    m2.`rdst      = 0; //rdst
    m2.`rsrc1     = 2; //rsrc1
    m2.`imm_mode  = 1; //immed
    m2.`isrc      = 5; //isrc
    #10
    $display("OP=ADDI rsrc1=%d immdat=%d rdst=%d",m2.gpr[2], m2.`isrc, m2.gpr[0]);
    $display("-------------------------------------------------------------------");

    m2.ir = 0;
    m2.`oper_type = 2;        //opcode
    m2.`rdst      = 0;        //rdst
    m2.`rsrc1     = 4;        //rsrc1
    m2.`imm_mode  = 0;        //immed
    m2.`rsrc2     = 5;        //rscr2
    m2.ir[10:0]   = 0;        //isrc
    #10
    $display("OP=ADD rsrc1=%0d rsrc2=%d rdst=%d",m2.gpr[4], m2.gpr[5], m2.gpr[0]);
    $display("-------------------------------------------------------------------");

    m2.ir = 0;
    m2.`oper_type = 1;        //opcode
    m2.`rdst      = 4;        //rdst
    m2.`rsrc1     = 9;        //rsrc1
    m2.`imm_mode  = 1;        //immed
    m2.`rsrc2     = 5;        //rscr2
    m2.`isrc     = 55;        //isrc
    #10
    $display("OP=MOVI rdst=%d immeddata=%d",m2.gpr[4], m2.`isrc);
    $display("-------------------------------------------------------------------");

    m2.ir = 0;
    m2.`oper_type = 1;        //opcode
    m2.`rdst      = 9;        //rdst
    m2.`rsrc1     = 4;        //rsrc1
    m2.`imm_mode  = 0;        //immed
    m2.`rsrc2     = 5;        //rscr2
    m2.`isrc      = 55;       //isrc
    #10
    $display("OP=MOV rdst=%d rsrc1=%d",m2.gpr[4], m2.gpr[9]);
    $display("-------------------------------------------------------------------");

    m2.ir = 0;
    m2.`oper_type = 4;        //opcode
    m2.`rdst      = 1;        //rdst
    m2.`rsrc1     = 9;        //rsrc1
    m2.`imm_mode  = 0;        //immed
    m2.`rsrc2     = 6;        //rscr2
    m2.`isrc      = 55;       //isrc
    #10
    $display("OP=MUL sgpr=%d rdst=%d rsrc1=%d rsrc2=%d",m2.sgpr,m2.gpr[1], m2.gpr[9],m2.gpr[6]);
    $display("-------------------------------------------------------------------");

    m2.ir = 0;
    m2.`oper_type = 6;        //opcode
    m2.`rdst      = 7;        //rdst
    m2.`rsrc1     = 4;        //rsrc1
    m2.`imm_mode  = 1;        //immed
    m2.`rsrc2     = 6;        //rscr2
    m2.`isrc      = 9;       //isrc
    #10
    $display("OP=ANDI rdst=%d rsrc1=%d immeddate=%d",m2.gpr[7], m2.gpr[4],m2.`isrc);
    $display("-------------------------------------------------------------------");

    m2.ir = 0;
    m2.`oper_type = 11;        //opcode
    m2.`rdst      = 7;        //rdst
    m2.`rsrc1     = 8;        //rsrc1
    m2.`imm_mode  = 0;        //immed
    m2.`rsrc2     = 6;        //rscr2
    m2.`isrc      = 9;       //isrc
    #10
    $display("OP=NOT rdst=%d rsrc1=%d ",m2.gpr[7], m2.gpr[8]);
    $display("-------------------------------------------------------------------");

    m2.ir  = 0;
    m2.gpr[0] = 0;
    m2.gpr[1] = 0; 
    m2.`imm_mode = 0;
    m2.`rsrc1 = 0;
    m2.`rsrc2 = 1;
    m2.`oper_type = 2;
    m2.`rdst = 2;
    #10;
    $display("Zero=%d rdst:%d rsrc1:%d rsrc2:%d ",m2.zero, m2.gpr[2], m2.gpr[0], m2.gpr[1] );
    $display("-------------------------------------------------------------------");

    m2.ir  = 0;
    m2.gpr[1] = 16'h8000;
    m2.gpr[0] = 0; 
    m2.`imm_mode = 0;
    m2.`rsrc1 = 0;
    m2.`rsrc2 = 1;
    m2.`oper_type = 2;
    m2.`rdst = 2;
    #10;
    $display("Sign=%d rdst:%d rsrc1:%d rsrc2:%d ",m2.sign, m2.gpr[2], m2.gpr[0], m2.gpr[1] );
    $display("-------------------------------------------------------------------");

    m2.ir  = 0;
    m2.gpr[1] = 16'h8000;
    m2.gpr[0] = 16'h8002; 
    m2.`imm_mode = 0;
    m2.`rsrc1 = 0;
    m2.`rsrc2 = 1;
    m2.`oper_type = 2;
    m2.`rdst = 2;
    #10;
    $display("Carry=%d Overflow=%d rdst:%d rsrc1:%d rsrc2:%d ",m2.carry,m2.overflow, m2.gpr[2], m2.gpr[0], m2.gpr[1] );
    $display("-------------------------------------------------------------------");


end

endmodule