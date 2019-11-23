module fifo1
		    #(parameter WIDTH=4'd14,
			parameter DEPTH=7'd64
			)
			(
			  input clk		  		,
			  input rst_n		    ,
			  input[WIDTH-1 : 0] din,
			  input wr_en     		,
			  
			  
			  
			  
			  input rd_en	  		  ,
			  output[WIDTH-1 : 0] dout,
			  output reg empty		  ,
			  output reg full
							  );  

//parameter WIDTH=4'd25,DEPTH=7'd64;//假设位宽为25，深度为64,只考虑深度为2的幂次方的情况

reg [WIDTH-1 : 0] ram [DEPTH-1 : 0];//开辟存储区
//reg [DEPTH-1 : 0] count;
//wire [WIDTH-1 : 0] dout,din;//读写数据
reg[5:0] rp,wp;//定义读写指针

//写入数据din
always@(posedge clk) begin
if((wr_en & ~full) || (full & wr_en & rd_en)) begin
	ram[wp] <= din;
	end
end

//读出数据dout
assign dout = (rd_en & ~empty)?ram[rp]:0;

//写指针wp
always@(posedge clk)begin
	if(!rst_n)begin
		wp <= 0;
	end
	else if(wr_en & ~full) begin
		wp <= wp + 1;
		end
	else if(full && (wr_en & rd_en)) begin
		wp <= wp + 1;
	end
end

//读指针rp
always@(posedge clk) begin
	if(!rst_n) begin
		rp <= 0;
	end
    else if(rd_en & ~empty) begin
        rp <= rp + 1;
    end
end

//满标志full
always@(posedge clk) begin
    if(!rst_n) begin
        full <= 0;
    end
    else if((wr_en & ~rd_en) && (wp == rp - 1)) begin
        full <= 1;
    end
    else if(full & rd_en) begin
        full <= 0;
    end
end

//空标志empty
always@(posedge clk) begin
    if(!rst_n) begin
        empty <= 1;
    end
    else if(wr_en & empty) begin
        empty <= 0;
    end
    else if((rd_en & ~wr_en) && (rp == wp - 1)) begin
        empty <= 1;
    end
end

endmodule 