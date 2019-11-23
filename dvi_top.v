`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:24:23 11/19/2018 
// Design Name: 
// Module Name:    dvi_top 
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
module dvi_top(
input clk_100M,
input clk_25M,
input clk_25M_N,
input rst,
inout SCL,
inout SDA,
output hsync_out,
output vsync_out,
output de,
output [11:0] dvi_d,
//-----------------
output [16:0]addr0 ,
output [16:0]addr1 ,
input [23:0]data0 ,
input [23:0]data1 ,
input switch_ram ,
input	pic_done,
//input pic_change ,
//output [17:0] addr,
//input  [23:0] pic_dout,
output 		valid,
output		frame_sw_ram,
//-----------------------
output dvi_xclk_p,
output dvi_xclk_n,
output rst_b
    );
	
wire h_de,v_de;
wire done;
wire hsync;
wire vsync;
wire vsync_rst;
wire [9:0]xpos;
wire [9:0]ypos;
//wire [16:0]addr;
//wire [23:0]data;
wire rst_n;

assign rst_n=~rst;



iic iic(
	.clk(clk_100M),
    .rst_n(rst_n),
	.scl(scl),
	.sda(sda),
	.done(done),
	.rst_b(rst_b));
	
	
h_sync h_sync(
	.clk(clk_25M),
	.rst_n(rst_n),
	.done(done),
	.vsync_rst(vsync_rst),
	.hsync(hsync),
	.h_de(h_de),
	.pixcel_col(xpos));
	
	
v_sync v_sync(
	.clk(clk_25M),
	.rst_n(vsync_rst),
	.clk_hsync(~hsync),
	.vsync(vsync),
	.v_de(v_de),
	.pixcel_row(ypos));
	
draw_new draw(
	.clk(clk_25M),
	.rst_n(rst_n),
	.xpos(xpos),
	.ypos(ypos),
	.dvi_d(dvi_d),
	.addr0(addr0),
	.addr1(addr1),
	.data0(data0),//rom
	.data1(data1),//ram
	//----------------------
	.valid(valid),
	//----------------------
	.frame_sw_ram	(frame_sw_ram),
	.pic_done		(pic_done),
	.vsync		(vsync),
	.switch_ram	(switch_ram)
	//.pic_change(pic_change)
	);

	 
assign de = (h_de&&v_de)?1'b1:1'b0;
assign hsync_out = hsync;
assign vsync_out = vsync;
assign dvi_xclk_p = clk_25M;
assign dvi_xclk_n = clk_25M_N;
assign SCL = scl;
assign SDA = sda;

endmodule
