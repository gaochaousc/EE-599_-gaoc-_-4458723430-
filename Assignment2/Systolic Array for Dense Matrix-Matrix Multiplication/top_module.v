`define matrix_size 32
`define result_length 21
`define input_length 8
`timescale 1 ns / 100 ps
module PE
#(
	parameter N = `matrix_size,
	parameter Result = `result_length,
	parameter IP= `input_length
)
(
	input			clk,
	input			reset,
	input	signed	[IP-1:0]	A,
	input	signed	[IP-1:0]	B,
	output  reg	signed  [IP-1:0] out_A,
	output  reg	signed  [IP-1:0] out_B,
	output  reg	signed  [Result-1:0] out_C
);
always @(posedge clk)begin
    if(reset) begin
      out_A=0;
      out_B=0;
      out_C=0;
    end
    else begin  
      out_C=out_C+A*B;
      out_A=A;
      out_B=B;
    end
 end
 
endmodule

module PERow
#(
	parameter N = `matrix_size,
	parameter Result = `result_length,
	parameter IP= `input_length
)
(
	input			clk,
	input			reset,
	input	signed	[IP*N-1:0]	row_in,
	input	signed	[IP-1:0]		col_A_in,
	output 	signed  [IP*N-1:0] 	row_B_out,
	output 	signed  [Result*N-1:0] 	row_out
);
wire [IP*(N+1)-1:0] interconn;
assign interconn[IP-1:0] = col_A_in;

genvar i;
generate
	for (i = 0; i < N; i = i + 1) 
		begin:  PE_Row
		PE pe(clk, 
		reset, 
		interconn[IP*i+IP-1:IP*i], 
		row_in[IP*(i+1)-1:IP*i], 
		interconn[IP*(i+1)+IP-1:IP*(i+1)], 
		row_B_out[IP*i+IP-1:IP*i], 
		row_out[Result*(i+1)-1:Result*i]);
		end
endgenerate
endmodule

module SystolicArray
#(
	parameter N = `matrix_size,
	parameter Result = `result_length
)
(
	input			clk,
	input			reset,
	input	signed	[8*N-1:0]	col_in,
	input	signed	[8*N-1:0]	row_in,
	output 	signed  [Result*N*N-1:0] 	out
);
wire [8*N*(N+1)-1:0] interconn;
assign interconn[8*N-1:0] = row_in;

genvar i;
generate
	for (i = 0; i < N; i = i + 1) 
		begin:  systolic_array
		PERow row(clk,
		 reset, 
		 interconn[8*N*(i+1)-1:8*N*i],
		 col_in[8*i+7:8*i],
		 interconn[8*N*(i+2)-1:8*N*(i+1)], 
		 out[Result*N*(i+1)-1:Result*N*i]);
		end
endgenerate
endmodule