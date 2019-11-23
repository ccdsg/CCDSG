
module boost_filter(input rst_n  	   ,
					input clk    	   ,
					input data_in	   ,
					input  [7:0] pixel ,
					input  [7:0] p1    ,
					input  [7:0] p2    ,
					input  [7:0] p3    ,
					input  [7:0] p4    ,
					input  [7:0] p5    ,
					input  [7:0] p6    ,
					input  [7:0] p7    ,
					input  [7:0] p8    ,
					output rd_en	   ,
					output wr_en	   ,
					output [7:0]result
						  ); 
							
wire a_ready  	; 
wire b_ready  	; 
wire v_fifo_full;
wire [15:0] a;
wire [23:0] b;

guided_filter gf(.rst_n	     (rst_n  ),
			     .a_clk		 (clk    ),
			     .data_in  	 (data_in),
			     .a_ready  	 (a_ready  	 ),
			     .b_ready  	 (b_ready  	 ),
			     .v_fifo_full(v_fifo_full),
			     //.m_fifo_full(m_fifo_full),
			     .p1(p1),
			     .p2(p2),
			     .p3(p3),
			     .p4(p4),
			     .p5(p5),
			     .p6(p6),
			     .p7(p7),
			     .p8(p8),
			     .result1(a),
			     .result2(b)
					 	   ); 

reg mul_en;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		mul_en <= 0;
	else 	
		mul_en <= a_ready;
end

// reg fifo1_wr_en;

// always @(posedge clk or negedge rst_n)begin
	// if(!rst_n)
		// fifo1_wr_en <= 0;
	// else 	
		// fifo1_wr_en <= mul_en;
// end

reg [23:0] mul_result;

always @(posedge clk or negedge rst_n)begin
	if(!rst_n)
		mul_result <= 0;
	else if(mul_en)
		mul_result <= a * pixel;
	else
		mul_result <= mul_result;
end

// wire empty_1;
// wire full_1	;

// wire [23:0] mul_result_o;

// s_fifo fifo1(
		  // .clk  (clk         ),
		  // .rst  (~rst_n       ),
		  // .din  (mul_result  ),
		  // .wr_en(fifo1_wr_en ),
				
		  // .rd_en(b_ready     ),
		  // .dout (mul_result_o),
		  // .empty(empty_1       ),
		  // .full (full_1        )
// ); 

wire [7:0] pixel_o;

reg cul_en1;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cul_en1 <= 0;
	else
		cul_en1 <= b_ready;
end

reg cul_en2;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cul_en2 <= 0;
	else
		cul_en2 <= cul_en1;
end

reg cul_en3;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		cul_en3 <= 0;
	else
		cul_en3 <= cul_en2;
end

wire empty_2;
wire full_2	;

s_fifo2 fifo2(
		  .clk  (clk    ),
		  .rst  (~rst_n ),
		  .din  (pixel  ),
		  .wr_en(a_ready),
				
		  .rd_en(cul_en1),
		  .dout (pixel_o),
		  .empty(empty_2),
		  .full (full_2 )
); 

reg [23:0] guided_result;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		guided_result <= 0;
	else if(cul_en1)
		guided_result <= mul_result + b;
		
	else
		guided_result <= guided_result;
end		

reg [23:0] boost_result;

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		boost_result <= 0;
	else if(cul_en2)begin
		if({pixel_o,16'b0} > guided_result)
			boost_result <= ({pixel_o,16'b0} - guided_result) + {3'b0,pixel_o,13'b0};
		else
			boost_result <= {3'b0,pixel_o,13'b0} - (guided_result - {pixel_o,16'b0});
	end
	else
		boost_result <= boost_result;
end	

assign wr_en = cul_en3;
assign rd_en = a_ready;
assign result = (boost_result[12] == 1) ? (boost_result[20:13] + 1'b1) : boost_result[20:13];

endmodule