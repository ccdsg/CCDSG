`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:17:58 11/19/2018 
// Design Name: 
// Module Name:    hsync 
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
module h_sync(
		input 			clk,
		input				rst_n,
		input    		done,
		output	reg	vsync_rst,
		output	reg	hsync,
		output	reg	h_de,
		output 	[9:0]	pixcel_col
);	  

	parameter	PULSE_LENGTH=96;
	parameter	BACK_PORCH=48;
	parameter	ACTIVE_VIDEO=640;
	parameter	FRONT_PORCH=16;
	
	reg	[9:0]	TOTAL_COUNT=PULSE_LENGTH+BACK_PORCH+ACTIVE_VIDEO+FRONT_PORCH; //行帧长800
	reg	[9:0]	BLANK_MIN=PULSE_LENGTH + BACK_PORCH; 
	reg	[9:0]	BLANK_MAX=PULSE_LENGTH+BACK_PORCH+ACTIVE_VIDEO;
		
	reg	[9:0]	count_h, ap_cnt;
	reg		ap_cnt_clr;
	
	assign	pixcel_col=ap_cnt;//ap_cnt是行有效区域计数器（即当前行有效区域的第几列）

//--------------------------------------------------------------------------//	

	//---define for state machine for hsync signal---------------------------------
	parameter	IDLE		=	5'b00001,
				Sp	=	5'b00010,
				Bp	=	5'b00100,
				Ap	=	5'b01000,
				Fp	=	5'b10000;
	reg	[4:0]	cur_state;
	reg	[4:0]	nex_state; 

	
	always @(posedge clk) 
	begin
		if(!rst_n) count_h<=0;
		else if(done)
		begin
			if(count_h==TOTAL_COUNT-1)
				count_h<=0; 
			else count_h<=count_h+1; 
		end
		else count_h<=0;
	end

	assign	gate=(count_h==TOTAL_COUNT-1) ? 1'b1 : 1'b0;//行一帧结束标志
	assign	blank=(count_h<BLANK_MIN || count_h>=BLANK_MAX) ? 1'b1 : 1'b0;//在无效区域则blank为1
	assign	sync_n=((count_h<PULSE_LENGTH)&&done) ? 1'b0 : 1'b1;//产生行同步信号
	
		
	always@(posedge clk)
	begin
		if(!rst_n)
		begin
			cur_state	<=	IDLE;
			vsync_rst	<= 	0;
		end
		else if(done)
		begin
			cur_state	<=	nex_state;
			vsync_rst 	<= 	1;
		end
		else
		begin
			cur_state	<=	IDLE;
			vsync_rst	<= 	0;
		end
		end				

	always@* begin//组合逻辑
		case(cur_state)
			IDLE:begin
				ap_cnt_clr<=1;
				hsync	<=1;
				h_de		<=0;					
				nex_state	<=	Sp;end			
			Sp:begin
				ap_cnt_clr<=1;
				hsync	<=0;
				h_de		<=0;								
				if(sync_n)	nex_state	<=	Bp;//产生行同步信号（hsync=0），行同步信号结束（维持时间足够），进入下一个状态Bp（后沿）
				else nex_state	<=	Sp;end
			Bp:begin
				ap_cnt_clr<=1;
				hsync	<=1;
				h_de		<=0;								
				if(!blank)	nex_state	<=	Ap;//后沿结束，进入下一个状态Ap（有效区域）
				else	nex_state	<=	Bp;end
			Ap:begin
				ap_cnt_clr<=0;
				hsync	<=1;
				h_de		<=1;//ap_cnt_clr<=0;h_de<=1;说明是有效区域
				if(blank) nex_state	<=	Fp;//有效区域结束，进入下一个状态Fp（前沿）
				else	nex_state	<=	Ap;end			
			Fp:begin
				ap_cnt_clr<=1;
				hsync	<=1;
				h_de		<=0;				 
				if(gate)nex_state	<=	Sp;//行一帧结束，进入下一个循环
				else	nex_state	<=	Fp;end
			default:begin
				ap_cnt_clr<=1;
				hsync	<=0;
				h_de		<=0;	
				nex_state	<=	IDLE;end
		endcase
	end					
    
	always @(posedge clk)begin                                                  
		if(ap_cnt_clr)  ap_cnt<=0;                  
		else	ap_cnt<=ap_cnt+1;//有效区域计数（列）
	end

endmodule			

		