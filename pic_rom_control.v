module pic_rom_contrl
#(
parameter	ADDR_WIDTH = 17,
parameter	DATA_WIDTH = 24
)
(
input							clk_25M		,
input							clk_100M	,
input							rst_n	 	,
//---------------key---------------------	
//input							start	 	,
//input							switch_ram	,
input							frame_sw_ram,
output							rom_ena,
//========================================
input [ADDR_WIDTH-1:0]			addr0,
input [ADDR_WIDTH-1:0]			addr1,
output[DATA_WIDTH-1:0]			data0,
output[DATA_WIDTH-1:0]			data1,
//===========================================
input                           defogging_wr_en,	
input [7:0]                     result_r       ,	
input [7:0]                     result_g       ,	
input [7:0]                     result_b       ,	
//=================uart============================
input [ADDR_WIDTH-1:0]			uart_addr	,
input [DATA_WIDTH-1:0]			pic_out		,
input							wr_ram		,
input							pic_done	,
//--------------------------------------------------
input   						dvi_valid	,
output[ADDR_WIDTH-1:0]			read_addr	,
output[DATA_WIDTH-1:0]			shift_din	
);

reg  [ADDR_WIDTH-1:0]			rd_addr    ;
reg  [ADDR_WIDTH-1:0]			rd_addr_r  ;
wire [ADDR_WIDTH-1:0]    		rom_rd_addr;
wire [DATA_WIDTH-1:0]			rom_dout   ;
reg[DATA_WIDTH-1:0]				rom_dout_r ;

//reg								start_r	   ;
reg								ena		   ;
//wire							rom_ena	   ;
wire 							rom_clk	   ;

wire 							defogging_ram_ena ;
reg [16:0]						defogging_wr_addr;

//-----------------------rom--------------------------------------
//always@(posedge rom_clk or negedge rst_n)	begin 
//	if(!rst_n)
//		start_r <= 0;
//	else 
//		start_r <= start;
//end

//reg 	pic_done_r;
//always@(posedge rom_clk or negedge rst_n)	begin 
//	if(!rst_n)
//		pic_done_r <= 0;
//	else 
//		pic_done_r <= pic_done;
//end

reg 	frame_sw_ram_r;
always@(posedge rom_clk or negedge rst_n)	begin 
	if(!rst_n)
		frame_sw_ram_r <= 0;
	else 
		frame_sw_ram_r <= frame_sw_ram;
end

//rom提供给移位寄存模块的使能
always@(posedge rom_clk or negedge rst_n)	begin 
	if(!rst_n)
		ena <= 0;
	else if(rd_addr == 18'd129598) //因为rd地址是根据ena_r来+1的，所以ena的0地址维持了两个周期，所以最后的读地址需要再减去一个1	
		ena <= 0;
	//else if(pic_done && (!pic_done_r) && frame_sw_ram && (!frame_sw_ram_r))
	else if(pic_done && frame_sw_ram && (!frame_sw_ram_r))
		ena <= 1;
	else 
		ena <= ena;
end

//----------------------------------------------
reg			ena_r;
always@(posedge rom_clk or negedge rst_n)	begin 
	if(!rst_n)
		ena_r <= 0;
	else 
		ena_r <= ena;
end

//rom读地址（给移位寄存模块的）
always@(posedge rom_clk or negedge rst_n)	begin 
	if(!rst_n)
		rd_addr <= 0;
	else if(frame_sw_ram && !frame_sw_ram_r)
		rd_addr <= 0;
	else if(ena_r)
		rd_addr <= rd_addr +1;
	//else if(!start_r && start && ((rd_addr < 18'd259200) && (rd_addr > 18'd129599))
	//else if(!pic_change)
	//	rd_addr <= 18'd0;
	////else if(!start_r && start && ((rd_addr < 18'd129600) && (rd_addr >= 18'd0))
	//else if(pic_change)	
	//	rd_addr <= 18'd129600;
	else 
		rd_addr <= rd_addr ;
end

//地址寄存一级与数据对齐
always@(posedge rom_clk or negedge rst_n)	begin 
	if(!rst_n)
		rd_addr_r <= 0;
	else 
		rd_addr_r <= rd_addr ;
end

//rom输出数据寄存一级，跟clk对齐
always@(posedge rom_clk or negedge rst_n)	begin 
	if(!rst_n)
		rom_dout_r <= 0;
	else 
		rom_dout_r <= rom_dout ;
end
//-----------------------ram--------------------------------------

pic_ram		pic_ram_m0
(
  .clka				(clk_100M					),
  .wea				(wr_ram						),//读写控制端，0：写 1：读
  .addra			(uart_addr					),
  .dina				(pic_out					),
  .clkb				(rom_clk					),
  .enb				(rom_ena					),
  .addrb            (rom_rd_addr				),
  .doutb       		(rom_dout					)
);

always@(posedge clk_100M or negedge rst_n)	begin 
	if(!rst_n)
		defogging_wr_addr <= 0;
	else if(defogging_wr_addr == 129599)
		defogging_wr_addr <= 0;
	else if(defogging_wr_en)
		defogging_wr_addr <= defogging_wr_addr + 1;
	else 
		defogging_wr_addr <= defogging_wr_addr;
end

defogging_pic_ram	defogging_pic_ram_m1
(
  .clka				(clk_100M					 ),
  .ena				(defogging_wr_en    		 ),
  .wea				(defogging_wr_en			 ),
  .addra			(defogging_wr_addr    		 ),
  .dina				({result_r,result_g,result_b}),
  .clkb				(clk_25M					 ),
  .enb				(defogging_ram_ena			 ),
  .addrb			(addr1						 ),
  .doutb            (data1						 )
);

/* defogging_pic_ram defogging_pic_ram_m1(
 .clka				(clk_25M			),
 .ena				(defogging_ram_ena  ),
 .addra				(addr1				),
 .douta       		(data1				)
); */

//消除时钟切换产生的小毛刺
glitch_free 	u_glitch_free
(
.clk0				(clk_100M			),
.clk1				(clk_25M			),
.reset				(~rst_n				),
.sel				(~frame_sw_ram		),
.clko   			(rom_clk			)
);

assign read_addr = rd_addr_r;

assign rom_ena = (frame_sw_ram) ? ena_r : dvi_valid;
assign rom_rd_addr = (frame_sw_ram) ? rd_addr : addr0 ;		//没按键：dvi；按键：移位寄存
assign data0 = (!frame_sw_ram)? rom_dout :0;
//assign shift_din = (switch_ram)? rom_dout : 0;  //
assign shift_din = (frame_sw_ram)? rom_dout_r : 0;

assign defogging_ram_ena  = (frame_sw_ram) ? dvi_valid : 0;

////-------------------------读数据到txt文件---------------------------------------
//wire [23:0]			wr_data;
//
//assign wr_data = {result_r,result_g,result_b};
// 
//   integer 										w_mem_ptr;   
//  
//   always @(posedge clk_100M)
//	 begin
//   		if (defogging_wr_en == 1'b1)
//   		  w_mem_ptr = $fopen("E:/wjt/Defogging image/design_coding/defoggingimage_v2/src/defoggy_data.txt") ;
//		else if (defogging_wr_en == 1'b0 )begin
//		   $fclose(w_mem_ptr);
//		end
//   	 end
//
//   always @(posedge clk_100M)
//   	 begin
//   		if (defogging_wr_en == 1'b1)begin
//		    $fdisplay(w_mem_ptr, "%h", wr_data);
//		end
//   	 end  



endmodule