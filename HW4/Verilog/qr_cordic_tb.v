`timescale 1ns/10ps
`define CYCLE      50.0
`define SDFFILE    "qr_cordic_syn.sdf"
`define End_CYCLE  1000
    

`define A_MEM      "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/input_A_matrix.txt"
`define R_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_R_matrix_golden.txt"
`define Q_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_Q_matrix_golden.txt"


module qr_cordic_tb;

parameter Q_row	= 8;
parameter Q_col	= 8;
parameter R_row	= 8;
parameter R_col	= 4;

parameter Q_len		= Q_row * Q_col;
parameter R_len		= R_row * R_col;
parameter OUT_WIDTH = 12;

parameter A_ROM_SIZE = R_len;
parameter Q_RAM_SIZE = Q_len;
parameter R_RAM_SIZE = R_len;


reg	rst = 0;
reg	clk = 0;
reg	en 	= 0;

wire rd_A;
wire wr_R;
wire wr_Q_1, wr_Q_2, wr_Q_3, wr_Q_4, wr_Q_5, wr_Q_6, wr_Q_7, wr_Q_8;

wire signed [OUT_WIDTH-1:0] rd_A_data;
wire signed [OUT_WIDTH-1:0]	wr_R_data;
wire signed [OUT_WIDTH-1:0]	wr_Q_data_1, wr_Q_data_2, wr_Q_data_3, wr_Q_data_4, wr_Q_data_5, wr_Q_data_6, wr_Q_data_7, wr_Q_data_8;

wire [2:0]	rd_A_row_addr;
wire [1:0]	rd_A_col_addr;
wire [2:0]	wr_R_row_addr;
wire [1:0]	wr_R_col_addr;
wire [2:0]	wr_Q_1_row_addr;
wire [2:0]	wr_Q_1_col_addr_1;

wire [4:0] rd_A_addr = R_col*rd_A_row_addr + rd_A_col_addr;
wire [4:0] wr_R_addr = R_col*wr_R_row_addr + wr_R_col_addr;

wire [2:0]  wr_Q_addr_1, wr_Q_addr_2, wr_Q_addr_3, wr_Q_addr_4, wr_Q_addr_5, wr_Q_addr_6, wr_Q_addr_7, wr_Q_addr_8;

wire valid;


qr_cordic qr_cordic_inst(
	.clk			(clk			),
	.rst			(rst			),
	.en				(en				),
	.rd_A			(rd_A			),
	.rd_A_data		(rd_A_data		),
	.rd_A_row_addr	(rd_A_row_addr	),
	.rd_A_col_addr	(rd_A_col_addr	),
	.wr_R			(wr_R			),
	.wr_R_data		(wr_R_data		),
	.wr_R_row_addr	(wr_R_row_addr	),
	.wr_R_col_addr	(wr_R_col_addr	),
	.wr_Q_1			(wr_Q_1			),
	.wr_Q_data_1	(wr_Q_data_1	),
	.wr_Q_addr_1	(wr_Q_addr_1	),
	.wr_Q_2			(wr_Q_2			),
	.wr_Q_data_2	(wr_Q_data_2	),
	.wr_Q_addr_2	(wr_Q_addr_2	),
	.wr_Q_3			(wr_Q_3			),
	.wr_Q_data_3	(wr_Q_data_3	),
	.wr_Q_addr_3	(wr_Q_addr_3	),
	.wr_Q_4			(wr_Q_4			),
	.wr_Q_data_4	(wr_Q_data_4	),
	.wr_Q_addr_4	(wr_Q_addr_4	),
	.wr_Q_5			(wr_Q_5			),
	.wr_Q_data_5	(wr_Q_data_5	),
	.wr_Q_addr_5	(wr_Q_addr_5	),
	.wr_Q_6			(wr_Q_6			),
	.wr_Q_data_6	(wr_Q_data_6	),
	.wr_Q_addr_6	(wr_Q_addr_6	),
	.wr_Q_7			(wr_Q_7			),
	.wr_Q_data_7	(wr_Q_data_7	),
	.wr_Q_addr_7	(wr_Q_addr_7	),
	.wr_Q_8			(wr_Q_8			),
	.wr_Q_data_8	(wr_Q_data_8	),
	.wr_Q_addr_8	(wr_Q_addr_8	),
	.valid			(valid			)
);

ROM  #(
	.OUT_WIDTH	(OUT_WIDTH), 
	.ROM_SIZE	(A_ROM_SIZE)
) 
ROM_A_inst(
	.clk		(clk		),
	.rd_A		(rd_A		),
	.rd_A_addr	(rd_A_addr	),
	.rd_A_data	(rd_A_data	)
);

RAM_R  #(
	.OUT_WIDTH	(OUT_WIDTH), 
	.RAM_SIZE	(R_RAM_SIZE),
	.ADDR_WID	(5)
) 
RAM_R_inst(
	.clk		(clk		),
	.rst		(rst		),
	.wr_R		(wr_R		),
	.wr_R_addr	(wr_R_addr	),
	.wr_R_data	(wr_R_data	)
);

RAM_Q #(
	.OUT_WIDTH	(OUT_WIDTH), 
	.RAM_SIZE	(Q_RAM_SIZE),
	.ADDR_WID	(3)
) 
RAM_Q_inst(
	.clk		(clk		),
	.rst		(rst		),
	.wr_Q_1		(wr_Q_1		),
	.wr_Q_data_1(wr_Q_data_1),
	.wr_Q_addr_1(wr_Q_addr_1),
	.wr_Q_2		(wr_Q_2		),
	.wr_Q_data_2(wr_Q_data_2),
	.wr_Q_addr_2(wr_Q_addr_2),
	.wr_Q_3		(wr_Q_3		),
	.wr_Q_data_3(wr_Q_data_3),
	.wr_Q_addr_3(wr_Q_addr_3),
	.wr_Q_4		(wr_Q_4		),
	.wr_Q_data_4(wr_Q_data_4),
	.wr_Q_addr_4(wr_Q_addr_4),
	.wr_Q_5		(wr_Q_5		),
	.wr_Q_data_5(wr_Q_data_5),
	.wr_Q_addr_5(wr_Q_addr_5),
	.wr_Q_6		(wr_Q_6		),
	.wr_Q_data_6(wr_Q_data_6),
	.wr_Q_addr_6(wr_Q_addr_6),
	.wr_Q_7		(wr_Q_7		),
	.wr_Q_data_7(wr_Q_data_7),
	.wr_Q_addr_7(wr_Q_addr_7),
	.wr_Q_8		(wr_Q_8		),
	.wr_Q_data_8(wr_Q_data_8),
	.wr_Q_addr_8(wr_Q_addr_8)
);


`ifdef SDF
	initial $sdf_annotate(`SDFFILE, qr_cord_Aic_inst);
`endif


always #(`CYCLE/2) clk = ~clk;

// initial begin
// 	$fsdbDumpfile("qr_cord_Aic.fsdb");
// 	$fsdbDumpvars;
// 	$fsdbDumpMDA;
// end

//-------------------------------------------------------------------------------------------------------------------
//expected result
reg signed [OUT_WIDTH-1:0] R_gold [0:R_RAM_SIZE-1];
reg signed [OUT_WIDTH-1:0] Q_gold [0:Q_RAM_SIZE-1];

initial begin
	$readmemb(`R_GOLD, R_gold);	
	$readmemb(`Q_GOLD, Q_gold);	
end

// global control
initial begin
	@(negedge clk); #1; rst = 1'b1;
	#(`CYCLE*2); 	#1; en 	= 1'b1;
   	#(`CYCLE);   	#1; rst = 1'b0;
   	wait(valid); 	#1	en 	= 1'b0;
end


//-------------------------------------------------------------------------------------------------------------------
integer err_R, err_Q;
integer i = 0;
integer j = 0;
integer k = 0;
integer n = 0; 
integer m = 0;
integer l = 0;
integer u, v;

initial begin
	$display("-------------------------------------------------------\n");
 	$display("START!!! Simulation Start .....\n");
 	$display("-------------------------------------------------------\n");
	$display("Input A matrix: ");
	while(i < R_row) begin
		$display("%8d %8d %8d %8d", ROM_A_inst.ROM[4*i], ROM_A_inst.ROM[4*i+1], ROM_A_inst.ROM[4*i+2], ROM_A_inst.ROM[4*i+3]);
		i = i + 1;
	end
	
	wait (valid);
	
	
	/***********************************************************************************/
	/**                                 Display matrix                                **/
	/***********************************************************************************/
	// display matrix R
	$display("");
	$display("Output R matrix golden pattern: ");
	while(k < R_row) begin
		$display("%8d %8d %8d %8d", R_gold[R_col*k], R_gold[R_col*k+1], R_gold[R_col*k+2], R_gold[R_col*k+3]);
		k = k + 1;
	end
	
	$display("R matrix calculated result: ");
	@(posedge clk);
	while(j < R_row) begin
		$display("%8d %8d %8d %8d", RAM_R_inst.RAM_R[R_col*j], RAM_R_inst.RAM_R[R_col*j+1], RAM_R_inst.RAM_R[R_col*j+2], RAM_R_inst.RAM_R[R_col*j+3]);
		j = j + 1;
	end
	
	// display matrix Q
	$display("");
	$display("Output Q matrix golden pattern: ");
	while(m < Q_row) begin
		$display("%8d %8d %8d %8d %8d %8d %8d %8d", Q_gold[Q_col*m+0], Q_gold[Q_col*m+1], Q_gold[Q_col*m+2], Q_gold[Q_col*m+3], Q_gold[Q_col*m+4], Q_gold[Q_col*m+5], Q_gold[Q_col*m+6], Q_gold[Q_col*m+7]);
		m = m + 1;
	end
	$display("Q matrix calculated result: ");
	@(posedge clk);
	while(l < Q_row) begin
		$display("%8d %8d %8d %8d %8d %8d %8d %8d", RAM_Q_inst.RAM_Q[Q_col*l+0], RAM_Q_inst.RAM_Q[Q_col*l+1], RAM_Q_inst.RAM_Q[Q_col*l+2], RAM_Q_inst.RAM_Q[Q_col*l+3], RAM_Q_inst.RAM_Q[Q_col*l+4], RAM_Q_inst.RAM_Q[Q_col*l+5], RAM_Q_inst.RAM_Q[Q_col*l+6], RAM_Q_inst.RAM_Q[Q_col*l+7]);
		l = l + 1;
	end
	
	/***********************************************************************************/
	/**                                  Check Matrix                                 **/
	/***********************************************************************************/
	// check R matrix
	err_R = 0;
	for(u=0; u<R_len; u=u+1) begin
		if (RAM_R_inst.RAM_R[u] != R_gold[u]) begin
			err_R = err_R + 1;
			$display("Data R[%2d] is wrong! The output data is %5d, but the expected data is %5d.", u, RAM_R_inst.RAM_R[u], R_gold[u]);
		end
	end
	$display("");
	
	// check Q matrix
	err_Q = 0;
	for(v=0; v<Q_len; v=v+1) begin
		if (RAM_Q_inst.RAM_Q[v] != Q_gold[v] || ^RAM_Q_inst.RAM_Q[v] === 1'bz || ^RAM_Q_inst.RAM_Q[v] === 1'bx) begin
			err_Q = err_Q + 1;
			// $display("Data Q[%2d] is wrong! The output data is %5d, but the expected data is %5d.", v, RAM_Q_inst.RAM_Q[v], Q_gold[v]);
		end
	end
	/***********************************************************************************/
	/**                                     SUMMARY                                   **/
	/***********************************************************************************/
	$display(" ");
	$display("-------------------------------------------------------\n");
	$display("--------------------- S U M M A R Y -------------------\n");
	if(err_R == 0 && err_Q == 0) begin
		$display("*****************************************************************************");
		$display("** Congratulations!!! R and Q data are all correct! The result is PASS!!!  **");
		$display("** Get finish at cycle:%3d                                                 **", cycle);
		$display("*****************************************************************************");
	end
	else begin
		$display("*****************************************************************************");
		if(err_R != 0) begin
			$display("** FAIL!!!  There are %5d error in R matrix!                             **", err_R);
		end
		else begin
			$display("** PASS!!!  All data are correct in R matrix!                              **");
		end
		if(err_Q != 0) begin
			$display("** FAIL!!!  There are %5d error in Q matrix!                             **", err_Q);
		end
		else begin
			$display("** PASS!!!  All data are correct in Q matrix!                              **");
		end
		$display("*****************************************************************************");
	end
	#(`CYCLE); $stop;
end


//-------------------------------------------------------------------------------------------------------------------
// Calculate number of cycles needed
reg [9:0] cycle;
always@(posedge clk) begin
	if(rst) begin
		cycle <= 0;
	end
	else if(~valid) begin
		cycle = cycle + 1;
	end
end

always@(posedge clk) begin
	if(cycle > `End_CYCLE) begin
		$display("");
		$display("***************************************************************************");
		$display("**  Failed waiting Valid signal, Simulation STOP at cycle %4d           **",cycle);
		$display("**  The simulation can't be terminated under normal operation!           **");
		$display("***************************************************************************");
		$stop;
	end
end

endmodule


module ROM #(
	parameter OUT_WIDTH = 12,
	parameter ROM_SIZE 	= 32
)
(
	input                    			clk,
	input                    			rd_A,
	input             [4:0] 			rd_A_addr,
	output reg signed [OUT_WIDTH-1:0] 	rd_A_data
);


reg signed [OUT_WIDTH-1:0] ROM [0:ROM_SIZE-1];

initial begin
	$readmemb(`A_MEM, ROM);
end

always @(negedge clk) begin
	if(rd_A) begin
		rd_A_data <= ROM[rd_A_addr];
	end
end

endmodule


module RAM_R #(
	parameter OUT_WIDTH = 12,
	parameter RAM_SIZE 	= 32,
	parameter ADDR_WID	= 3
)
(	input	       	       			clk,
	input							rst,
	input	       	       			wr_R,
	input	       	[ADDR_WID-1:0] 	wr_R_addr,
	input	 signed	[OUT_WIDTH-1:0] wr_R_data
);

reg signed [OUT_WIDTH-1:0] RAM_R [0:RAM_SIZE-1];

integer i;
always @(posedge clk) begin
	if(rst) begin
		for(i=0; i<RAM_SIZE; i=i+1) begin
			RAM_R[i] <= 0;
		end
	end
	else if(wr_R) begin
		RAM_R[wr_R_addr] <= wr_R_data;
	end
end

endmodule

module RAM_Q #(
	parameter OUT_WIDTH = 12,
	parameter RAM_SIZE 	= 64,
	parameter ADDR_WID	= 5
)
(	input	       	       			clk,
	input							rst,
	input	       	       			wr_Q_1, wr_Q_2, wr_Q_3, wr_Q_4, wr_Q_5, wr_Q_6, wr_Q_7, wr_Q_8,
	input	       	[ADDR_WID-1:0] 	wr_Q_addr_1, wr_Q_addr_2, wr_Q_addr_3, wr_Q_addr_4, wr_Q_addr_5, wr_Q_addr_6, wr_Q_addr_7, wr_Q_addr_8,
	input	 signed	[OUT_WIDTH-1:0] wr_Q_data_1, wr_Q_data_2, wr_Q_data_3, wr_Q_data_4, wr_Q_data_5, wr_Q_data_6, wr_Q_data_7, wr_Q_data_8
);

reg signed [OUT_WIDTH-1:0] RAM_Q [0:RAM_SIZE-1];

integer i;
always @(posedge clk) begin
	if(rst) begin
		for(i=0; i<RAM_SIZE; i=i+1) begin
			RAM_Q[i] <= 0;
		end
	end
	else begin
		RAM_Q[wr_Q_addr_1 + 0*8] <= wr_Q_1 ? wr_Q_data_1 : RAM_Q[wr_Q_addr_1 + 0*8];
		RAM_Q[wr_Q_addr_2 + 1*8] <= wr_Q_2 ? wr_Q_data_2 : RAM_Q[wr_Q_addr_2 + 1*8];
		RAM_Q[wr_Q_addr_3 + 2*8] <= wr_Q_3 ? wr_Q_data_3 : RAM_Q[wr_Q_addr_3 + 2*8];
		RAM_Q[wr_Q_addr_4 + 3*8] <= wr_Q_4 ? wr_Q_data_4 : RAM_Q[wr_Q_addr_4 + 3*8];
		RAM_Q[wr_Q_addr_5 + 4*8] <= wr_Q_5 ? wr_Q_data_5 : RAM_Q[wr_Q_addr_5 + 4*8];
		RAM_Q[wr_Q_addr_6 + 5*8] <= wr_Q_6 ? wr_Q_data_6 : RAM_Q[wr_Q_addr_6 + 5*8];
		RAM_Q[wr_Q_addr_7 + 6*8] <= wr_Q_7 ? wr_Q_data_7 : RAM_Q[wr_Q_addr_7 + 6*8];
		RAM_Q[wr_Q_addr_8 + 7*8] <= wr_Q_8 ? wr_Q_data_8 : RAM_Q[wr_Q_addr_8 + 7*8];
	end
end

endmodule
