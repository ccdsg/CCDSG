module ram1(wr_clk,
		   wr_data,
		   wr_en,
		   wr_addr,
		   
		   rd_clk,
		   rd_data,
		   rd_en,
		   rd_addr
		   );

parameter DWIDTH = 11;		//data width
parameter AWIDTH =  3;		//address width 

input wr_clk;
input wr_en;

input[DWIDTH-1:0] wr_data;
input[AWIDTH-1:0] wr_addr;

input  rd_clk;
input  rd_en;

input[AWIDTH-1:0] rd_addr;
output [DWIDTH-1:0] rd_data;
	
reg[DWIDTH-1:0] rw_mem [2**AWIDTH-1:0];//define the memory
reg[AWIDTH-1:0] raddr;

always@(posedge wr_clk )begin
	if(wr_en) begin
		rw_mem[wr_addr]<=wr_data;
	end
end
 
always@(posedge rd_clk)begin
	if(rd_en) begin
		raddr<=rd_addr;
	end
end
assign rd_data = rw_mem[raddr];

endmodule
