module buttons (
                            input clk, //100M
							input  key_c,     //start
							//input  key_right,  //change
							
							output start
							//output change
							);
							
							reg [17:0] cnt_c;                          						
		                    reg en,enable;
							reg en0;
							reg [1:0] state;
							
                        parameter  waiting=0;
						parameter  setup=1;
						parameter  send=2;
						parameter  released=3;
						
				always @ (posedge clk)
				    begin
					   state<=waiting;
                      case(state)
					     waiting: begin 
									//if(key_c || key_right )
									if(key_c )
						               begin 
							              state<=setup;
                                          cnt_c<=0;
										  en<=0;
									   end
									   else 
									      begin
										     state<=waiting;
											 cnt_c<=0;
											 en<=0;
										   end
							            end			   
						setup:      begin  
									if(cnt_c<50000)
						                 begin
										  cnt_c<=cnt_c+1;
										  state<=setup;
									     end
								    else if(cnt_c>=50000)
									       begin
										     cnt_c<=0;
											 state<=send;
										   end
								    else
									       begin
										      cnt_c<=0;
											  state<=waiting;
											end
									end
						send:     begin 
									//if(key_c || key_right )
									if(key_c )
						                begin
										   en<=1;
										   state<=released;
										end
								     else                                    
                                           state<=waiting;								
									end
									
						released: begin
									//if(!(key_c || key_right ))	
									if( !key_c )										
                                        begin
                                           en<=0;
										   state<=waiting;
										 end
									  else
									      begin
									        state<=released;
										    en<=0;
										  end
									end
						endcase
					end
		
      always @ (posedge clk)
	       begin
		      en0<=en;
		   end
		 
		always @ (posedge clk)  //en转化沿触发信号
		     begin
			    if((en==1)&&(en0==0))
				    enable<=1;
			    else 
				    enable<=0;
			 end
		
	   //脉冲输出
	   assign  start=(enable && key_c)?1:0;
	   //assign  change=(enable && key_right)?1:0;
	   
	   endmodule 

	