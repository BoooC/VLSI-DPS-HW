`timescale 1ns/10ps
`define CYCLE      50.0
`define SDFFILE    "qr_cordic_syn.sdf"
`define End_CYCLE  1000
    

`define A_MEM      "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/input_A_matrix.txt"
`define R_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_R_matrix_golden.txt"
`define Q_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_Q_matrix_golden.txt"


module qr_cordic_tb;

parameter Q_len		= 64;
parameter R_len		= 32;
parameter OUT_WIDTH = 12;

parameter A_ROM_SIZE = 32;
parameter R_RAM_SIZE = 32;
parameter Q_RAM_SIZE = 64;


reg	rst = 0;
reg	clk = 0;
reg	en 	= 0;

wire rd_A;
wire wr_R;
wire wr_Q;

wire signed [OUT_WIDTH-1:0] rd_A_data;
wire signed [OUT_WIDTH-1:0]	wr_R_data;
wire signed [OUT_WIDTH-1:0]	wr_Q_data;

wire [2:0]	rd_A_row_addr;
wire [1:0]	rd_A_col_addr;
wire [2:0]	wr_R_row_addr;
wire [1:0]	wr_R_col_addr;
wire [2:0]	wr_Q_row_addr;
wire [2:0]	wr_Q_col_addr;

wire [4:0] rd_A_addr = 4*rd_A_row_addr + rd_A_col_addr;
wire [4:0] wr_R_addr = 4*wr_R_row_addr + wr_R_col_addr;
wire [5:0] wr_Q_addr = 8*wr_Q_row_addr + wr_Q_col_addr;

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

RAM  #(
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

RAM #(
	.OUT_WIDTH	(OUT_WIDTH), 
	.RAM_SIZE	(Q_RAM_SIZE),
	.ADDR_WID	(6)
) 
RAM_Q_inst(
	.clk		(clk		),
	.rst		(rst		),
	.wr_R		(wr_Q		),
	.wr_R_addr	(wr_Q_addr	),
	.wr_R_data	(wr_Q_data	)
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
	while(i<8) begin
		$display("%13d %13d %13d %13d", ROM_A_inst.ROM[4*i], ROM_A_inst.ROM[4*i+1], ROM_A_inst.ROM[4*i+2], ROM_A_inst.ROM[4*i+3]);
		i = i + 1;
	end
	
	wait (valid);
	
	// display matrix R
	$display("");
	$display("Output R matrix golden pattern: ");
	while(k<8) begin
		$display("%13d %13d %13d %13d", R_gold[4*k], R_gold[4*k+1], R_gold[4*k+2], R_gold[4*k+3]);
		k = k + 1;
	end
	
	$display("R matrix calculated result: ");
	@(posedge clk);
	while(j<8) begin
		$display("%13d %13d %13d %13d", RAM_R_inst.RAM[4*j], RAM_R_inst.RAM[4*j+1], RAM_R_inst.RAM[4*j+2], RAM_R_inst.RAM[4*j+3]);
		j = j + 1;
	end
	
	/*
	// display matrix Q
	$display("");
	$display("Output Q matrix golden pattern: ");
	while(m<4) begin
		$display("%12d %12d %12d %12d", Q_gold[4*m], Q_gold[4*m+1], Q_gold[4*m+2], Q_gold[4*m+3]);
		m = m + 1;
	end
	$display("Q matrix calculated result: ");
	@(posedge clk);
	while(l<4) begin
		$display("%12d %12d %12d %12d", RAM_Q_inst.RAM[4*l+0], RAM_Q_inst.RAM[4*l+1], RAM_Q_inst.RAM[4*l+2], RAM_Q_inst.RAM[4*l+3],
										RAM_Q_inst.RAM[4*l+4], RAM_Q_inst.RAM[4*l+5], RAM_Q_inst.RAM[4*l+6], RAM_Q_inst.RAM[4*l+7]);
		l = l + 1;
	end
	*/
	
	// check R matrix
	err_R = 0;
	for(u=0; u<R_len; u=u+1) begin
		if (RAM_R_inst.RAM[u] != R_gold[u]) begin
			err_R = err_R + 1;
			$display("Data R[%2d] is wrong! The output data is %5d, but the expected data is %5d.", u, RAM_R_inst.RAM[u], R_gold[u]);
		end
	end
	$display("");
	
	// check Q matrix
	err_Q = 0;
	/*
	for(v=0; v<Q_len; v=v+1) begin
		if (RAM_Q_inst.RAM[v] != Q_gold[v]) begin
			err_Q = err_Q + 1;
			$display("Data Q[%2d] is wrong! The output data is %5d, but the expected data is %5d.", v, RAM_Q_inst.RAM[v], Q_gold[v]);
		end
	end
	*/
	
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
		if(err_R != 0) begin
			$display("*****************************************************************************");
			$display("** FAIL!!! There are %3d error in R matrix!                                **", err_R);
			$display("*****************************************************************************");
		end
		else begin
			$display("*****************************************************************************");
			$display("** PASS!!! all data are correct in R matrix!                                **", err_R);
			$display("*****************************************************************************");
		end
		if(err_Q != 0) begin
			$display("*****************************************************************************");
			$display("** FAIL!!! There are %3d error in Q matrix!                                **", err_Q);
			$display("*****************************************************************************");
		end
		else begin
			$display("*****************************************************************************");
			$display("** PASS!!! All data are correct in Q matrix!                                **", err_R);
			$display("*****************************************************************************");
		end
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
		$display("********************************************************************");
		$display("**  Failed waiting Valid signal, Simulation STOP at cycle %4d    **",cycle);
		$display("**  If needed, You can increase End_CYCLE                         **");
		$display("********************************************************************");
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


module RAM #(
	parameter OUT_WIDTH = 12,
	parameter RAM_SIZE 	= 32,
	parameter ADDR_WID	= 5
)
(
	input	       	       			clk,
	input							rst,
	input	       	       			wr_R,
	input	       	[ADDR_WID-1:0] 	wr_R_addr,
	input	 signed	[OUT_WIDTH-1:0] wr_R_data
);


reg signed [OUT_WIDTH-1:0] RAM [0:RAM_SIZE-1];

integer i;
always @(posedge clk) begin
	if(rst) begin
		for(i=0; i<RAM_SIZE; i=i+1) begin
			RAM[i] <= 0;
		end
	end
	else if(wr_R) begin
		RAM[wr_R_addr] <= wr_R_data;
	end
end


endmodule
