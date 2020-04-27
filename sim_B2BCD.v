`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CPP
// Engineer: Justin Nguyen
//////////////////////////////////////////////////////////////////////////////////

module sim_B2BCD();
reg clk = 0;
reg [11:0] B;
wire [15:0] BCD;

localparam period = 10;

B2BCD uut(clk,B,BCD);
always #(period/2.0) clk=~clk;

initial begin
#0.6 B = 12'b110110000000; //3456
#(period*24) B = 12'b001111100111; //999
#(period*24) B = 12'b000001001011; //75
#(period*24) B = 12'b000000001000; //8
#(period) $finish;
end
endmodule
