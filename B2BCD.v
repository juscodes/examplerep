`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CPP
// Engineer: Justin Nguyen
//////////////////////////////////////////////////////////////////////////////////
module B2BCD(clk,B,E,CAtoCG,dp);
input clk;
input [11:0] B;
output reg [6:0] CAtoCG;
output reg [7:0] E;
output dp;

reg [3:0] cnt;
reg [1:0] s;
reg [11:0] R;
reg [3:0]c;
reg [3:0] BCD3,BCD2,BCD1,BCD0;
reg [3:0] D3,D2,D1,D0;
wire z;
localparam [3:0] I = 12;
localparam[1:0]s0 =2'b00, s1 = 2'b01, s2 = 2'b10;

//initialize registers before simulation
initial s = s0; 
initial cnt = 0;
initial R = 0;
initial D0 = 0; initial D1 = 0; initial D2 = 0; initial D3 = 0;
initial BCD3 = 0; initial BCD2 = 0; initial BCD1 = 0; initial BCD0 = 0;


//IFL/FFs
always @(posedge clk)
case (s)
    0: s <= 1;
    1: if(!z) s <= 2; else s <= 0;
    2: s <= 1; 
    2: s <= 1; 
    2: s <= 1; 
    default: s <= 0;
endcase

//ofl Statemachine
always @(*)
case (s)
    0: c = 4'b1000;
    1: if(z) c = 4'b0001; else c = 4'b0010;
    2: c = 4'b0100;
    default: c = 4'b1000;
endcase

//4-bit counter
always @(posedge clk)
case (c)
    8: cnt <= I;
    4: cnt <= cnt - 1;
    default: cnt <= cnt;
endcase

//Nor for z
assign z = ~(cnt[3] | cnt[2] | cnt [1] | cnt[0]);

//Register
always @(posedge clk)
case (c)
    4'b1000: R <= B;
    4'b0100: R <= {R[10:0], 1'b0};
    default: R <= R;
endcase

//BCD0
always @(posedge clk)
case (c)
    4'b0001: BCD0 <= D0;
    4'b0010: if(D0 > 4'b0100) D0 <= D0 + 4'b0011; else D0 <= D0;
    4'b0100: D0 <= {D0[2:0],R[11]};
    4'b1000: D0 <= 4'b0000;
    default: D0 <= D0;
endcase

//BCD1
always @(posedge clk)
case (c)
    4'b0001: BCD1 <= D1;
    4'b0010: if(D1 > 4'b0100) D1 <= D1 + 4'b0011; else D1 <= D1;
    4'b0100: D1 <= {D1[2:0],D0[3]};
    4'b1000: D1 <= 4'b0000;
    default: D1 <= D1;
endcase

//BCD2
always @(posedge clk)
case (c)
    4'b0001: BCD2 <= D2;
    4'b0010: if(D2 > 4'b0100) D2 <= D2 + 4'b0011; else D2 <= D2;
    4'b0100: D2 <= {D2[2:0],D1[3]};
    4'b1000: D2 <= 4'b0000;
    default: D2 <= D2;
endcase

//BCD3
always @(posedge clk)
case (c)
    4'b0001: BCD3 <= D3;
    4'b0010: if(D3 > 4'b0100) D3 <= D3 + 4'b0011; else D3 <= D3;
    4'b0100: D3 <= {D3[2:0],D2[3]};
    4'b1000: D3 <= 4'b0000;
    default: D3 <= D3;
endcase

assign BCD = {BCD3,BCD2,BCD1,BCD0};

reg [19:0] cntr=0;
reg [5:0] dout;

always@ (posedge clk)
    cntr <= cntr + 1;
always@ (cntr[19:17])
begin
    case(cntr[19:17])
        0: E <= 8'b11111110;
        1: E <= 8'b11111101;
        2: E <= 8'b11111011;
        3: E <= 8'b11110111;
        4: E <= 8'b11101111;
        5: E <= 8'b11011111;
        6: E <= 8'b10111111;
        7: E <= 8'b01111111;
  default: E <= 8'b11111111;
  endcase
end
always@ (*)
//Mux
begin
    case(cntr[19:17])
        0: dout <= {1'b1,BCD0[3:0],1'b1};
        1: dout <= {1'b1,BCD1[3:0],1'b1};
        2: dout <= {1'b1,BCD2[3:0],1'b1};
        3: dout <= {1'b1,BCD3[3:0],1'b1};
        4: dout <= {1'b0,4'd0,1'b1};
        5: dout <= {1'b0,4'd0,1'b1};
        6: dout <= {1'b0,4'd0,1'b1};
        7: dout <= {1'b0,4'd0,1'b1};
        default: dout <= 6'b111111;
      endcase
 end
 assign dp = dout[0];
 always@(dout)
 begin
    if(dout[5])
        case(dout[4:1])
            0: CAtoCG <= 7'b0000001;
            1: CAtoCG <= 7'b1001111;
            2: CAtoCG <= 7'b0010010;
            3: CAtoCG <= 7'b0000110;
            4: CAtoCG <= 7'b1001100;
            5: CAtoCG <= 7'b0100100;
            6: CAtoCG <= 7'b0100000;
            7: CAtoCG <= 7'b0001111;
            8: CAtoCG <= 7'b0000000;
            9: CAtoCG <= 7'b0000100;
            10:CAtoCG <= 7'b0001000; 
            11:CAtoCG <= 7'b1100000;
            12:CAtoCG <= 7'b0110001;
            13:CAtoCG <= 7'b1000010;
            14:CAtoCG <= 7'b0110000;
            15:CAtoCG <= 7'b0111000;
        endcase
else
         CAtoCG <= 7'b1111111;   
end
endmodule

