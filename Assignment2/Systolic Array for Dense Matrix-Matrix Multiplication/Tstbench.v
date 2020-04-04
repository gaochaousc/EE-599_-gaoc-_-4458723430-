`define matrix_size 16
`define result_length 20
`define input_length 8
`timescale 1 ns / 100 ps
module SystolicArray_tb
#(
	parameter N = `matrix_size,
	parameter Result = `result_length,
	parameter IP= `input_length
);
reg clk;
reg reset; 
reg check_point;
reg		[IP-1:0] matrix_row[N-1:0][N-1:0];
reg		[IP-1:0] matrix_column[N-1:0][N-1:0];
wire	[Result*N*N-1:0] out;
wire    [IP*N-1:0] col_buffer;
wire    [IP*N-1:0] row_buffer;
wire	[Result-1:0] matrix_out_tb[N-1:0][N-1:0];
reg 	[IP-1:0] col_buffer_tb[N-1:0];
reg 	[IP-1:0] row_buffer_tb[N-1:0];
reg     [7:0] i,j,k,cnt;
localparam CLK_PERIOD = 10;
wire [IP*N*(N+1)-1:0] interconn;
integer A,B,S;
  
SystolicArray  top (.clk(clk), .reset(reset), .col_in(col_buffer), .row_in(row_buffer), .out(out));
assign interconn = top.interconn;
initial
  begin  : CLK_GENERATOR
    clk = 0;
    forever
       begin
	      #(CLK_PERIOD/2) clk = ~clk;
       end 
  end

initial
  begin  : RESET_GENERATOR
    reset = 0;
    #(10) reset = 1;
  end
 
initial
	begin : MATRIX_GENERATOR
	A = $fopen("../../../../Matrix_row.txt", "w");
	B = $fopen("../../../../Matrix_column.txt", "w");
	for (i = 0; i < N; i = i + 1)
		begin
		for (j = 0; j < N; j = j + 1)
			begin
				matrix_row[i][j] = $random % 128;
				matrix_column[i][j] = $random % 128;
				col_buffer_tb[i] = 0;
				row_buffer_tb[i] = 0;
				$fwrite(A, "%d ", matrix_row[i][j]);
				$fwrite(B, "%d ", matrix_column[i][j]);
			end
			$fwrite(A, "\n");$fwrite(B, "\n");
		end
	$fclose(A);
	$fclose(B);
	end
  
always @ (posedge clk, negedge reset)
	begin
		if (reset == 1'b0)
		begin
		    cnt <= 0;
			k = 0;
			for (i = 0; i < N; i = i + 1)
			begin
				col_buffer_tb[i] <= 0;
				row_buffer_tb[i] <= 0;
			end
		end
		else
            begin
                cnt <= cnt + 1;
                if (cnt == 3 * N - 1)
                    begin
                    check_point = 1;
                    S = $fopen("../../../../Matrix_Result.txt", "w");
                    for (i = 0; i < N; i = i + 1)
                        begin
                            for (j = 0; j < N; j = j + 1)
                                begin
                                    $fwrite(S, "%d ", matrix_out_tb[i][j]);
                                end
                            $fwrite(S, "\n");
		                  end
		              $fclose(S);
		              end   
		       if (cnt >= 3 * N - 2)
		          check_point = 1;
		        else
                    check_point = 0;
                for (i = 0; i < N; i = i + 1)
                    begin
                        k = cnt - i; 
                        if (k < 0 || k > N - 1 || cnt >= 2 * N - 1)
                            begin
                                col_buffer_tb[i] <= 0;
                                row_buffer_tb[i] <= 0;
                            end
                        else
                            begin
                                col_buffer_tb[i] <= matrix_row[i][k];
                                row_buffer_tb[i] <= matrix_column[k][i];				
                            end
                  end             
		end
	end
genvar p,q;
generate
    for (p = 0; p < N; p = p + 1) begin
        for (q = 0; q < N; q = q + 1) begin:IO_buffer
		assign matrix_out_tb[p][q] = out[Result*p*N+Result*q+Result-1:Result*p*N+Result*q];
		assign col_buffer[8*p+7:8*p] = col_buffer_tb[p];
		assign row_buffer[8*p+7:8*p] = row_buffer_tb[p];
    end     
    end
endgenerate
endmodule