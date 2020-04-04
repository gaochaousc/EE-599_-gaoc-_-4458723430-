`timescale 1ns / 1ps
module mux(
            input a,
            input b,
            input select,
            output reg result
    );
    always @ (a,b,select) begin
        case (select)
        0:result = a;
        1:result = b;
        endcase
        end
endmodule
module muxstater#(    
    parameter width = 8,
    parameter N=8,
    parameter muxstate=0)
    (
    input clk,
    input [width*N-1:0] IN,
    input [$clog2(N)-1:0] A,
    output reg [width*N-1:0] out,
    output reg [$clog2(N)-1:0] B
    );
    wire [width*N-1:0] middle;
   
    wire [width-1:0] IN0_arr [0:N-1];
    wire [width-1:0] IN1_arr [0:N-1];
    wire [width-1:0] OUT_arr [0:N-1];

    genvar m;
    generate
    for(m=0;m<N;m=m+1) begin
        assign IN0_arr[m]= IN[(m+1)*width-1:m*width];
        if((m+2**(muxstate))< N)begin
            assign IN1_arr[m+2**(muxstate)]= IN[(m+1)*width-1:m*width];
        end
        else begin
            assign IN1_arr[m+2**(muxstate)-N]= IN[(m+1)*width-1:m*width];
        end
        
    end
    endgenerate
    genvar i;
    generate
        for (i=0;i<N;i=i+1)begin
             MUX#(
            .BIT_WIDTH (width),
            .N(N))
            MUX1(
            .a(IN0_arr[i]),
            .b(IN1_arr[i]),
            .select(B[muxstate]),
            .result(middle[(i+1)*width-1:i*width])
            );
            assign OUT_arr[i]=middle[(i+1)*width-1:i*width];
        end
     endgenerate
     
    always @(posedge clk)
    begin
        out <= middle;
        B<=A;
    end 
endmodule
module Barrel_Shifter#(
     parameter width = 8,
     parameter N=64)
     (
     input clk,
     input [width*N-1:0] IN,
     input [$clog2(N)-1:0] Shift,
     output [width*N-1:0] OUT
     );
     wire [width*N-1:0] IN_l [0:5]; 
     wire [width*N-1:0] OUT_l [0:5]; 
     wire [$clog2(N)-1:0] Shift_I[0:5];
     wire [$clog2(N)-1:0] Shift_O[0:5];  
     genvar m;
     generate
	 for(m=0;m<$clog2(N);m=m+1) begin
	   if(m==0)begin
	       assign IN_l[m]=IN;
	       assign Shift_I[m]=Shift;
	       end
	   else
	       begin
	       assign IN_l[m]=OUT_l[m-1];
	       assign Shift_I[m]=Shift_O[m-1];
	       end
	   muxstate#(
        .width (width),.N(N),.muxstate(m))
         Layer(.clk(clk), .IN(IN_l[m]), .A(Shift_I[m]), .OUT(OUT_l[m]), .B(Shift_O[m]));
	 end
	 assign OUT=OUT_l[5];
	 endgenerate
endmodule