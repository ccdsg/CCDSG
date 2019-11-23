module shift_reg(
//sys_signal
input						clk,
input						rst_n,
//
input						frame_sw_ram,
input		[23:0]			shift_din,					//输入数据
input						shift_din_en,				//输入数据对应的是能有效信号
output reg 	[16:0]			shift_dout_cnt,
//output reg					shift_dout_end,				//遍历一幅图片结束的信号
output 						shift_dout_valid,			//输出数据有效信号（寄存一级使其与数据对齐）
output reg [191:0]			shift_dout_v1_r				//输出数据(寄存了一级去除毛刺)
);

//缓存8行数据的计数7*480=3360；此后可以开始往外读数据
reg [11:0]					shift_cnt;	
reg 						shift_dout_flag;
reg							shift_dout_flag_r;
wire [23:0]					shift_7_din;
wire [23:0]					shift_7_dout;
wire [23:0]					shift_6_dout;
wire [23:0]					shift_5_dout;
wire [23:0]					shift_4_dout;
wire [23:0]					shift_3_dout;
wire [23:0]					shift_2_dout;
wire [23:0]					shift_1_dout;
wire [191:0]				shift_dout_v1;	
//-----------------------------------------
reg[23:0]					shift_din_r;
//reg							shift_din_en_r;

always@(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		shift_din_r <= 0;
	else 
		shift_din_r <= shift_din;
end

/* always@(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		shift_din_en_r <= 0;
	else 
		shift_din_en_r <= shift_din_en;
end */

//shift_cnt计数到3360时开始读数据		
always@(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		shift_cnt <= 0;
	else if(!frame_sw_ram)
		shift_cnt <= 0;
	else if(shift_cnt == 12'd3359)
		shift_cnt <= 0;
	else if(shift_din_en)
		shift_cnt <= shift_cnt+1;
	else 
		shift_cnt <= shift_cnt;
end

//always@(posedge clk or negedge rst_n)	begin 
//	if(!rst_n)
//		shift_dout_end <= 0;
//	else if((shift_dout_flag == 0) && (shift_dout_cnt == 17'd126239))
//		shift_dout_end <= 1;
//	else 
//		shift_dout_end <= shift_dout_end;
//end

//480x270的图片一共读480x263列（每列8个数）

//always@(posedge clk or negedge rst_n)	begin 
//	if(!rst_n)
//		shift_dout_cnt_r <= 0;
//	else 
//		shift_dout_cnt_r <= shift_dout_cnt;
//end

always@(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		shift_dout_flag <= 0;
	else if(shift_dout_cnt == 17'd126239 )
		shift_dout_flag <= 0;
	else if(shift_dout_cnt == 17'd126240 )
		shift_dout_flag <= 0;
	else if(shift_cnt == 12'd3359)
		shift_dout_flag <= 1;
	else 
		shift_dout_flag <= shift_dout_flag;
end

//读数据的个数 480x（270-7）= 126240
always@(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		shift_dout_cnt <= 0;
	//else if(shift_dout_cnt == 17'd126240)
	//	shift_dout_cnt <= 0;
	else if(!frame_sw_ram)
		shift_dout_cnt <= 0;
	else if(shift_dout_flag)
		shift_dout_cnt <= shift_dout_cnt +1;
	else 
		shift_dout_cnt <= shift_dout_cnt;
end


always@(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		shift_dout_flag_r <= 0;
	else 
		shift_dout_flag_r <= shift_dout_flag;
end
	
assign shift_dout_v1 = (shift_dout_flag )?{shift_din,shift_7_dout,shift_6_dout,shift_5_dout,shift_4_dout,shift_3_dout,shift_2_dout,shift_1_dout} : 0;



always@(posedge clk or negedge rst_n)	begin 
	if(!rst_n)
		shift_dout_v1_r <= 0;
	else
		shift_dout_v1_r <= shift_dout_v1;
end

// //-------------------------读数据到txt文件---------------------------------------
//
//   integer 										fun;
// 
//   always @(posedge clk)
//	 begin
//   		if (shift_dout_flag == 1'b1)
//   		  fun = $fopen("E:/wjt/Defogging image/design_coding/defoggingimage_v2/src/shift_data.txt") ;
//		else if (frame_sw_ram == 1'b0 )begin
//		   $fclose(fun);
//		end
//   	 end
//
//   always @(posedge clk)
//   	 begin
//   		if (shift_dout_flag_r == 1'b1)begin
//		    $fdisplay(fun, "%h", shift_dout_v1_r[191:168]);
//		end
//   	 end  
//
//--------------------------shift_reg--------------------------------------------------
c_shift_ram 	u_c_shift_ram_1 
(
  .d			(shift_7_din	), 
  .clk			(clk			), 
  .sclr			(!shift_din_en), 
  .q			(shift_7_dout	)  
);

c_shift_ram 	u_c_shift_ram_2 
(
  .d			(shift_7_dout	), 
  .clk			(clk			), 
  .sclr			(!shift_din_en	), 
  .q			(shift_6_dout	)  
);


c_shift_ram 	u_c_shift_ram_3
(
.clk		(clk			),
.sclr		(!shift_din_en	),
.d          (shift_6_dout	),
.q          (shift_5_dout	)
);

c_shift_ram 	u_c_shift_ram_4
(
.clk		(clk			),
.sclr		(!shift_din_en	),
.d          (shift_5_dout	),
.q          (shift_4_dout	)
);

c_shift_ram 	u_c_shift_ram_5
(
.clk		(clk			),
.sclr		(!shift_din_en	),
.d          (shift_4_dout	),
.q          (shift_3_dout	)
);

c_shift_ram 	u_c_shift_ram_6
(
.clk		(clk			),
.sclr		(!shift_din_en	),
.d          (shift_3_dout	),
.q          (shift_2_dout	)
);

c_shift_ram 	u_c_shift_ram_7
(
.clk		(clk			),
.sclr		(!shift_din_en	),
.d          (shift_2_dout	),
.q          (shift_1_dout	)
);

assign shift_7_din = shift_din;
assign shift_dout_v1 = (shift_dout_flag )?{shift_din,shift_7_dout,shift_6_dout,shift_5_dout,shift_4_dout,shift_3_dout,shift_2_dout,shift_1_dout} : 0;
assign shift_dout_valid = shift_dout_flag_r;

endmodule 