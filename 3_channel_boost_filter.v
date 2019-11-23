module boost_filter_4_3channel(
							   input        rst_n   ,
							   input        clk     ,
							   input        data_in ,
							   input [23:0] p1      ,
							   input [23:0] p2      ,
							   input [23:0] p3      ,
							   input [23:0] p4      ,
							   input [23:0] p5      ,
							   input [23:0] p6      ,
							   input [23:0] p7      ,
							   input [23:0] p8      ,
							   input [23:0] pixel   ,		//从大fifo输出的像素点
							   output       rd_en   ,
							   output       wr_en   ,
							   output[7:0] result_r ,
							   output[7:0] result_g ,
							   output[7:0] result_b
							   );

wire [7:0] p1_r;
wire [7:0] p2_r;
wire [7:0] p3_r;
wire [7:0] p4_r;
wire [7:0] p5_r;
wire [7:0] p6_r;
wire [7:0] p7_r;
wire [7:0] p8_r;

wire [7:0] p1_g;
wire [7:0] p2_g;
wire [7:0] p3_g;
wire [7:0] p4_g;
wire [7:0] p5_g;
wire [7:0] p6_g;
wire [7:0] p7_g;
wire [7:0] p8_g;

wire [7:0] p1_b;
wire [7:0] p2_b;
wire [7:0] p3_b;
wire [7:0] p4_b;
wire [7:0] p5_b;
wire [7:0] p6_b;
wire [7:0] p7_b;
wire [7:0] p8_b;

wire [7:0] pixel_r;
wire [7:0] pixel_g;
wire [7:0] pixel_b;

wire rd_en_r;
wire rd_en_g;
wire rd_en_b;

wire wr_en_r;
wire wr_en_g;
wire wr_en_b;

assign p1_r = p1[23:16];
assign p2_r = p2[23:16];
assign p3_r = p3[23:16];
assign p4_r = p4[23:16];
assign p5_r = p5[23:16];
assign p6_r = p6[23:16];
assign p7_r = p7[23:16];
assign p8_r = p8[23:16];

assign p1_g = p1[15: 8];
assign p2_g = p2[15: 8];
assign p3_g = p3[15: 8];
assign p4_g = p4[15: 8];
assign p5_g = p5[15: 8];
assign p6_g = p6[15: 8];
assign p7_g = p7[15: 8];
assign p8_g = p8[15: 8];

assign p1_b = p1[ 7: 0];
assign p2_b = p2[ 7: 0];
assign p3_b = p3[ 7: 0];
assign p4_b = p4[ 7: 0];
assign p5_b = p5[ 7: 0];
assign p6_b = p6[ 7: 0];
assign p7_b = p7[ 7: 0];
assign p8_b = p8[ 7: 0];

assign pixel_r = pixel[23:16];
assign pixel_g = pixel[15: 8];
assign pixel_b = pixel[ 7: 0];	

assign rd_en = rd_en_r && rd_en_g && rd_en_b;
assign wr_en = wr_en_r && wr_en_g && wr_en_b;	
					  
boost_filter R_channel(.rst_n  (rst_n  ),
					   .clk    (clk    ),
					   .data_in(data_in),
					   .pixel  (pixel_r),
					   .p1     (p1_r   ),
					   .p2     (p2_r   ),
					   .p3     (p3_r   ),
					   .p4     (p4_r   ),
					   .p5     (p5_r   ),
					   .p6     (p6_r   ),
					   .p7     (p7_r   ),
					   .p8     (p8_r   ),
					   .rd_en  (rd_en_r), 
					   .wr_en  (wr_en_r),  
					   .result (result_r)
										); 

boost_filter G_channel(.rst_n  (rst_n  ),
					   .clk    (clk    ),
					   .data_in(data_in),
					   .pixel  (pixel_g),
					   .p1     (p1_g   ),
					   .p2     (p2_g   ),
					   .p3     (p3_g   ),
					   .p4     (p4_g   ),
					   .p5     (p5_g   ),
					   .p6     (p6_g   ),
					   .p7     (p7_g   ),
					   .p8     (p8_g   ),
					   .rd_en  (rd_en_g), 
					   .wr_en  (wr_en_g),  
					   .result (result_g)
										); 

boost_filter B_channel(.rst_n  (rst_n  ),
					   .clk    (clk    ),
					   .data_in(data_in),
					   .pixel  (pixel_b),
					   .p1     (p1_b   ),
					   .p2     (p2_b   ),
					   .p3     (p3_b   ),
					   .p4     (p4_b   ),
					   .p5     (p5_b   ),
					   .p6     (p6_b   ),
					   .p7     (p7_b   ),
					   .p8     (p8_b   ),
					   .rd_en  (rd_en_b), 
					   .wr_en  (wr_en_b), 
					   .result (result_b)
										); 
										
//-------------------------读数据到txt文件---------------------------------------
wire[23:0] result ;
assign result = {result_r,result_g,result_b};

   integer 										w_mem_ptr;   
  
   always @(posedge clk)
	 begin
   		if (wr_en == 1'b1)
   		  w_mem_ptr = $fopen( "E:/wjt/Defogging image/design_coding/defoggingimage_v3/src/boost_filter_data.txt") ;
		else if (wr_en == 1'b0 )begin
		   $fclose(w_mem_ptr);
		end
   	 end

   always @(posedge clk)
   	 begin
   		if (wr_en == 1'b1)begin
		    $fdisplay(w_mem_ptr, "%h", result);
		end
   	 end  
										
endmodule