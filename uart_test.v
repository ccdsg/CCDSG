module  test(
				input clk,
				input rst,
				input din,

				output    [7:0] dout,
				output  done,
				output  download
				);

wire  [23:0] pic_out;
//wire  [1:0] state;
wire  wr_ram;
wire [16:0] addr;
wire rst_n;
wire clk0;
//wire  [7:0] dout1;
assign rst_n=~rst;


	
	uart_top  uart_top (
									.clk(clk0),
									.rst_n(rst_n),
									.din(din),
									.pic_out(pic_out),
									.addr(addr),
									.wr_ram(wr_ram),
									.pic_done(done),
									.pic_download(download),
									.dout(dout)
								);

    pll pll(
				.clk(clk),
				.clk0(clk0)
				);
				
	
	endmodule 		
		     