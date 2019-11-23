`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:44:32 11/21/2018 
// Design Name: 
// Module Name:    iic 
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
module iic(
input clk,
input rst_n,
inout scl,
inout sda,
output done,
output rst_b
    );
	 
/*-------------------配置信息-----------------------*/
localparam SLAVE_ADDR =  7'h76,
			  WR_SIG     =  1'b0,
			  ACK        =  1'bz,
			  REG0_ADDR  =  8'h49,	REG0_DATA  =  8'hC0,
			  REG1_ADDR  =  8'h21,	REG1_DATA  =  8'h09,
			  REG2_ADDR  =  8'h33,	REG2_DATA  =  8'h08,
			  REG3_ADDR  =  8'h34,	REG3_DATA  =  8'h16,
			  REG4_ADDR  =  8'h36,	REG4_DATA  =  8'h60,
			  REG5_ADDR  =  8'h23,	REG5_DATA  =  8'h08,
			  REG6_ADDR  =  8'h1D,	REG6_DATA  =  8'h43,
			  REG7_ADDR  =  8'h48,	REG7_DATA  =  8'h18,
			  REG8_ADDR  =  8'h35,	REG8_DATA  =  8'h70;			  			  
/*--------------------状态机------------------------*/
localparam IDLE      = 4'd0,
			  INIT      = 4'd1,
			  START     = 4'd2,
			  CLK_RISE  = 4'd3,
			  SET_UP    = 4'd4,
			  CLK_FALL  = 4'd5,
			  PRE_STOP  = 4'd6,
			  NEAR_STOP = 4'd7,
			  STOP	   = 4'd8,
			  WAIT	   = 4'd9;
 /*---------------------------------------*/			  
localparam PERIOD_CYCLE = 1000;//分频100kb/s
 /*--------------------------------------*/
reg [3:0]c_state;
reg [3:0]n_state;
wire trs;
reg [9:0]trs_cnt;
reg [4:0]bit_cnt;
reg [3:0]reg_cnt;	

/*-------------------------------*/
reg rst_ch;
always@(posedge clk or negedge rst_n)
begin
  if(!rst_n) rst_ch <= 1'b0;
  else rst_ch <= 1'b1;
end
assign rst_b = rst_ch;

/*------------初始化完成信号-------------*/
assign done = (!rst_n)?1'b0:(c_state==IDLE)?1'b1:1'b0; 

/*-------------传输允许信号（分频）----------------*/
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)trs_cnt <= 10'b0;
	else if(trs_cnt == 999)trs_cnt <= 10'b0;
	else trs_cnt <= trs_cnt+1;
end
assign trs = (trs_cnt==999)?1'b1:1'b0;

/*---------------数据写计数器及寄存器计数器-------------*/	  
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) bit_cnt <= 5'b0;
	else if(c_state == PRE_STOP) bit_cnt <= 5'b0;
	else if((c_state == CLK_FALL)&&trs) bit_cnt <= bit_cnt+1;
	else bit_cnt <= bit_cnt;
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) reg_cnt <= 4'b0;
	else if((c_state == WAIT)&&trs) 
	begin
		if(reg_cnt==8)reg_cnt <= 4'b0;
		else reg_cnt <= reg_cnt+1;
	end
	else reg_cnt <= reg_cnt;
end

/*--------------------应答信号--------------------------*/
wire ack_right;
assign ack_right=(((bit_cnt==8)||(bit_cnt==17)||(bit_cnt==26))&&(sda==1)&&(c_state==CLK_FALL)&&trs)?1'b0:1'b1;

/*------------状态机切换-----------------------*/
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)c_state <= INIT;
	else c_state <= n_state;
end

always@(*)
begin
	if(!ack_right)n_state =INIT;
	else
	case(c_state)
	IDLE:n_state = IDLE;
	INIT:begin
				if(trs) n_state = START;
				else n_state = INIT;
		  end
	START:begin
				if(trs) n_state = CLK_RISE;
				else n_state = START;
			end
	CLK_RISE:begin
					if(trs)n_state = SET_UP;
					else n_state = CLK_RISE;
				end
	SET_UP:begin
				if(trs)n_state = CLK_FALL;
				else n_state = SET_UP;
			 end
	CLK_FALL:begin
					if((bit_cnt==26)&&trs)n_state = PRE_STOP;
					else if((bit_cnt!=26)&&trs)n_state = CLK_RISE;
					else n_state = CLK_FALL;
				end
	PRE_STOP:begin
					if(trs)n_state = NEAR_STOP;
					else n_state = PRE_STOP;
				end
	NEAR_STOP:begin
					if(trs)n_state = STOP;
					else n_state = NEAR_STOP;
				end
	STOP:begin
				if(trs)n_state = WAIT;
				else n_state = STOP;
			end
	WAIT:begin
				if((reg_cnt==8)&&trs)n_state = IDLE;
				else if((reg_cnt!=8)&&trs)n_state = INIT;
				else n_state = WAIT;
		  end
	default:n_state = IDLE;
	endcase
end


/*-------------------时钟线与数据线配置--------------------------*/
reg scl_i,sda_i;
reg [26:0]sda_buffer;
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		scl_i <= 1;
		sda_i <= 1;
	end
	else
	case(c_state)
	IDLE:begin
			scl_i <= 1;
			sda_i <= 1;
		  end
	INIT:sda_i <= 0;//此时开始信号已产生
	START:scl_i <= 0;
	CLK_RISE:sda_i <= sda_buffer[26];//数据（从机地址、寄存器地址、数据信息）存入sda
	SET_UP:scl_i <= 1;//scl拉高，数据输入
	CLK_FALL:scl_i <= 0;
	PRE_STOP:sda_i <= 0;
	NEAR_STOP:scl_i <= 1;
	STOP:sda_i <= 1;
	//WAIT:
	default:begin
				scl_i <= 1;
				sda_i <= 1;
			  end
	endcase
end
assign scl = scl_i;
assign sda = sda_i;

/*-----------------sda数据配置-------------------------*/		
always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
		sda_buffer <= {SLAVE_ADDR,1'b0,ACK,REG0_ADDR,ACK,REG0_DATA,ACK};
	else if((c_state == SET_UP)&&trs)
		sda_buffer <= {sda_buffer[25:0],1'b0};
	else if(c_state == WAIT)
	case(reg_cnt)
	0:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG0_ADDR,ACK,REG0_DATA,ACK};
	1:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG1_ADDR,ACK,REG1_DATA,ACK};
	2:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG2_ADDR,ACK,REG2_DATA,ACK};
	3:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG3_ADDR,ACK,REG3_DATA,ACK};
	4:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG4_ADDR,ACK,REG4_DATA,ACK};
	5:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG5_ADDR,ACK,REG5_DATA,ACK};
	6:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG6_ADDR,ACK,REG6_DATA,ACK};
	7:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG7_ADDR,ACK,REG7_DATA,ACK};
	8:sda_buffer <= {SLAVE_ADDR,WR_SIG,ACK,REG8_ADDR,ACK,REG8_DATA,ACK};
	default:sda_buffer <= 27'b0;
	endcase
end

endmodule
