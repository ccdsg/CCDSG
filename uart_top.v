module  uart_top(
								input  clk,
								input  rst_n,
								input  din,
								input sw8,
							//  input in，    //测试用
								output  reg  [23:0] pic_out,
								output  reg [16:0] addr,
								output  reg wr_ram,
								output  tx,
								output  reg pic_done,   //图片传输完成(接led灯)
							//	output   [1:0] state,   //用于测试
								output  reg  pic_download,   //传输灯
								output  reg [7:0] rgb_led
								);
								

	wire   dout_vld;
	wire  [7:0] dout;
	reg [3:0] code_p;
	reg  [4:0]  cnt;
	reg  [3:0]  state;
	wire  [3:0]  code;
	wire [7:0]  temp;
	reg [23:0] pic_reg;
	

	
	/*****************************状态机含有ascii译码模块*****************************/
	
	parameter  monitor=0;  //监听（第一个数）
	parameter  second=1 ;
	parameter  third=2 ;
	parameter   fouth=3;
	parameter   fiveth=4;
	parameter   sixth=5;
	parameter   send=6;
	parameter   stop=7;
	
	assign temp=(dout>8'd57)?(dout-8'd87):(dout-8'd48);
	assign code=temp[3:0];

	
	always  @ (posedge clk or negedge rst_n)
	    begin
			if  (!rst_n)
			   begin
			      state<=monitor;
				  wr_ram<=1;
				  pic_out<=0;
				  addr<=0;
				  pic_done<=0;
				  end
			else
	case (state)
	monitor:	begin
				   if (dout_vld)
						begin
						    wr_ram<=1;	
							pic_reg[23:20]<=code;
							state<=second;
							code_p<=code;
						end
				 else
				          state<=monitor;
					end
					
	second:	begin
					if (dout_vld)
							begin
								pic_reg[19:16]<=code;
								state<=third;
								rgb_led<={code_p,code};
							end
					else
							state<=second;
					end
					
		third:		begin
					if (dout_vld)
						begin
							pic_reg[15:12]<=code;
							state<=fouth;
							code_p<=code;
						end
					else
						state<=third;
					end
					
		fouth:		begin
					if (dout_vld)
						begin
							pic_reg[11:8]<=code;
							state<=fiveth;
							rgb_led<={code_p,code};
						end
					else
						state<=fouth;
					end
					
		fiveth:		begin
					if (dout_vld)
						begin
							
							pic_reg[7:4]<=code;
							state<=sixth;
							code_p<=code;
						end
					else
						state<=fiveth;
					end
		
        sixth:		begin
					if (dout_vld)
						begin
							pic_reg[3:0]<=code;
							state<=send;
							rgb_led<={code_p,code};
						end
					else
						state<=sixth;
					end
		
		send: 	 begin
						wr_ram<=0;
						pic_out<=pic_reg;
						if (addr<129599)
							begin
								addr<=addr+1;								
								pic_done<=0;
								state<=monitor;
							end
			         else if (addr==129599)
					        begin								 
							     addr<=0;		
															 
								 pic_done<=1;
								 state<=stop;								
							end	 
						end
			
		stop:  begin
					if  (sw8==1)
					    state<=monitor;
					else
						begin
						
						state<=stop;
						end
				  end
		     endcase
		end
		
		always  @ (posedge  clk or negedge rst_n)
		    begin
				if (!rst_n)
					cnt<=0;
				else if (state==send)
				    cnt<=cnt+1;
			    else 
					cnt<=cnt;
			end
			
		always  @ (posedge  clk or negedge rst_n)
			begin
				if (!rst_n)
					pic_download<=1;
		   else if (cnt>=15)
					pic_download<=0;
			else
					pic_download<=1;
			end
		
		/* assign tx=din; */
		
		uart_rx uart_rx(
								.clk(clk),
								.rst_n(rst_n),
								.din(din),
								//.din(tx)        //测试用
								.dout(dout),
								.dout_vld(dout_vld)
								);

	   uart_tx uart_tx(
                              .clk(clk)    ,			
                              .rst_n(rst_n)  ,		
							  .din_vld(dout_vld)    ,
							  .din(dout),
				//			  .din(in)
				//			  .dout()          //测试用
							  .dout(tx),
							  .rdy()
							); 

		endmodule 
		
								
					