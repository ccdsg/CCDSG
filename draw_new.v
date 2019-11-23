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
module draw_new(
	input		 	  	clk,
	input				rst_n,
	input		[9:0]	xpos,
	input		[9:0]	ypos,
	input [23:0]		data0,  //rom
    input [23:0]		data1,  //ram
	input 				switch_ram,
   // input pic_change,
   input				vsync	,
	//------------------
   output	reg			frame_sw_ram,
   input				pic_done,
	output    			valid,
	//-----------------
	output [16:0] 		addr0,
    output [16:0] 		addr1,
	output [11:0]		dvi_d
    );

    reg [23:0]data0_reg;  
    reg [23:0]data1_reg;  
    reg valid_1;
	reg valid_reg;
	wire [23:0] DATAA;
	//wire valid;

	
	assign valid = ((xpos>=10'd78)&&(xpos<10'd558)&&(ypos>=10'd105)&&(ypos<10'd375))?1'b1:1'b0;//因为rom存在延迟，故把显示有效区域后移
	
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
		else if(ypos == 375)
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
	
always@ (posedge clk)
  begin
       data0_reg<=data0;
	   data1_reg<=data1;
	   valid_1<=valid;
	   valid_reg<=valid_1;
   end

reg 		vsync_r;
always @(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		vsync_r <= 0;
	else 
		vsync_r <= vsync;
end

//reg 	frame_sw_ram ;
always @(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		frame_sw_ram <= 0;
	else if(switch_ram && vsync && (!vsync_r))
		frame_sw_ram <= 1;
	 else if(!switch_ram && vsync && (!vsync_r))
		 frame_sw_ram <= 0;
	else 
		frame_sw_ram <= frame_sw_ram;
end
 
 //assign addr1=(switch_ram==1)?(base+offset):0 ;
 assign addr1=(pic_done == 1 && frame_sw_ram==1)?(base+offset):0 ;
 //assign addr0=(switch_ram==0)? ((pic_change==0)?(base+offset):(base+offset+129600)) : 0 ;
 assign addr0=( pic_done == 1 && frame_sw_ram==0)? (base+offset) : 0 ;
// assign DATAA=(frame_sw_ram==1)?data1_reg:data0_reg;
assign DATAA=(pic_done == 1 && frame_sw_ram==1)?data1_reg:(( pic_done == 1 && frame_sw_ram==0) ? data0_reg :0);
 	
	
	assign dvi_d = (~valid_reg)?12'b0:
									(clk?{DATAA[23:16],DATAA[15:12]}:
										 {DATAA[11:8],DATAA[7:0]});
	
//-------------------------读数据到txt文件---------------------------------------

   integer 										w_mem_ptr;   
  
   always @(posedge clk)
	 begin
   		if (valid_1 == 1'b1)
   		  w_mem_ptr = $fopen( "E:/wjt/Defogging image/design_coding/ise project/defoggingimage/src/dvi_data.txt") ;
		else if (valid_1 == 1'b0 && ypos == 375)begin
		   $fclose(w_mem_ptr);
		end
   	 end

   always @(posedge clk)
   	 begin
   		if (valid_reg == 1'b1)begin
		    $fdisplay(w_mem_ptr, "%h", DATAA);
		end
   	 end  
	
endmodule
