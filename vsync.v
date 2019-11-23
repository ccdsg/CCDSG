`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:19:02 11/19/2018 
// Design Name: 
// Module Name:    vsync 
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
module v_sync(
		input 		clk,
		input		rst_n,
		input		clk_hsync,
		output	reg	vsync,
		output	reg	v_de,
		output 	[9:0]	pixcel_row
);

	parameter	PULSE_LENGTH=2;
	parameter	BACK_PORCH=31;
	parameter	ACTIVE_VIDEO=480;
	parameter	FRONT_PORCH=12;
	
	reg	[9:0]	TOTAL_COUNT=PULSE_LENGTH+BACK_PORCH+ACTIVE_VIDEO+FRONT_PORCH; //525
	reg	[9:0]	BLANK_MIN=PULSE_LENGTH + BACK_PORCH; 
	reg	[9:0]	BLANK_MAX=PULSE_LENGTH+BACK_PORCH+ACTIVE_VIDEO;
	
	reg	[9:0]	count_i, ap_cnt;
	reg			ap_cnt_clr; 
	
	assign	pixcel_row=ap_cnt;//ap_cnt是列有效区域计数器
	
//----------------------------------------------------------------------//	
//---define for state machine for h_sync signal----
	parameter	IDLE	=	5'b00001,
						Sp	=	5'b00010,
						Bp	=	5'b00100,
						Ap	=	5'b01000,
						Fp	=	5'b10000;
						
	reg	[4:0]	cur_state;
	reg	[4:0]	nex_state;

	//----detect the positive edge and negative edge of the h_sync signal----------------------------------------
	reg			clk_hsync_d;
	reg			clk_pos;
	reg			clk_neg;
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)begin
				clk_hsync_d<=0; 
				clk_pos<=0;								//初始状态default state;
				clk_neg<=0;end
			else begin
				clk_hsync_d	<=clk_hsync;//clk_hsync是行同步信号取反，将上一时刻的clk_hsync存储到clk_hsync_d
				clk_pos<=clk_hsync&~clk_hsync_d;//clk_pos为1说明clk_hsync处于上升沿（上一时刻clk_hsync为0，此时刻为1）
				//if clk_pos is "1" means the clk_hsync is in "positive" edge;
				clk_neg<=~clk_hsync&clk_hsync_d;end//clk_neg为1说明clk_hsync处于下降沿（上一时刻clk_hsync为1，此时刻为0）
				//else the clk_neg is "1",the clk_hsync is in "negative" edge;
		end			

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n) count_i<=0;
		else if(clk_neg) begin
			if(count_i!=TOTAL_COUNT-1)
				count_i<=count_i+1; //行计数1帧后场计数加1
			else count_i<=0; end
	end	
		
	assign	gate=(count_i==TOTAL_COUNT-1) ? 1'b1 : 1'b0;//1场结束标志
	assign	blank=(count_i<BLANK_MIN || count_i>=BLANK_MAX) ? 1'b1 : 1'b0;//定义无效区域
	assign	sync_n=(count_i<PULSE_LENGTH) ? 1'b0 : 1'b1;//产生场同步信号
	
	always@(posedge clk or negedge rst_n)
		begin
			if(!rst_n)begin
				cur_state	<=	IDLE;end
			else begin
				if(clk_pos)
				cur_state	<=	nex_state;end
		end							
	always@* begin//组合逻辑
		case(cur_state)
			IDLE:begin
				ap_cnt_clr<=1;
				vsync	<=0;
				v_de		<=0;					
				nex_state	<=	Bp;end	//？？？why not Sp
			Sp:begin
				ap_cnt_clr<=1;
				vsync	<=0;
				v_de		<=0;								
				if(sync_n)	nex_state	<=	Bp;//产生场同步信号，场同步信号结束，进入下一个状态Bp（后沿）
				else		nex_state	<=	Sp;end	
			Bp:begin
				ap_cnt_clr<=1;
				vsync	<=1;
				v_de		<=0;								
				if(!blank)	nex_state	<=	Ap;//后沿结束，进入下一个状态Ap（有效区域）
				else	nex_state	<=	Bp;end
			Ap:begin
				ap_cnt_clr<=0;
				vsync	<=1;
				v_de		<=1;//ap_cnt_clr<=0;v_de<=1;说明是有效区域									
				if(blank)	nex_state	<=	Fp;//有效区域结束，进入下一个状态Fp（前沿）
				else		nex_state	<=	Ap;end	
			Fp:begin
				ap_cnt_clr<=1;
				vsync	<=1;
				v_de		<=0;				
			if(gate)	nex_state	<=	Sp;//场一帧结束，进入下一个循环
				else	nex_state	<=	Fp;end
			default:begin
				ap_cnt_clr<=1;
				vsync	<=0;
				v_de		<=0;	
				nex_state	<=	IDLE;	end
			endcase
		end					

		always @(posedge clk)begin                                                  
			if(ap_cnt_clr) ap_cnt<=0;                  
			else if(clk_neg) ap_cnt<=ap_cnt+1;//有效区域计数
		end	
		
					
endmodule	
