`timescale 1ns / 1ps
module  uart_rx_tb;
   reg [7:0] din_reg;
   reg  clk;
   reg  rst_n;
   reg  din;
   wire [23:0] pic_out;
   wire  [16:0] addr;
   wire  wr_ram;
   wire  pic_done;

   always   #1 clk=~clk;
   
   initial   
      begin
	     clk<=0;
		 rst_n<=1;
		 din<=1;
		 
		#7  rst_n<=0;
		#7 rst_n<=1;
	    #8 din<=1;
		
		repeat (250000)
		begin
		din_reg<={$random}%255;
		 #8 din<=0; //起始位
		
		#8 din<=din_reg[7];
		#8 din<=din_reg[6];
		#8 din<=din_reg[5];
		#8 din<=din_reg[4];
		#8 din<=din_reg[3];
		#8 din<=din_reg[2];
		#8 din<=din_reg[1];
		#8 din<=din_reg[0];
		     
		
		    #8 din<=1; //停止位
		   end
     	end
		
		uart_top  uart_top(
							.clk(clk),
							.rst_n(rst_n),
							.din(din),
							.pic_out(pic_out),
							.addr(addr),
							.wr_ram(wr_ram),
							.pic_done(pic_done)
									);
		
	endmodule 
		
   