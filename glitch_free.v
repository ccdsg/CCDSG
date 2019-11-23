///////////////////////////////////////////////////////////////////////
//
//
//时钟切换电路
//
//assign clko=sel ? clk1:clk2
//////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module glitch_free(
						input clk0,
						input clk1,
						input reset,
						input sel,
						output clko
					);
	reg dff01,dff02;
	reg dff11,dff12;
	 
	wire clk0_inv = ~clk0;		//clk0的反向时钟
	wire clk1_inv = ~clk1;		//clk1的反向时钟
//clk0		
//clk0=!sel & !clk1	
always @ (posedge clk0_inv or posedge reset)
	if(reset)
		dff01 <= 1'b1;
	else
		dff01 <= !sel & !dff12;
		
always @ (posedge clk0 or posedge reset)
	if(reset)
		dff02 <= 1'b1;
	else 
		dff02 <= dff01;
		
wire clk0_gate = ~(~clk0 & dff02);

//clk1
always @ (posedge clk1_inv or posedge reset)
	if(reset)
		dff11 <= 1'b0;
	else
		dff11 <= sel & !dff02;
always @ (posedge clk0 or posedge reset)
	if(reset)
		dff12 <= 1'b0;
	else 
		dff12 <= dff11;
		
wire clk1_gate = ~(~clk1 & dff12);
//mux
assign clko = clk1_gate & clk0_gate;

endmodule