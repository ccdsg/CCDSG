//////////////////////////////////////////////////////////////////////////////////
//  sd bmp vga display                                                          //
//                                                                              //
//  Author: meisq                                                               //
//          msq@qq.com                                                          //
//          ALINX(shanghai) Technology Co.,Ltd                                  //
//          heijin                                                              //
//     WEB: http://www.alinx.cn/                                                //
//     BBS: http://www.heijin.org/                                              //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////
//                                                                              //
// Copyright (c) 2017,ALINX(shanghai) Technology Co.,Ltd                        //
//                    All rights reserved                                       //
//                                                                              //
// This source file may be used and distributed without restriction provided    //
// that this copyright statement is not removed from the file and that any      //
// derivative work contains the original copyright notice and the associated    //
// disclaimer.                                                                  //
//                                                                              //
//////////////////////////////////////////////////////////////////////////////////

//================================================================================
//  Revision History:
//  Date          By            Revision    Change Description
//--------------------------------------------------------------------------------
//  2017/6/21    meisq         1.0         Original
//*******************************************************************************/
module top(
	//Differential system clocks
	input                               sys_clk_p,
	//input                             sys_clk_n,
	input                               rst,
	input								key_c,//去雾 或原图
	//input								key_right,//切换两张原图
	inout 								SCL,
	inout 								SDA,	
	//-----------------uart--------------------------
	input								uart_rx	,
	input 								sw8		,
	output 								uart_tx ,
	output [7:0] 						rgb_led ,
	output                              pic_done,
	output                              download,
	output                              wr_ram  ,
	output								rom_ena ,
	//-----------------dvi----------------------------
	output 								hsync_out,
	output 								vsync_out,
	output 								de,
	output [11:0]						dvi_d,
	output 								dvi_xclk_p,
    output 								dvi_xclk_n,
	output 								rst_b
  );

parameter ADDR_WIDTH            		= 17  ;  
parameter DATA_WIDTH					= 24  ;

wire                           			video_clk	;         //video pixel clock
wire									video_clk_N ;
wire[DATA_WIDTH-1:0]                    shift_din	;


wire									read_data_en;
wire 									pic_data_en	;
wire [191:0]							pic_data_v1 ;
wire [16:0]								rd_pic_cnt	;
wire [ADDR_WIDTH-1:0]					read_addr	;
//wire                           		sys_clk		;

wire 									ui_clk		;
wire 									start       ;
//wire 									pic_change	;
wire 									switch_ram  ;
//-------------------------------dvi---------------------		
wire 									dvi_valid	;

//--------------------------------------------------
wire 									key_start 	;
//wire 									key_change  ;
wire [ADDR_WIDTH-1:0]					addr0       ;
wire [ADDR_WIDTH-1:0]					addr1       ;
wire [DATA_WIDTH-1:0]					data0       ;
wire [DATA_WIDTH-1:0]					data1       ;

wire [23:0] p1;
wire [23:0] p2;
wire [23:0] p3;
wire [23:0] p4;
wire [23:0] p5;
wire [23:0] p6;
wire [23:0] p7; 
wire [23:0] p8;

wire [7:0] result_r;
wire [7:0] result_g;
wire [7:0] result_b;

wire [23:0] fifo_out;

wire fifo_full;
wire fifo_empty;
wire fifo_rd_en;
wire result_en;

wire frame_sw_ram;

//uart--------------------------
wire [16:0]			uart_addr;
wire [23:0]			pic_out  ;
		

PLL PLL_m0(
    .CLK_IN1		(sys_clk_p				),      
    .CLK_OUT1		(ui_clk					),     //100M
    .CLK_OUT2		(video_clk				),     //25M
	.CLK_OUT3		(video_clk_N			),  
    .RESET			(1'b0 					),
    .LOCKED			(						)
	);      

uart_top 	uart_top
(
.clk				(ui_clk		),
.rst_n				(~rst		),
.din				(uart_rx	),
.sw8				(sw8		),
.tx					(uart_tx	),
.pic_out			(pic_out	),
.addr				(uart_addr	),
.wr_ram				(wr_ram		),
.pic_done			(pic_done	),
.pic_download		(download	),
.rgb_led			(rgb_led	)
);	

//pic_rom   pic_rom_m0
//(
//  .clka			(ui_clk			),
//  .ena			(wr_ram			),
//  .addra		(uart_addr			),
//  .douta        (pic_out		)
//
//);
//
//always @(posedge ui_clk or posedge rst)	begin 
//	if(rst)
//		wr_ram <= 0;
//	else if(uart_addr <= 129599)
//		wr_ram <= 1;
//	else 
//		wr_ram <= 0;
//end
//
//always @(posedge ui_clk or posedge rst)	begin 
//	if(rst)
//		uart_addr <= 0;
//	else if (uart_addr==129599)						 
//		uart_addr <= 0;	
//	else if( wr_ram )
//		uart_addr <= uart_addr + 1;
//	else 
//		uart_addr <= uart_addr;
//end
//
//assign pic_done = (uart_addr = 129599) ? 1:0;
	
//--------------------------------rom-test--------------------------------
pic_rom_contrl		
#(
.ADDR_WIDTH  		(17						),
.DATA_WIDTH  		(24						)
)	
u_pic_rom_contrl	
(	
  .clk_25M			(video_clk				),
  .clk_100M			(ui_clk					),
  .rst_n			(~rst					),
 //-------------------------------------------
  .frame_sw_ram		(frame_sw_ram			),
  .addr0			(addr0					),
  .addr1            (addr1					),
  .data0            (data0					),
  .data1            (data1					),
//---------------------------------------------
  .uart_addr		(uart_addr				),
  .pic_out			(pic_out				),
  .wr_ram			(wr_ram					),
  .pic_done         (pic_done				),
  .rom_ena			(rom_ena				),
  .defogging_wr_en	(result_en				),
  .result_r    		(result_r    			),
  .result_g    		(result_g    			),
  .result_b    		(result_b    			),
  //--------------------------------------------
  //.dvi_addr       (dvi_addr				),
  .dvi_valid		(dvi_valid				),
  .read_addr		(read_addr				),
  .shift_din		(shift_din				)

);

//----------------------------------------------
shift_reg			u_shift_reg
(
.clk				(ui_clk					),
.frame_sw_ram		(frame_sw_ram			),
.rst_n				(~rst					),			
.shift_din			(shift_din				),
.shift_din_en		(read_data_en			),
.shift_dout_cnt		(rd_pic_cnt				),
.shift_dout_valid	(pic_data_en			),
.shift_dout_v1_r    (pic_data_v1  			)
);

assign p1 = pic_data_v1[ 23:  0];
assign p2 = pic_data_v1[ 47: 24];
assign p3 = pic_data_v1[ 71: 48];
assign p4 = pic_data_v1[ 95: 72];
assign p5 = pic_data_v1[119: 96];
assign p6 = pic_data_v1[143:120];
assign p7 = pic_data_v1[167:144];
assign p8 = pic_data_v1[191:168];

boost_filter_4_3channel uut1(
							.rst_n   (!rst),
							.clk     (ui_clk),
							.data_in (pic_data_en),
							.p1      (p1),
							.p2      (p2),
							.p3      (p3),
							.p4      (p4),
							.p5      (p5),
							.p6      (p6),
							.p7      (p7),
							.p8      (p8),
							.pixel   (fifo_out),
							.rd_en   (fifo_rd_en),
							.wr_en   (result_en),
							.result_r(result_r),
							.result_g(result_g),
							.result_b(result_b)
							   );

fifo_buffer buffer(
				.clk	(ui_clk			),
				.rst	(rst			),
				.din	(shift_din		),
				.wr_en	(read_data_en	),
				.rd_en	(fifo_rd_en		),
				.dout 	(fifo_out		),
				.full 	(fifo_full		),
				.empty	(fifo_empty		)  
);



dvi_top  dvi_top_m0(
.clk_100M			(ui_clk					),
.clk_25M			(video_clk				),
.clk_25M_N			(video_clk_N			),
.rst				(rst					),
.SCL				(SCL					),
.SDA				(SDA					),
.hsync_out			(hsync_out				),
.vsync_out			(vsync_out				),
.de					(de						),
.dvi_d				(dvi_d					),
//-------------------------------------------
.addr0				(addr0					),
.addr1              (addr1					),
.data0              (data0					),
.data1              (data1					),
.valid				(dvi_valid				),
.frame_sw_ram		(frame_sw_ram			),
.pic_done			(pic_done				),
//------------------------------------------
 .switch_ram		(switch_ram				),
 //.pic_change		(pic_change				),	
//-------------------------------------------
.dvi_xclk_p			(dvi_xclk_p				),
.dvi_xclk_n			(dvi_xclk_n				),
.rst_b             	(rst_b					)
);

//------------按键------------------------------
buttons  u_buttons
(
.clk				(ui_clk					),
.key_c				(key_c					), //
//.key_right		(key_right				),
.start				(key_start				)
//.change			(key_change				)
);

arbiter_v2 arbiter
(
.key_start			(key_start				),

.rst_n				(~rst					),
.clk				(ui_clk					),
.start				(start					),
//.pic_change		(pic_change				),
.switch_ram			(switch_ram				)
);

reg[ADDR_WIDTH-1:0] read_addr_r;
always @(posedge ui_clk or posedge rst) begin
	if(rst)
		read_addr_r <= 0;
	else 
		read_addr_r <= read_addr;
end
 
assign read_data_en = ((read_addr <= 129599) && (read_addr >= 1)||(read_addr_r <= 129599) && (read_addr_r >= 1))  ? 1:0;

endmodule