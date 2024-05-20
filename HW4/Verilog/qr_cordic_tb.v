`timescale 1ns/10ps
`define CYCLE      50.0
`define SDFFILE    "/home/univtrain/qr_cord_Aic/qr_cord_Aic_syn.sdf"
`define End_CYCLE  10000
    

`define A_MEM      "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/input_A_matrix.txt"
`define R_GOLD     "C:/Users/p8101/Desktop/school/Univ/senior(II)/VLSIDSP/2024/HW/HW4/Verilog/output_R_matrix_golden.txt"


module qr_cordic_tb;


reg signed [12:0] r_gold [0:31];

reg		rst = 0;
reg		clk = 0;
reg		en = 0;

wire wr_R;
wire rd_A;
wire signed [12:0]	wr_R_data;
wire signed [12:0]  rd_A_data;

wire [2:0]	rd_A_row_addr;
wire [1:0]	rd_A_col_addr;
wire [2:0]	wr_R_row_addr;
wire [1:0]	wr_R_col_addr;

wire [4:0] rd_A_addr;
wire [4:0] wr_R_addr;

wire valid;

integer i = 0;
integer j = 0;
integer k = 0;

integer err;

reg [9:0] cycle;

qr_cord_Aic qr_cord_Aic_inst(
	.clk(clk),
	.rst(rst),
	.en(en),
	.rd_A(rd_A),
	.rd_A_data(rd_A_data),
	.rd_A_row_addr(rd_A_row_addr),
	.rd_A_col_addr(rd_A_col_addr),
	.wr_R(wr_R),
	.wr_R_data(wr_R_data),
	.wr_R_row_addr(wr_R_row_addr),
	.wr_R_col_addr(wr_R_col_addr),
	.valid(valid)
);

rom_32x13 rom_32x13_inst(
	.clk(clk),
	.rd_A(rd_A),
	.rd_A_addr(rd_A_addr),
	.rd_A_data(rd_A_data)
);


ram_32x13 ram_32x13_inst(
	.clk(clk),
	.wr_R(wr_R),
	.wr_R_addr(wr_R_addr),
	.wr_R_data(wr_R_data)
);

`ifdef SDF
	initial $sdf_annotate(`SDFFILE, qr_cord_Aic_inst);
`endif



assign rd_A_addr = 4*rd_A_row_addr+rd_A_col_addr;
assign wr_R_addr = 4*wr_R_row_addr+wr_R_col_addr;


always begin #(`CYCLE/2) clk = ~clk; end

// initial begin
// 	$fsdbDumpfile("qr_cord_Aic.fsdb");
// 	$fsdbDumpvars;
// 	$fsdbDumpMDA;
// end

//-------------------------------------------------------------------------------------------------------------------
//expected result
initial begin
	wait(rst==1);
	$readmemb(`R_GOLD, r_gold);	
end

//global control
initial begin
	$display("-------------------------------------------------------\n");
 	$display("START!!! Simulation Start .....\n");
 	$display("-------------------------------------------------------\n");
	@(negedge clk); #1; rst = 1'b1; en = 1'b0;
	$display("Input A matrix: ");
	while(i<8) begin
		$display("%13d %13d %13d %13d", rom_32x13_inst.rom[4*i], rom_32x13_inst.rom[4*i+1], rom_32x13_inst.rom[4*i+2], rom_32x13_inst.rom[4*i+3]);
		i = i + 1;
	end
	#(`CYCLE*2); #1; en = 1'b1;
   	#(`CYCLE);   #1; rst = 1'b0;
   	wait (valid == 1); en = 1'b0;
end



//-------------------------------------------------------------------------------------------------------------------
//Calculate number of cycles needed
always @(posedge clk) begin
	if (rst) begin
		cycle <= -1;
	end
	else if(valid) begin
		cycle <= cycle;
	end
	else begin
		cycle <= cycle + 1;
	end
end

//-------------------------------------------------------------------------------------------------------------------
initial begin
	wait (valid == 1);
	$display("Output R matrix golden pattern: ");
	while(k<8) begin
		$display("%13d %13d %13d %13d", r_gold[4*k], r_gold[4*k+1], r_gold[4*k+2], r_gold[4*k+3]);
		k = k + 1;
	end
	$display("");
	$display("R matrix calculated result: ");
	@(posedge clk);
	while(j<8) begin
		$display("%13d %13d %13d %13d", ram_32x13_inst.ram[4*j], ram_32x13_inst.ram[4*j+1], ram_32x13_inst.ram[4*j+2], ram_32x13_inst.ram[4*j+3]);
		j = j + 1;
	end
	err = 0;
	if (ram_32x13_inst.ram[0] != r_gold[0]) begin
		err = err + 1;
		$display("Data r11 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[0], r_gold[0]);
	end
	if (ram_32x13_inst.ram[1] != r_gold[1]) begin
		err = err + 1;
		$display("Data r12 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[1], r_gold[1]);
	end
	if (ram_32x13_inst.ram[2] != r_gold[2]) begin
		err = err + 1;
		$display("Data r13 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[2], r_gold[2]);
	end
	if (ram_32x13_inst.ram[3] != r_gold[3]) begin
		err = err + 1;
		$display("Data r14 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[3], r_gold[3]);
	end
	if (ram_32x13_inst.ram[5] != r_gold[5]) begin
		err = err + 1;
		$display("Data r22 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[5], r_gold[5]);
	end
	if (ram_32x13_inst.ram[6] != r_gold[6]) begin
		err = err + 1;
		$display("Data r23 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[6], r_gold[6]);
	end
	if (ram_32x13_inst.ram[7] != r_gold[7]) begin
		err = err + 1;
		$display("Data r24 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[7], r_gold[7]);
	end
	if (ram_32x13_inst.ram[10] != r_gold[10]) begin
		err = err + 1;
		$display("Data r33 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[10], r_gold[10]);
	end
	if (ram_32x13_inst.ram[11] != r_gold[11]) begin
		err = err + 1;
		$display("Data r34 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[11], r_gold[11]);
	end
	if (ram_32x13_inst.ram[15] != r_gold[15]) begin
		err = err + 1;
		$display("Data r44 is wr_Rong! The output data is %13d, but the expected data is %13d.", ram_32x13_inst.ram[15], r_gold[15]);
	end
	$display(" ");
	$display("-------------------------------------------------------\n");
	$display("--------------------- S U M M A R Y -------------------\n");

	if (err ==0) begin
		$display("*****************************************************************************");
		$display("** Congratulations!!! R matrix data are all correct! The result is PASS!!! **");
		$display("** Get valid at cycle:%4d                                                 **", cycle);
		$display("*****************************************************************************");
	end
	else begin
		$display("*****************************************************************************");
		$display("** FAIL!!! There are %4d error in R matrix!                               **", err);
		$display("*****************************************************************************");
	end
	$stop;
end


//-------------------------------------------------------------------------------------------------------------------
initial  begin
#`End_CYCLE;
 	$display("*****************************************************************************");
 	$display("**   Error!!! The simulation can't be terminated under normal operation!   **");
 	$display("**                                  FAIL!                                  **");
 	$display("*****************************************************************************");
 	$stop;
end


   
endmodule

module rom_32x13 (
	input                    clk,
	input                    rd_A,
	input             [ 4:0] rd_A_addr,
	output reg signed [12:0] rd_A_data
);


reg signed [12:0] rom [0:31];

initial begin
	$readmemb(`A_MEM, rom);
end

always @(negedge clk) begin
	if(rd_A) begin
		rd_A_data <= rom[rd_A_addr];
	end
end

endmodule

module ram_32x13 (
	input                    clk,
	input                    wr_R,
	input             [ 4:0] wr_R_addr,
	input      signed [12:0] wr_R_data
);


reg signed [12:0] ram [0:31];

integer i;

initial begin
	for(i = 0; i < 32; i = i + 1) begin
		ram[i] <= 0;
	end
end

always @(posedge clk) begin
	if(wr_R) begin
		ram[wr_R_addr] <= wr_R_data;
	end
end


endmodule
