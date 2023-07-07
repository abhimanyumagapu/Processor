`timescale 1ns / 1ns

`define oper_type ir[31:27] //Instruction reg breakup
`define rdst      ir[26:22]
`define rsrc1     ir[21:17]
`define imm_mode  ir[16]
`define rsrc2     ir[15:11]
`define isrc      ir[10:0]

`define movsgpr   5'b00000  // arithmetic instructions
`define mov       5'b00001
`define add       5'b00010
`define sub       5'b00011
`define mul       5'b00100

`define  ror      5'b00101 // logical instructions
`define  rand     5'b00110
`define  rxor     5'b00111
`define  rxnor    5'b01000
`define  rnand    5'b01001
`define  rnor     5'b01010
`define  rnot     5'b01011

`define storereg  5'b01101   //////store content of register in data memory
`define storedin  5'b01110   ////// store content of din bus in data memory
`define senddout  5'b01111   /////send data from data memory to dout bus
`define sendreg   5'b10001   ////// send data from data memory to register

`define jump           5'b10010  ////jump to address
`define jcarry         5'b10011  ////jump if carry
`define jnocarry       5'b10100
`define jsign          5'b10101  ////jump if sign
`define jnosign        5'b10110
`define jzero          5'b10111  //// jump if zero
`define jnozero        5'b11000
`define joverflow      5'b11001 ////jump if overflow
`define jnooverflow    5'b11010

`define halt           5'b11011 // for a halt state of indefinite period

module top(dout,din,clock,reset);
output reg [15:0]dout;
input clock,reset;
input [15:0]din;


reg [31:0]ir;
reg [15:0]gpr[31:0]; //general purpose register

reg [15:0]sgpr; // for multiplication
reg [63:0]mulreg;

reg sign = 0, zero = 0, carry = 0, overflow = 0;//flags
reg [16:0]temp_sum;

reg [31:0] inst_mem[15:0]; //harvard architecture
reg [15:0] data_mem[15:0];

reg [2:0]count = 0;
integer PC = 0; 

reg jmp_flag = 0;
reg stop = 0;


task decode_inst; begin

    jmp_flag = 0;
    stop     = 0;

    case(`oper_type)

    `movsgpr: begin
 
        gpr[`rdst] = sgpr;
    end

    `mov : begin
        if(`imm_mode)
            gpr[`rdst]  = `isrc;
        else
            gpr[`rdst]   = gpr[`rsrc1];
    end

    `add : begin
        if(`imm_mode)
             gpr[`rdst]   = gpr[`rsrc1] + `isrc;
        else
             gpr[`rdst]   = gpr[`rsrc1] + gpr[`rsrc2];
    end
    `sub : begin
        if(`imm_mode)
            gpr[`rdst]  = gpr[`rsrc1] - `isrc;
        else
            gpr[`rdst]   = gpr[`rsrc1] - gpr[`rsrc2];
    end

    `mul : begin
        if(`imm_mode)
            mulreg   = gpr[`rsrc1] * `isrc;
        else
            mulreg   = gpr[`rsrc1] * gpr[`rsrc2];
        
        gpr[`rdst]   =  mulreg[15:0];
        sgpr         =  mulreg[31:16];
    end
    

    `ror : begin
      if(`imm_mode)
            gpr[`rdst]  = gpr[`rsrc1] | `isrc;
        else
            gpr[`rdst]   = gpr[`rsrc1] | gpr[`rsrc2];
    end

    `rand : begin
      if(`imm_mode)
            gpr[`rdst]  = gpr[`rsrc1] & `isrc;
        else
            gpr[`rdst]   = gpr[`rsrc1] & gpr[`rsrc2];
    end

    `rxor : begin
      if(`imm_mode)
            gpr[`rdst]  = gpr[`rsrc1] ^ `isrc;
        else
            gpr[`rdst]   = gpr[`rsrc1] ^ gpr[`rsrc2];
    end

    `rxnor : begin
      if(`imm_mode)
            gpr[`rdst]  = gpr[`rsrc1] ~^ `isrc;
        else
            gpr[`rdst]   = gpr[`rsrc1] ~^ gpr[`rsrc2];
    end
 
    `rnand : begin
      if(`imm_mode)
            gpr[`rdst]  = gpr[`rsrc1] ~& `isrc;
        else
            gpr[`rdst]   = (gpr[`rsrc1] ~& gpr[`rsrc2]);
    end
 
    `rnor : begin
      if(`imm_mode)
            gpr[`rdst]  = (gpr[`rsrc1] ~| `isrc);
        else
            gpr[`rdst]   = (gpr[`rsrc1] ~| gpr[`rsrc2]);
    end
 
    `rnot : begin
      if(`imm_mode)
            gpr[`rdst]  = ~(`isrc);
        else
            gpr[`rdst]   = ~(gpr[`rsrc1]);
    end

    `storedin : data_mem[`isrc] = din;

    `storereg : data_mem[`isrc] = gpr[`rsrc1];

    `senddout : dout = data_mem[`isrc];

    `sendreg  : gpr[`rdst] = data_mem[`isrc];

    `jump: begin
        jmp_flag = 1'b1;
    end
 
    `jcarry: begin
        if(carry == 1'b1)
            jmp_flag = 1'b1;
        else
            jmp_flag = 1'b0; 
    end
 
    `jsign: begin
        if(sign == 1'b1)
            jmp_flag = 1'b1;
        else
            jmp_flag = 1'b0; 
    end
 
    `jzero: begin
        if(zero == 1'b1)
            jmp_flag = 1'b1;
        else
            jmp_flag = 1'b0; 
    end
 
 
    `joverflow: begin
        if(overflow == 1'b1)
            jmp_flag = 1'b1;
        else
            jmp_flag = 1'b0; 
    end
    
    `jnocarry: begin
        if(carry == 1'b0)
            jmp_flag = 1'b1;
        else
            jmp_flag = 1'b0; 
    end
    
    `jnosign: begin
        if(sign == 1'b0)
            jmp_flag = 1'b1;
        else
            jmp_flag = 1'b0; 
    end
    
    `jnozero: begin
        if(zero == 1'b0)
            jmp_flag = 1'b1;
        else
            jmp_flag = 1'b0; 
    end
    
    
    `jnooverflow: begin
        if(overflow == 1'b0)
            jmp_flag = 1'b1;
        else
            jmp_flag = 1'b0; 
    end

    `halt : begin
        stop = 1'b1;
    end

    endcase
end
endtask

task decode_flags;begin
    if(`oper_type == `mul)//sign flag
        sign = sgpr[15];
        else   
            sign = gpr[15];


    if(`oper_type == `add) begin//carry flag
        if(`imm_mode)
            begin
            temp_sum = gpr[`rsrc1] + `isrc;
            carry = temp_sum[16];
            end
            else
                temp_sum = gpr[`rsrc1] + gpr[`rsrc2];
                carry  = temp_sum[16];
    end
    else carry = 1'b0;


    if(`oper_type == `mul) // zero flag
        zero = ~( (|sgpr) | (|gpr[`rdst]) );
        else 
         zero = ~(|gpr[`rdst]);


    if(`oper_type == `add)//overflow flag
        begin
        if(`imm_mode)
            overflow = ( (~gpr[`rsrc1][15] & ~ir[15] & gpr[`rdst][15] ) | (gpr[`rsrc1][15] & ir[15] & ~gpr[`rdst][15]) );
        else
            overflow = ( (~gpr[`rsrc1][15] & ~gpr[`rsrc2][15] & gpr[`rdst][15]) | (gpr[`rsrc1][15] & gpr[`rsrc2][15] & ~gpr[`rdst][15]));
        end
        else if(`oper_type == `sub)
        begin
            if(`imm_mode)
            overflow = ( (~gpr[`rsrc1][15] & ir[15] & gpr[`rdst][15] ) | (gpr[`rsrc1][15] & ~ir[15] & ~gpr[`rdst][15]) );
            else
            overflow = ( (~gpr[`rsrc1][15] & gpr[`rsrc2][15] & gpr[`rdst][15]) | (gpr[`rsrc1][15] & ~gpr[`rsrc2][15] & ~gpr[`rdst][15]));
        end 
    else overflow = 1'b0;
    
end
endtask

initial begin
    $readmemb("mem.txt",inst_mem);
end

 
parameter idle = 0, fetch_inst = 1, dec_exec_inst = 2, next_inst = 3, sense_halt = 4, delay_next_inst = 5;
reg [2:0] state = idle, next_state = idle; 
 

always@(posedge clock)
    begin
        if(reset)
        state <= idle;
        else
        state <= next_state; 
end

 
always@(*) begin
  case(state)
    idle: begin
        ir         = 32'h0;
        PC         = 0;
        next_state = fetch_inst;
    end
 
  fetch_inst: begin
        ir          =  inst_mem[PC];   
        next_state  = dec_exec_inst;
    end
  
  dec_exec_inst: begin
        decode_inst;
        decode_flags;
        next_state  = delay_next_inst;   
    end
  
  
  delay_next_inst:begin
    if(count < 4)
        next_state  = delay_next_inst;       
        else
        next_state  = next_inst;
    end
  
  next_inst: begin
        next_state = sense_halt;
        if(jmp_flag == 1'b1)
            PC = `isrc;
        else
            PC = PC + 1;
    end
  
  
 sense_halt: begin
        if(stop == 1'b0)
            next_state = fetch_inst;
        else if(reset == 1'b1)
            next_state = idle;
        else
            next_state = sense_halt;
    end
  
  default : next_state = idle;
  
  endcase
  
end

 
always@(posedge clock) begin
case (state)
    idle : begin
        count <= 0;
    end
    
        fetch_inst: begin
        count <= 0;
    end
    
        dec_exec_inst : begin
        count <= 0;    
    end  
    
        delay_next_inst: begin
        count  <= count + 1;
    end
    
        next_inst : begin
            count <= 0;
    end
    
        sense_halt : begin
            count <= 0;
    end
    
    default : count <= 0;
    
  
endcase
end
 
endmodule




