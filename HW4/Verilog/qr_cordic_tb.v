`timescale 1ns/10ps
`define CYCLE      50.0
`define SDFFILE    "/home/univtrain/qr_cordic/qr_cordic_syn.sdf"*/
`define End_CYCLE  10000

`define A_MEM      "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/input_A_matrix.txt"
`define R_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_R_matrix_golden.txt"
`define Q_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_Q_matrix_golden.txt"
// "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/input_A_matrix.txt"
// "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_R_matrix_golden.txt"
// "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_Q_matrix_golden.txt"

// "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/HW5/Verilog/input_A_matrix.txt"
// "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/HW5/Verilog/output_R_matrix_golden.txt"
// "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/HW5/Verilog/output_Q_matrix_golden.txt"

module qr_cordic_tb;

parameter Q_len		= 16;
parameter R_len		= 16;
parameter OUT_WIDTH = 12;

reg	clk = 0;
reg	rst = 0;
reg	en 	= 0;

wire wr_R;
wire wr_Q;
wire rd_A;

wire signed [OUT_WIDTH-1:0]	wr_data_R;
wire signed [OUT_WIDTH-1:0]	wr_data_Q;
wire signed [OUT_WIDTH-1:0] rd_data_A;

wire [1:0]	rd_row_addr_A;
wire [1:0]	rd_col_addr_A;
wire [1:0]	wr_row_addr_R;
wire [1:0]	wr_col_addr_R;
wire [1:0]	wr_row_addr_Q;
wire [1:0]	wr_col_addr_Q;

wire [3:0]	rd_addr_A;
wire [3:0]	wr_addr_R;
wire [3:0]	wr_addr_Q;

wire finish;

cordic cordic_inst(
	.clk			(clk			),
	.rst			(rst			),
	.en				(en				),
	.finish			(finish			),
	.rd_A			(rd_A			),
	.rd_data_A		(rd_data_A		),
	.rd_row_addr_A	(rd_row_addr_A	),
	.rd_col_addr_A	(rd_col_addr_A	),
	.wr_R			(wr_R			),
	.wr_data_R		(wr_data_R		),
	.wr_row_addr_R	(wr_row_addr_R	),
	.wr_col_addr_R	(wr_col_addr_R	),
	.wr_Q			(wr_Q			),
	.wr_data_Q		(wr_data_Q		),
	.wr_row_addr_Q	(wr_row_addr_Q	),
	.wr_col_addr_Q	(wr_col_addr_Q	)
);

rom_16x12 rom_16x12_A(
	.clk	(clk		),
	.rd		(rd_A		),
	.rd_addr(rd_addr_A	),
	.rd_data(rd_data_A	)
);


ram_16x12 ram_16x12_R(
	.clk	(clk		),
	.rst	(rst		),
	.wr		(wr_R		),
	.wr_addr(wr_addr_R	),
	.wr_data(wr_data_R	)
);

ram_16x12 ram_16x12_Q(
	.clk	(clk		),
	.rst	(rst		),
	.wr		(wr_Q		),
	.wr_addr(wr_addr_Q	),
	.wr_data(wr_data_Q	)
);

`ifdef SDF
	initial $sdf_annotate(`SDFFILE, qr_cordic_inst);
`endif


reg [9:0] cycle;

reg signed [OUT_WIDTH-1:0] Q_gold [0:15];
reg signed [OUT_WIDTH-1:0] R_gold [0:15];

initial begin
	$readmemb(`R_GOLD, R_gold);
	$readmemb(`Q_GOLD, Q_gold);		
end

assign rd_addr_A = 4 * rd_row_addr_A + rd_col_addr_A;
assign wr_addr_R = 4 * wr_row_addr_R + wr_col_addr_R;
assign wr_addr_Q = 4 * wr_row_addr_Q + wr_col_addr_Q;


always #(`CYCLE/2) clk = ~clk; 

//initial begin
//	$fsdbDumpfile("qr_cordic.fsdb");
//	$fsdbDumpvars;
//	$fsdbDumpMDA;
//end

// system control
initial begin
	@(negedge clk); #1; rst = 1'b1; en = 1'b0;
	#(`CYCLE*2); 	#1; 			en = 1'b1;
   	#(`CYCLE);   	#1; rst = 1'b0;
   	wait (finish == 1); 			en = 1'b0;
end


integer i = 0;
integer j = 0;
integer k = 0;
integer n = 0; 
integer m = 0;
integer l = 0;
integer u, v;
integer err_R, err_Q;

initial begin
	$display("-------------------------------------------------------\n");
 	$display("START!!! Simulation Start .....\n");
 	$display("-------------------------------------------------------\n");
	
	wait (finish == 1);
	// display matrix result 
	// display matrix A 
	$display("");
	$display("Original_Input A matrix: ");
    while(i<4) begin
		$display("%12d %12d %12d %12d", rom_16x12_A.rom[4*i]>>>3, rom_16x12_A.rom[4*i+1]>>>3, rom_16x12_A.rom[4*i+2]>>>3, rom_16x12_A.rom[4*i+3]>>>3);
		i = i + 1;
	end
	$display("Shifted_Input A matrix: ");
	while(n<4) begin
		$display("%12d %12d %12d %12d", rom_16x12_A.rom[4*n], rom_16x12_A.rom[4*n+1], rom_16x12_A.rom[4*n+2], rom_16x12_A.rom[4*n+3]);
		n = n + 1;
	end
	// display matrix R
	$display("");
	$display("Output R matrix golden pattern: ");
	while(k<4) begin
		$display("%12d %12d %12d %12d", R_gold[4*k], R_gold[4*k+1], R_gold[4*k+2], R_gold[4*k+3]);
		k = k + 1;
	end
	$display("R matrix calculated result: ");
	@(posedge clk);
	while(j<4) begin
		$display("%12d %12d %12d %12d", ram_16x12_R.ram[4*j], ram_16x12_R.ram[4*j+1], ram_16x12_R.ram[4*j+2], ram_16x12_R.ram[4*j+3]);
		j = j + 1;
	end
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
		$display("%12d %12d %12d %12d", ram_16x12_Q.ram[4*l], ram_16x12_Q.ram[4*l+1], ram_16x12_Q.ram[4*l+2], ram_16x12_Q.ram[4*l+3]);
		l = l + 1;
	end
	// check R matrix
	err_R = 0;
	for(u=0; u<R_len; u=u+1) begin
		if (ram_16x12_R.ram[u] != R_gold[u]) begin
			err_R = err_R + 1;
			$display("Data R[%2d] is wrong! The output data is %5d, but the expected data is %5d.", u, ram_16x12_R.ram[u], R_gold[u]);
		end
	end
	$display("");
	// check Q matrix
	err_Q = 0;
	for(v=0; v<Q_len; v=v+1) begin
		if (ram_16x12_Q.ram[v] != Q_gold[v]) begin
			err_Q = err_Q + 1;
			$display("Data Q[%2d] is wrong! The output data is %5d, but the expected data is %5d.", v, ram_16x12_Q.ram[v], Q_gold[v]);
		end
	end
	
	$display(" ");
	$display("--------------------- S U M M A R Y -------------------\n");
	if(err_R != 0) begin
		$display("*****************************************************************************");
		$display("** FAIL!!! There are %3d error in R matrix!                                **", err_R);
		$display("*****************************************************************************");
	end
	if(err_Q != 0) begin
		$display("*****************************************************************************");
		$display("** FAIL!!! There are %3d error in Q matrix!                                **", err_Q);
		$display("*****************************************************************************");
	end
	if(err_R == 0 && err_Q == 0) begin
		$display("*****************************************************************************");
		$display("** Congratulations!!! R and Q data are all correct! The result is PASS!!!  **");
		$display("** Get finish at cycle:%3d                                                 **", cycle);
		$display("*****************************************************************************");
	end
	
	#(`CYCLE); $stop;
end


always @(posedge clk) begin
	if (rst) begin
		cycle <= -1;
	end
	else if(finish) begin
		cycle <= cycle;
	end
	else begin
		cycle = cycle+1;
		if(cycle > `End_CYCLE) begin
			$display("********************************************************************");
			$display("**  Failed waiting Valid signal, Simulation STOP at cycle %d **",cycle);
			$display("**  If needed, You can increase End_CYCLE                         **");
			$display("********************************************************************");
			$finish;
		end
	end
end

endmodule


module rom_16x12 (
	input                    clk,
	input                    rd,
	input             [3:0]  rd_addr,
	output reg signed [11:0] rd_data
);

reg signed [11:0] rom [0:15];

initial begin
	$readmemb(`A_MEM, rom);
end

always @(negedge clk) begin
	if(rd) begin
		rd_data <= rom[rd_addr];
	end
end

endmodule


module ram_16x12 (
	input	              	clk,
	input 					rst,
	input	              	wr,
	input	       [3:0]  	wr_addr,
	input	signed [11:0] 	wr_data
);

reg signed [11:0] ram [0:15];

integer i;
always @(posedge clk) begin
	if(rst) begin
		for(i = 0; i < 16; i = i + 1) begin
			ram[i] <= 0;
		end
	end
	else if(wr) begin
		ram[wr_addr] <= wr_data;
	end
end

endmodule
