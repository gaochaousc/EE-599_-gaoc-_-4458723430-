`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2020 04:26:35 PM
// Design Name: 
// Module Name: testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module testbench;

    parameter	BIT_WIDTH	=	8;
    parameter N=8;

	reg						clk;
	reg 					reset;
	reg		[BIT_WIDTH*N-1:0]	A;//one row
	reg		[BIT_WIDTH*N-1:0]	B;//one col
	wire    [BIT_WIDTH-1:0]	C;// one element
	
	
	reg [BIT_WIDTH-1:0] A_Matrix [0:N-1][0:N-1];
	reg [BIT_WIDTH-1:0] B_Matrix [0:N-1][0:N-1];
	reg [BIT_WIDTH-1:0] C_Matrix [0:N-1][0:N-1];
	
	
	MulandAddTree
	#(
	.BIT_WIDTH(BIT_WIDTH),
	.N(N)
	)
	MAT(
	.clk(clk),
	.rst(reset),
	.A(A),
	.B(B),
	.C(C)
	);
	
	initial begin
		clk		=	0;
		forever	begin
			#5;
			clk	=	~clk;
		end
	end

	initial begin
		reset		=	1;
		#100;
		reset		=	0;
		#20000;
	end
    integer r;//row
    integer c;//col
    integer k;//bit
    reg [2:0] state;
    
    localparam    
    INI =       3'b001,
    LOAD =      3'b010,
    LOAD_NEW_COL =     3'b100;
/*
    always @(posedge clk) begin
		if(reset)	begin
			A_Matrix 		<=	0;
			A_Matrix 		<=	0;
			state <= INI;
		end
		else	
		  begin
		  case (state)
		      INI:
                  for(r = 0; r <N; r = r+1) 
                  begin
                      for(c = 0;c<N;c = c+1)
                      begin
                           for (k = 0;k < BIT_WIDTH;k = k + 1) //only set lower 3 bit, otherwise may overflow
                            begin
                                if(k<3) begin
                                    A_Matrix[r][c][k] = $random();
                                    B_Matrix[r][c][k]  = $random();       
                                end
                                else begin
                                    A_Matrix[r][c][k] = 0;
                                    B_Matrix[r][c][k]  = 0;    
                                end        
                            end
                      end
                      state <= LOAD_ROW;
                   end
               LOAD_ROW:
                    begin
                      for(c = 0;c<N;c = c+1)
                      begin
                           for (k = 0;k < 3;k = k + 1) //only set lower 3 bit, otherwise may overflow
                            begin
                               A[c*BIT_WIDTH+k] = $random();
                               B[c*BIT_WIDTH+k] = $random();
                              state<=LOAD_ROW;
                            end
                      end  
                    end
             endcase 
		  end
	end
*/	
integer counter_row;
integer counter_col;

integer counter_c_row;
integer counter_c_col;
integer clk_counter;

//counter = 0;
always @(posedge clk) begin
		if(reset)	begin
			A 		<=	0;
			A		<=	0;
			state <= INI;
					counter_c_row <=0;
			        counter_c_col <=0;
			        clk_counter <=0;
		end
		else	
		  begin
              case (state)
                  INI:
                  begin
                  	counter_row <=0;
			        counter_col <=0;

                    for(r = 0; r <N; r = r+1) 
                          begin
                              for(c = 0;c<N;c = c+1)
                              begin
                                   for (k = 0;k < BIT_WIDTH;k = k + 1) //only set lower 3 bit, otherwise may overflow
                                    begin
                                        if(k<3) begin
                                            A_Matrix[r][c][k] = $random();
                                            B_Matrix[r][c][k]  = $random();       
                                        end
                                        else begin
                                            A_Matrix[r][c][k] = 0;
                                            B_Matrix[r][c][k]  = 0;    
                                        end        
                                    end
                              end
                           end
                    state<=LOAD;
                  end
                  LOAD:	
                  begin
                 // for(r = 0; r <N; r = r+1)
                //      begin
                
                /*
                      for(c = 0;c<N;c = c+1)
                      begin
                           for (k = 0;k < BIT_WIDTH;k = k + 1) //only set lower 3 bit, otherwise may overflow
                            begin
                               A[c*BIT_WIDTH+k] = $random();
                               B[c*BIT_WIDTH+k] = $random();                         
                            end
                      end 
                      state<=LOAD_NEW_ROW;
                   end
                   */   
                  clk_counter<=clk_counter+1;
                  for(c = 0;c<N;c = c+1)
                      begin
                           for (k = 0;k < BIT_WIDTH;k = k + 1) //only set lower 3 bit, otherwise may overflow
                            begin
                               A[c*BIT_WIDTH+k] = A_Matrix[counter_row][c][k];//$random();
                               B[c*BIT_WIDTH+k] = B_Matrix[c][counter_col][k];//$random();                         
                            end
                      end 
                      //check
                      if(counter_col==N-1) begin
                        if(counter_row == N-1) begin
                            state<=INI;
                            counter_row<=0;
                            counter_col<=0;
                           // reset<=1;
                        end
                        else begin
                            counter_row<=counter_row+1;
                            state<=LOAD;
                            counter_col<=0;
                        end
                      end
                      else begin
                        counter_col<=counter_col+1;
                        state<=LOAD;
                      end                                       
                   end
          endcase
          
        if(clk_counter > $clog2(N)) 
        begin
          C_Matrix[counter_c_row][counter_c_col]<=C;
          if(counter_c_col==N-1) begin
            if(counter_c_row == N-1) begin
                counter_c_row <= 0;
                counter_c_col <= 0;
                reset=1;
            end
            else begin
                counter_c_row<=counter_c_row+1;
                counter_c_col<=0;
            end
          end
          else begin
            counter_c_col<=counter_c_col+1;
          end     
        end
		end
		
		
	end
    
     
    /*
	always @(posedge clk) begin
		if(reset)	begin
			A 		<=	0;
			B 		<=	0;
		end
		else	
		  begin
		      for(c = 0;c<N;c = c+1)
		      begin
                   for (k = 0;k < 3;k = k + 1) //only set lower 3 bit, otherwise may overflow
                    begin
                       A[c*BIT_WIDTH+k] = $random();
                       B[c*BIT_WIDTH+k] = $random();
                      
                    end
              end  
		end
	end
	
	*/
	
    
endmodule
