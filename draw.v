`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:19:59 11/19/2018 
// Design Name: 
// Module Name:    draw 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module draw(
	input		 	  clk,
	input		[9:0]xpos,
	input		[9:0]ypos,
	input		[23:0]DATAA,
	output	[16:0]ADDRA,
	output	[11:0]dvi_d
    );
	wire valid;
	assign valid = ((xpos>=10'd80)&&(xpos<10'd560)&&(ypos>=10'd105)&&(ypos<10'd375))?1'b1:1'b0;//因为rom存在延迟，故把显示有效区域后移
	
	reg [16:0]base;	//基地址
	reg [8:0]offset;	//偏移地址
	always@(posedge clk)
	begin
		if((xpos==0)&&(ypos==0))
		begin
			base <= 0;
			offset <= 0;
		end
		else if((ypos>=105)&&(ypos<375))
		begin
			if((xpos>=78)&&(xpos<558))
			begin
				offset <= offset + 1; 
				base   <= base;
			end
			else if(xpos==558)
			begin
				offset <= 0;
				base   <= base + 480;
			end
			else 
			begin
				offset <= offset;
				base   <= base;
			end
		end
		else if(ypos==374)
		begin
			offset <= 0;
			base   <= 0;
		end
		else
		begin
			offset <= offset;
			base   <= base;
		end
	end
	
	assign ADDRA = base+offset;
	
/*	reg [7:0]RED,GREEN,BLUE;
	always@(posedge clk)
	begin
		if(valid)
		begin
			RED   = DATAA[23:16];
			GREEN = DATAA[15:8];
			BLUE  = DATAA[7:0];
		end
		else
		begin
			RED 	= 8'b0;
			GREEN = 8'b0;
			BLUE 	= 8'b0;
		end
	end

	assign dvi_d = clk?{RED[7:0],GREEN[7:4]}:{GREEN[3:0],BLUE[7:0]};*/
	assign dvi_d = (~valid)?12'b0:
									(clk?{DATAA[23:16],DATAA[15:12]}:
										 {DATAA[11:8],DATAA[7:0]});
	
endmodule
