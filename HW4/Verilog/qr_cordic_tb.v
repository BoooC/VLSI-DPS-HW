`timescale 1ns/10ps
`define CYCLE      50.0
/*`define SDFFILE    "/home/univtrain/qr_cordic/qr_cordic_syn.sdf"*/
`define End_CYCLE  10000
  

`define A_MEM      "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/HW5/Verilog/input_A_matrix.txt"
`define R_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/HW5/Verilog/output_R_matrix_golden.txt"
`define Q_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/HW5/Verilog/output_Q_matrix_golden.txt"

module qr_cordic_tb;


reg signed [11:0] r_gold [0:15];
reg signed [11:0] Q_gold [0:15];
reg		rst = 0;
reg		clk = 0;
reg		en = 0;

wire wr;
wire wr_Q;
wire rd;
wire signed [11:0]	wr_data;
wire signed [11:0]	wr_data_Q;
wire signed [11:0]  rd_data;

wire [1:0]	rd_row_addr;
wire [1:0]	rd_col_addr;
wire [1:0]	wr_row_addr;
wire [1:0]	wr_col_addr;
wire [1:0]	wr_row_addr_Q;
wire [1:0]	wr_col_addr_Q;

wire [3:0] rd_addr;
wire [3:0] wr_addr;
wire [3:0] wr_addr_Q;

wire finish;

integer i = 0;
integer j = 0;
integer k = 0;
integer n = 0; 
integer m = 0;
integer l = 0;

integer err;

reg [9:0] cycle;

cordic cordic_inst(
	.clk(clk),
	.rst(rst),
	.en(en),
	.finish(finish),
	.rd(rd),
	.rd_data(rd_data),
	.rd_row_addr(rd_row_addr),
	.rd_col_addr(rd_col_addr),
	.wr(wr),
	.wr_data(wr_data),
	.wr_row_addr(wr_row_addr),
	.wr_col_addr(wr_col_addr),
	.wr_Q(wr_Q),
	.wr_data_Q(wr_data_Q),
	.wr_row_addr_Q(wr_row_addr_Q),
	.wr_col_addr_Q(wr_col_addr_Q)
);

rom_16x12 rom_16x12_inst(
	.clk(clk),
	.rd(rd),
	.rd_addr(rd_addr),
	.rd_data(rd_data)
);


ram_16x12 ram_16x12_inst(
	.clk(clk),
	.wr(wr),
	.wr_addr(wr_addr),
	.wr_data(wr_data)
);

ram_16x12 ram_16x12_Q(
	.clk(clk),
	.wr(wr_Q),
	.wr_addr(wr_addr_Q),
	.wr_data(wr_data_Q)
);

/*`ifdef SDF
	initial $sdf_annotate(`SDFFILE, qr_cordic_inst);
`endif
*/


assign rd_addr = 4*rd_row_addr+rd_col_addr;
assign wr_addr = 4*wr_row_addr+wr_col_addr;
assign wr_addr_Q = 4*wr_row_addr_Q+wr_col_addr_Q;

always begin #(`CYCLE/2) clk = ~clk; end

/*initial begin
	$fsdbDumpfile("qr_cordic.fsdb");
	$fsdbDumpvars;
	$fsdbDumpMDA;
end
*/
//-------------------------------------------------------------------------------------------------------------------
//expected result
initial begin
	wait(rst==1);
	$readmemb(`R_GOLD, r_gold);
	$readmemb(`Q_GOLD, Q_gold);		
end

//global control
initial begin
	$display("-------------------------------------------------------\n");
 	$display("START!!! Simulation Start .....\n");
 	$display("-------------------------------------------------------\n");
	@(negedge clk); #1; rst = 1'b1; en = 1'b0;
	$display("Original_Input A matrix: ");
    while(i<4) begin
		$display("%12d %12d %12d %12d", rom_16x12_inst.rom[4*i]>>>3, rom_16x12_inst.rom[4*i+1]>>>3, rom_16x12_inst.rom[4*i+2]>>>3, rom_16x12_inst.rom[4*i+3]>>>3);
		i = i + 1;
	end
	$display("Shifted_Input A matrix: ");
	while(n<4) begin
		$display("%12d %12d %12d %12d", rom_16x12_inst.rom[4*n], rom_16x12_inst.rom[4*n+1], rom_16x12_inst.rom[4*n+2], rom_16x12_inst.rom[4*n+3]);
		n = n + 1;
	end
	#(`CYCLE*2); #1; en = 1'b1;
   	#(`CYCLE);   #1; rst = 1'b0;
   	wait (finish == 1); en = 1'b0;
end



//-------------------------------------------------------------------------------------------------------------------
//Calculate number of cycles needed
always @(posedge clk) begin
	if (rst) begin
		cycle <= -1;
	end
	else if(finish) begin
		cycle <= cycle;
	end
	else begin
		cycle <= cycle + 1;
	end
end

//-------------------------------------------------------------------------------------------------------------------
initial begin
	wait (finish == 1);
	$display("Output R matrix golden pattern: ");
	while(k<4) begin
		$display("%12d %12d %12d %12d", r_gold[4*k], r_gold[4*k+1], r_gold[4*k+2], r_gold[4*k+3]);
		k = k + 1;
	end
	$display("");
	$display("R matrix calculated result: ");
	@(posedge clk);
	while(j<4) begin
		$display("%12d %12d %12d %12d", ram_16x12_inst.ram[4*j], ram_16x12_inst.ram[4*j+1], ram_16x12_inst.ram[4*j+2], ram_16x12_inst.ram[4*j+3]);
		j = j + 1;
	end
	$display("Output Q matrix golden pattern: ");
	while(m<4) begin
		$display("%12d %12d %12d %12d", Q_gold[4*m], Q_gold[4*m+1], Q_gold[4*m+2], Q_gold[4*m+3]);
		m = m + 1;
	end
	$display("");
	$display("Q matrix calculated result: ");
	@(posedge clk);
	while(l<4) begin
		$display("%12d %12d %12d %12d", ram_16x12_Q.ram[4*l], ram_16x12_Q.ram[4*l+1], ram_16x12_Q.ram[4*l+2], ram_16x12_Q.ram[4*l+3]);
		l = l + 1;
	end
	err = 0;
	if (ram_16x12_inst.ram[0] != r_gold[0]) begin
		err = err + 1;
		$display("Data r11 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[0], r_gold[0]);
	end
	if (ram_16x12_inst.ram[1] != r_gold[1]) begin
		err = err + 1;
		$display("Data r12 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[1], r_gold[1]);
	end
	if (ram_16x12_inst.ram[2] != r_gold[2]) begin
		err = err + 1;
		$display("Data r13 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[2], r_gold[2]);
	end
	if (ram_16x12_inst.ram[3] != r_gold[3]) begin
		err = err + 1;
		$display("Data r14 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[3], r_gold[3]);
	end
	if (ram_16x12_inst.ram[5] != r_gold[5]) begin
		err = err + 1;
		$display("Data r22 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[5], r_gold[5]);
	end
	if (ram_16x12_inst.ram[6] != r_gold[6]) begin
		err = err + 1;
		$display("Data r23 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[6], r_gold[6]);
	end
	if (ram_16x12_inst.ram[7] != r_gold[7]) begin
		err = err + 1;
		$display("Data r24 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[7], r_gold[7]);
	end
	if (ram_16x12_inst.ram[10] != r_gold[10]) begin
		err = err + 1;
		$display("Data r33 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[10], r_gold[10]);
	end
	if (ram_16x12_inst.ram[11] != r_gold[11]) begin
		err = err + 1;
		$display("Data r34 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[11], r_gold[11]);
	end
	if (ram_16x12_inst.ram[15] != r_gold[15]) begin
		err = err + 1;
		$display("Data r44 is wrong! The output data is %12d, but the expected data is %12d.", ram_16x12_inst.ram[15], r_gold[15]);
	end
	$display(" ");
	$display("-------------------------------------------------------\n");
	$display("--------------------- S U M M A R Y -------------------\n");

	if (err ==0) begin
		$display("*****************************************************************************");
		$display("** Congratulations!!! R and Q data are all correct! The result is PASS!!! **");
		$display("** Get finish at cycle:%4d                                                 **", cycle);
		$display("*****************************************************************************");
	end
	else begin
		$display("*****************************************************************************");
		$display("** FAIL!!! There are %4d error in R matrix!                               **", err);
		$display("*****************************************************************************");
	end
	$finish;
end


//-------------------------------------------------------------------------------------------------------------------
initial  begin
#`End_CYCLE;
 	$display("*****************************************************************************");
 	$display("**   Error!!! The simulation can't be terminated under normal operation!   **");
 	$display("**                                  FAIL!                                  **");
 	$display("*****************************************************************************");
 	$finish;
end


   
endmodule

module rom_16x12 (
	input                    clk,
	input                    rd,
	input             [ 3:0] rd_addr,
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
	input                    clk,
	input                    wr,
	input             [ 3:0] wr_addr,
	input      signed [11:0] wr_data
);


reg signed [11:0] ram [0:15];

integer i;

initial begin
	for(i = 0; i < 16; i = i + 1) begin
		ram[i] <= 0;
	end
end

always @(posedge clk) begin
	if(wr) begin
		ram[wr_addr] <= wr_data;
	end
end


endmodule
