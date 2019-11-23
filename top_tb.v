`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:41:50 09/20/2019
// Design Name:   shifit_top
// Module Name:   E:/wjt/Defogging image/design_coding/ise project/defoggingimage/shift_top_tb.v
// Project Name:  defoggingimage
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: shifit_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_tb;
	// Inputs
reg 							sys_clk   	;
reg 							rst 		;
wire							sys_clk_p	;
//wire        					sys_clk_n	;
reg								key_c    ;
//reg								key_right   ;

wire 							SCL         ;
wire 							SDA         ;
wire  							hsync_out   ;
wire  							vsync_out   ;
wire  							de          ;
wire  [11:0]					dvi_d       ;
wire  							dvi_xclk_p  ;
wire  							dvi_xclk_n  ;
wire  							rst_b       ;

wire 							pic_done	;
wire 							wr_ram      ;
wire 							rom_ena     ;
reg								uart_rx	    ;
reg 							sw8		    ;
wire 							uart_tx     ;
wire [7:0] 						rgb_led     ;
wire                            download    ;


// Instantiate the Unit Under Test (UUT)
top uut 
(
	.sys_clk_p		(sys_clk_p			), 
	.rst			(rst				),
	.key_c			(key_c				),
	.SCL            (SCL        		),
	.SDA            (SDA        		),
	.pic_done		(pic_done			),
	.wr_ram         (wr_ram  			),
	.rom_ena        (rom_ena 			),
	.hsync_out      (hsync_out  		),
	.vsync_out      (vsync_out  		),
	//-----------------------------------
	//.pic_done		(pic_done			),
	//.wr_ram         (wr_ram  			),
	//.rom_ena        (rom_ena 			),
	.uart_rx	    (uart_rx			),
	.sw8		    (sw8				),
	.uart_tx        (uart_tx 			),
	.rgb_led        (rgb_led 			),
	.download       (download			),
	.de             (de         		),
	.dvi_d          (dvi_d      		),
	.dvi_xclk_p     (dvi_xclk_p 		),
	.dvi_xclk_n     (dvi_xclk_n 		),
	.rst_b          (rst_b      		)
);

reg [7:0]		din_reg;

assign sys_clk_p = sys_clk;
//assign sys_clk_n = ~sys_clk;

initial   
      begin
	    sys_clk		= 0;
		rst   		= 1;
		key_c		= 0;
		uart_rx		= 1;
		sw8 		= 1;
		 
		#7  rst	= 1;
		#7 rst	= 0;
	    #8 uart_rx		= 1;
		
		//#3100000
		//key_c = 1;
		//#3100001
		//key_c = 0;
		//#4200000
		//key_c = 1;
		//#4200001
		//key_c = 0;
		
		repeat (129600)
		begin
		din_reg={$random}%255;
		 #8 uart_rx=0; //起始位
		
		#8 uart_rx = din_reg[7];
		#8 uart_rx = din_reg[6];
		#8 uart_rx = din_reg[5];
		#8 uart_rx = din_reg[4];
		#8 uart_rx = din_reg[3];
		#8 uart_rx = din_reg[2];
		#8 uart_rx = din_reg[1];
		#8 uart_rx = din_reg[0];
		     
		
		    #8 uart_rx = 1; //停止位
		   end
     	end

//initial 
//	begin
//		// Initialize Inputs
//		sys_clk 	= 0;
//		rst   		= 1;
//		key_c		= 0;
//        //key_right  = 0;
//		// Wait 100 ns for global reset to finish
//		#500;
//        rst   	= 0;
//		#3100000
//		key_c = 1;
//		#3100001
//		key_c = 0;
//		#4200000
//		key_c = 1;
//		#4200001
//		key_c = 0;
//		
//		// Add stimulus here
//	end

always # 0.1 sys_clk = ~sys_clk; 
 
endmodule

