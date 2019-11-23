module  arbiter_v2(
                          input key_start,
						 // input key_change,
					      input rst_n,
						  input clk, // 100M
						  output reg start,     //开始去雾
						  //output reg pic_change ,              //换图片 0：图1  ，1：图2(addr=0+129600)      
                          output reg switch_ram		//0:原图     1:去雾图				  
						);
						
always @ (negedge clk)     //开始去雾&切换显示原图去雾图
    begin  
	  if(!rst_n)
	     begin
		    start<=0;
			switch_ram<=0;
         end
      else if(key_start)   
	         begin
			   start<=~start;
			   switch_ram<=~switch_ram;
			end
     //else if (key_change)
     //       begin 
     //          start<=0;
     //          switch_ram<=0;
     //       end				
      else 
	       begin
		      start<=start;
			  switch_ram<=switch_ram;
		   end
     end
	 
	 
//always @ (negedge clk)  //换图片
//   begin  
//      if(!rst_n)
//		    pic_change<=0;
//	  else if(key_change)
//	        pic_change<=~pic_change;
//	   else
//            pic_change<=pic_change;
//     end
 
endmodule  