module BS_tb;
    parameter width	=8;
    parameter N =16;
	reg	clk;
	reg reset;
	reg	[width*N-1:0]	IN;
	reg  [3:0]    Shift;
	wire [width*N-1:0]	OUT;
	initial begin
	   clk	=0;
    forever	begin
	#5;
	   clk	=~clk;
	end
	end
	initial begin
	   reset=1;
	   #10;
	   reset=0;
	   #20000;
	end
	integer k;
	integer j;
	always @(posedge clk) begin
        if(reset == 0)
        begin
            for (k = 0;k < width*N;k = k + 1) 
                begin
                   IN[k] <= $random();
                end       
            for (j = 0;j < 4;j = j + 1) 
                begin
                   Shift[j] <= $random();
                end                       
        end
    end   
    Barrel_Shifter#(
    .width(width),//k
    .N(N))
     Barrel_Shifter1(
     .clk(clk),
     .IN(IN),
     .Shift(Shift),
     .OUT(OUT)
     );
endmodule