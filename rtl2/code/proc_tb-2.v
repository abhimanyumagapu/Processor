`timescale 1ns/1ns
`include "proc2.v"

module top_tb3;
 
reg clock,reset;
reg [15:0] din;
wire [15:0] dout;
parameter stop_time = 800;
 
top m2(clock,reset,din,dout);

initial #stop_time $finish;
 
initial begin   
    clock = 1'b0;
    repeat(50)
        #5 clock = ~clock;
end

initial begin
    $dumpfile("proc2.vcd");
    $dumpvars(0,top_tb3);
end
 
initial begin
reset = 1;
    #15
    reset = 0;

    end

endmodule