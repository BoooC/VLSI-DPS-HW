module qr_cordic #(
	parameter R_LEN     = 12,
	parameter R_FRAC    = 2,
	parameter K_LEN     = 10,
	parameter K_FRAC    = 9,
	parameter ROW_LEN   = 3,
	parameter COL_LEN   = 2,
	parameter ITER_NUM  = 8,
	parameter MICRO_NUM = 2,
	parameter ITER_LEN  = 4
)
(	input                                   clk,
	input                                   rst,
	input                                   en,
	
	output                                  rd_A,
	input      signed    [R_LEN-1:0]        rd_A_data,
	output reg           [ROW_LEN-1:0]      rd_A_row_addr,
	output reg           [COL_LEN-1:0]      rd_A_col_addr,
	
	output reg                              wr_R,
	output reg signed    [R_LEN-1:0]        wr_R_data,
	output reg           [ROW_LEN-1:0]      wr_R_row_addr,
	output reg           [COL_LEN-1:0]      wr_R_col_addr,
	
	output reg                              valid
);

parameter ITER 				= 12;
parameter ITER_K			= ITER + 1;
parameter ITER_ONE_CYCLE 	= 4;

localparam IDLE		= 0;
localparam ROT		= 1; // GG1 CORDIC scheme: execute 4 micro-rotations
localparam MUL_K	= 2; // GG1 CORDIC scheme: execute scalar K multiplication
localparam DONE		= 3;


reg                   [3:0]                state;
reg                   [3:0]                next_state;

reg                   [2:0]                mk_cnt_gg1;
reg                   [2:0]                mk_cnt_gr11;
reg                   [2:0]                mk_cnt_gr12;
reg                   [2:0]                mk_cnt_gr13;
reg                   [2:0]                mk_cnt_gg2;
reg                   [2:0]                mk_cnt_gr21;
reg                   [2:0]                mk_cnt_gr22;
reg                   [2:0]                mk_cnt_gg3;
reg                   [2:0]                mk_cnt_gr31;
reg                   [2:0]                mk_cnt_gg4;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                              signals of other modules                                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//GG1
reg            signed 	[R_LEN-1:0]         xi_gg1;
reg            signed 	[R_LEN-1:0]         yi_gg1;
reg                   	[ITER_LEN-1:0]      iter_gg1;
wire                  	[1:0]               d1_gg1;
wire                  	[1:0]				d2_gg1;
wire                  	[1:0]				d3_gg1;
wire                  	[1:0]				d4_gg1;
wire                  	                    neg_gg1;
wire           signed 	[R_LEN-1:0]         xo_gg1;
wire           signed 	[R_LEN-1:0]         yo_gg1;

//GR11
reg                                         nop_gr11;
reg            signed	[R_LEN-1:0]         xi_gr11;
reg            signed	[R_LEN-1:0]         yi_gr11;
reg                  	[ITER_LEN-1:0]      iter_gr11;
reg                  	[1:0]               d1_gr11;
reg                  	[1:0]				d2_gr11;
reg                  	[1:0]				d3_gr11;
reg                  	[1:0]				d4_gr11;
reg                                         neg_gr11;
wire           signed 	[R_LEN-1:0]         xo_gr11;
wire           signed 	[R_LEN-1:0]         yo_gr11;

//GR12
reg                                         nop_gr12;
reg            signed	[R_LEN-1:0]         xi_gr12;
reg            signed	[R_LEN-1:0]         yi_gr12;
reg                  	[ITER_LEN-1:0]      iter_gr12;
reg                  	[1:0]               d1_gr12;
reg                  	[1:0]				d2_gr12;
reg                  	[1:0]				d3_gr12;
reg                  	[1:0]				d4_gr12;
reg                                         neg_gr12;
wire           signed 	[R_LEN-1:0]         xo_gr12;
wire           signed 	[R_LEN-1:0]         yo_gr12;

//GR13
reg                                         nop_gr13;
reg            signed	[R_LEN-1:0]         xi_gr13;
reg            signed	[R_LEN-1:0]         yi_gr13;
reg                  	[ITER_LEN-1:0]      iter_gr13;
reg                  	[1:0]               d1_gr13;
reg                  	[1:0]				d2_gr13;
reg                  	[1:0]				d3_gr13;
reg                  	[1:0]				d4_gr13;
reg                                         neg_gr13;
wire           signed 	[R_LEN-1:0]         xo_gr13;
wire           signed 	[R_LEN-1:0]         yo_gr13;

//GG2
reg            signed 	[R_LEN-1:0]         xi_gg2;
reg            signed 	[R_LEN-1:0]         yi_gg2;
reg                   	[ITER_LEN-1:0]      iter_gg2;
wire                  	[1:0]               d1_gg2;
wire                  	[1:0]				d2_gg2;
wire                  	[1:0]				d3_gg2;
wire                  	[1:0]				d4_gg2;
wire                  	                    neg_gg2;
wire           signed 	[R_LEN-1:0]         xo_gg2;
wire           signed 	[R_LEN-1:0]         yo_gg2;

//GR21
reg                                         nop_gr21;
reg            signed	[R_LEN-1:0]         xi_gr21;
reg            signed	[R_LEN-1:0]         yi_gr21;
reg                  	[ITER_LEN-1:0]      iter_gr21;
reg                  	[1:0]               d1_gr21;
reg                  	[1:0]				d2_gr21;
reg                  	[1:0]				d3_gr21;
reg                  	[1:0]				d4_gr21;
reg                                         neg_gr21;
wire           signed 	[R_LEN-1:0]         xo_gr21;
wire           signed 	[R_LEN-1:0]         yo_gr21;

//GR22
reg                                         nop_gr22;
reg            signed 	[R_LEN-1:0]         xi_gr22;
reg            signed 	[R_LEN-1:0]         yi_gr22;
reg                   	[ITER_LEN-1:0]      iter_gr22;
reg                   	[1:0]               d1_gr22;
reg                   	[1:0]				d2_gr22;
reg                  	[1:0]				d3_gr22;
reg                  	[1:0]				d4_gr22;
reg                   	                    neg_gr22;
wire           signed 	[R_LEN-1:0]         xo_gr22;
wire           signed 	[R_LEN-1:0]         yo_gr22;

//GG3
reg            signed 	[R_LEN-1:0]         xi_gg3;
reg            signed 	[R_LEN-1:0]         yi_gg3;
reg                   	[ITER_LEN-1:0]      iter_gg3;
wire                  	[1:0]               d1_gg3;
wire                  	[1:0]				d2_gg3;
wire                  	[1:0]				d3_gg3;
wire                  	[1:0]				d4_gg3;
wire                  	                    neg_gg3;
wire           signed 	[R_LEN-1:0]         xo_gg3;
wire           signed 	[R_LEN-1:0]         yo_gg3;

//GR31
reg                                         nop_gr31;
reg            signed 	[R_LEN-1:0]         xi_gr31;
reg            signed 	[R_LEN-1:0]         yi_gr31;
reg                   	[ITER_LEN-1:0]      iter_gr31;
reg                   	[1:0]               d1_gr31;
reg                   	[1:0]				d2_gr31;
reg                  	[1:0]				d3_gr31;
reg                  	[1:0]				d4_gr31;
reg                   	                    neg_gr31;
wire           signed 	[R_LEN-1:0]         xo_gr31;
wire           signed 	[R_LEN-1:0]         yo_gr31;

//GG4
reg            signed 	[R_LEN-1:0]         xi_gg4;
reg            signed 	[R_LEN-1:0]         yi_gg4;
reg                   	[ITER_LEN-1:0]      iter_gg4;
wire                  	[1:0]               d1_gg4;
wire                  	[1:0]				d2_gg4;
wire                  	[1:0]				d3_gg4;
wire                  	[1:0]				d4_gg4;
wire                  	                    neg_gg4;
wire           signed 	[R_LEN-1:0]         xo_gg4;
wire           signed 	[R_LEN-1:0]         yo_gg4;

// MK1
reg            signed	[R_LEN-1:0]         xi_mk1;
reg            signed	[R_LEN-1:0]         yi_mk1;
wire           signed	[R_LEN-1:0]         xo_mk1;
wire           signed	[R_LEN-1:0]         yo_mk1;
	
// MK2	
reg            signed	[R_LEN-1:0]         xi_mk2;
reg            signed	[R_LEN-1:0]         yi_mk2;
wire           signed	[R_LEN-1:0]         xo_mk2;
wire           signed	[R_LEN-1:0]         yo_mk2;
	
// MK3	
reg            signed	[R_LEN-1:0]         xi_mk3;
reg            signed	[R_LEN-1:0]         yi_mk3;
wire           signed	[R_LEN-1:0]         xo_mk3;
wire           signed	[R_LEN-1:0]         yo_mk3;
	
// MK4	
reg            signed	[R_LEN-1:0]         xi_mk4;
reg            signed	[R_LEN-1:0]         yi_mk4;
wire           signed	[R_LEN-1:0]         xo_mk4;
wire           signed	[R_LEN-1:0]         yo_mk4;


// state wire
wire IDLE_wire 	= state == IDLE;      
wire ROT_wire 	= state == ROT;
wire MUL_K_wire = state == MUL_K;  
wire DONE_wire 	= state == DONE;
wire OP_wire 	= ROT_wire | MUL_K_wire;

//control signals
wire read_store 	= rd_A_row_addr == 7 || (rd_A_row_addr == 6 && rd_A_col_addr == 0);
wire rd_A_col_end 	= rd_A_col_addr == 3;
wire rd_A_end		= rd_A_row_addr == 0 && rd_A_col_end && mk_cnt_gg1 >= 6;

wire start_gg1		= rd_A_row_addr == 7 && rd_A_col_addr == 0;
wire start_gr11 	= rd_A_row_addr == 7 && rd_A_col_addr == 1;
wire start_gr12 	= rd_A_row_addr == 7 && rd_A_col_addr == 2;
wire start_gr13 	= rd_A_row_addr == 7 && rd_A_col_addr == 3;
wire start_gg2  	= rd_A_row_addr == 5 && rd_A_col_addr == 1;
wire start_gr21 	= rd_A_row_addr == 5 && rd_A_col_addr == 2;
wire start_gr22 	= rd_A_row_addr == 5 && rd_A_col_addr == 3;
wire start_gg3  	= rd_A_row_addr == 3 && rd_A_col_addr == 2;
wire start_gr31 	= rd_A_row_addr == 3 && rd_A_col_addr == 3;
wire start_gg4  	= rd_A_row_addr == 1 && rd_A_col_addr == 3;

wire iter_last_gg1  = iter_gg1  == ITER;	// 12
wire iter_last_gr11 = iter_gr11 == ITER;
wire iter_last_gr12 = iter_gr12 == ITER;
wire iter_last_gr13 = iter_gr13 == ITER;
wire iter_last_gg2  = iter_gg2  == ITER;
wire iter_last_gr21 = iter_gr21 == ITER;
wire iter_last_gr22 = iter_gr22 == ITER;
wire iter_last_gg3  = iter_gg3  == ITER;
wire iter_last_gr31 = iter_gr31 == ITER;
wire iter_last_gg4	= iter_gg4  == ITER;

wire multk_gg1		= iter_gg1  == ITER_K;
wire multk_gr11 	= iter_gr11 == ITER_K;
wire multk_gr12 	= iter_gr12 == ITER_K;
wire multk_gr13 	= iter_gr13 == ITER_K;
wire multk_gg2  	= iter_gg2  == ITER_K;
wire multk_gr21 	= iter_gr21 == ITER_K;
wire multk_gr22 	= iter_gr22 == ITER_K;
wire multk_gg3  	= iter_gg3  == ITER_K;
wire multk_gr31 	= iter_gr31 == ITER_K;
wire multk_gg4  	= iter_gg4  == ITER_K;

wire multk_gg1_last	= mk_cnt_gg1  == 6 && multk_gg1;
wire multk_gr11_last= mk_cnt_gr11 == 6 && multk_gr11;
wire multk_gr12_last= mk_cnt_gr12 == 6 && multk_gr12;
wire multk_gr13_last= mk_cnt_gr13 == 6 && multk_gr13;
wire multk_gg2_last = mk_cnt_gg2  == 5 && multk_gg2;
wire multk_gr21_last= mk_cnt_gr21 == 5 && multk_gr21;
wire multk_gr22_last= mk_cnt_gr22 == 5 && multk_gr22;
wire multk_gg3_last = mk_cnt_gg3  == 4 && multk_gg3;
wire multk_gr31_last= mk_cnt_gr31 == 4 && multk_gr31;
wire multk_gg4_last = mk_cnt_gg4  == 3 && multk_gg4;

wire wr_R_r13 		= mk_cnt_gg4 == 3 && iter_gg4 == 0;
wire wr_R_r34 		= mk_cnt_gg4 == 4 && iter_gg4 == 0;
wire wr_R_r24 		= mk_cnt_gg4 == 4 && iter_gg4 == 1;
wire wr_R_r14 		= mk_cnt_gg4 == 4 && iter_gg4 == 2;

wire finish_gg1		= multk_gg1_last  || (mk_cnt_gg1  == 7 && iter_gg1  == 0);
wire finish_gr11	= multk_gr11_last || (mk_cnt_gr11 == 7 && iter_gr11 == 0);
wire finish_gr12	= multk_gr12_last || (mk_cnt_gr12 == 7 && iter_gr12 == 0);
wire finish_gr13	= multk_gr13_last || (mk_cnt_gr13 == 7 && iter_gr13 == 0);
wire finish_gg2 	= multk_gg2_last  || (mk_cnt_gg2  == 6 && iter_gg2  == 0);
wire finish_gr21	= multk_gr21_last || (mk_cnt_gr21 == 6 && iter_gr21 == 0);
wire finish_gr22	= multk_gr22_last || (mk_cnt_gr22 == 6 && iter_gr22 == 0);
wire finish_gg3 	= multk_gg3_last  || (mk_cnt_gg3  == 5 && iter_gg3  == 0);
wire finish_gr31	= multk_gr31_last || (mk_cnt_gr31 == 5 && iter_gr31 == 0);
wire finish_gg4 	= multk_gg4_last  || (mk_cnt_gg4  == 4 && iter_gg4  <= 3);

wire nop_gg1 		= (~OP_wire) | read_store | finish_gg1;
wire nop_gg2 		= (~OP_wire) | mk_cnt_gr11 <= 1 | finish_gg2 | multk_gg2;
wire nop_gg3 		= (~OP_wire) | mk_cnt_gr21 <= 1 | finish_gg3 | multk_gg3;
wire nop_gg4 		= (~OP_wire) | mk_cnt_gr31 <= 1 | finish_gg4 | multk_gg4;

wire qr_finish		= mk_cnt_gg4 == 4 && iter_gg4 == 2;


assign rd_A = (!rst) && en && (~iter_last_gg1);


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                       main code                                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//next state logic
always @(*) begin
	case(state)
		IDLE 	: next_state = en ? ROT : IDLE;
		ROT 	: next_state = qr_finish ? DONE : iter_last_gg1 ? MUL_K : ROT;
		MUL_K	: next_state = ROT;
		DONE	: next_state = IDLE;
		default	: next_state = IDLE;
	endcase
end

//state register
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state <= IDLE;
	end
	else begin
		state <= next_state;
	end
end


// rd_A_row_addr, rd_A_col_addr
always @(posedge clk or posedge rst) begin
	if (rst) begin
		rd_A_row_addr <= 0;
		rd_A_col_addr <= 3;
	end
	else if(rd_A & ~rd_A_end) begin
		if(rd_A_col_end) begin
			rd_A_row_addr <= rd_A_row_addr - 1;
			rd_A_col_addr <= 0;
		end
		else begin
			rd_A_row_addr <= rd_A_row_addr;
			rd_A_col_addr <= rd_A_col_addr + 1;
		end
	end
end

// wr_R_row_addr, wr_R_col_addr
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_R_row_addr <= 0;
		wr_R_col_addr <= 0;
	end
	else if(ROT_wire) begin
		if(multk_gg2_last || multk_gg3_last || multk_gg4_last) begin
			wr_R_row_addr = wr_R_col_addr + 1;
			wr_R_col_addr = wr_R_col_addr + 1;
		end
		else if(wr_R_row_addr != 0) begin
			wr_R_row_addr = wr_R_row_addr - 1;
			wr_R_col_addr = wr_R_col_addr;
		end
	end
	else begin
		wr_R_row_addr <= 0;
		wr_R_col_addr <= 0;
	end
end


//wr_R_data, wr_R
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_R_data <= 0;
	end
	else if(OP_wire) begin
		case(1)
			multk_gg1_last 	: wr_R_data <= xo_mk1;
			multk_gg2_last 	: wr_R_data <= xo_mk2;
			multk_gg3_last 	: wr_R_data <= xo_mk3;
			multk_gg4_last 	: wr_R_data <= xo_mk4;
			multk_gr21_last : wr_R_data <= xo_gg2;
			multk_gr31_last : wr_R_data <= xo_gg3;
			wr_R_r13 		: wr_R_data <= yo_gg3;
			wr_R_r34 		: wr_R_data <= xo_gg4;
			wr_R_r24 		: wr_R_data <= yo_gg4;
			wr_R_r14 		: wr_R_data <= yo_gg4;
			default 		: wr_R_data <= 0;
		endcase
	end
	else begin
		wr_R_data <= 0;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_R <= 0;
	end
	else if(OP_wire) begin
		wr_R <= multk_gg1_last | multk_gg2_last | multk_gg3_last | multk_gg4_last | multk_gr21_last | multk_gr31_last | wr_R_r13 | wr_R_r34 | wr_R_r24 | wr_R_r14;
	end
	else begin
		wr_R <= 0;
	end
end


// valid
always @(posedge clk or posedge rst) begin
	if (rst) begin
		valid <= 0;
	end
	else if(DONE_wire) begin
		valid <= 1;
	end
end



/*****************************************************************/
/**                              GG1                            **/
/*****************************************************************/
//GG1 current iteration number
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gg1 <= 0;
	end
	else if(ROT_wire) begin
		if(nop_gg1) begin
			iter_gg1 <= 0;
		end
		else if(iter_last_gg1) begin
			iter_gg1 <= iter_gg1 + 1;
		end
		else begin
			iter_gg1 <= iter_gg1 + ITER_ONE_CYCLE;
		end
	end
	else begin
		iter_gg1 <= 0;
	end
end

//GG1 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg1 <= 0;
		yi_gg1 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gg1)
			0: begin
				if(start_gg1) begin
					xi_gg1 <= 0;
					yi_gg1 <= rd_A_data;
				end
				else if(nop_gg1 && !finish_gg1) begin
					xi_gg1 <= rd_A_data;
					yi_gg1 <= yo_gg1;
				end
				else begin
					xi_gg1 <= xo_gg1;
					yi_gg1 <= yo_gg1;
				end
			end
			ITER_K: begin
				if(finish_gg1) begin
					xi_gg1 <= xo_gg1;
					yi_gg1 <= yo_gg1;
				end
				else begin
					xi_gg1 <= rd_A_data;
					yi_gg1 <= xo_mk1;
				end
			end
			default: begin
				xi_gg1 <= xo_gg1;
				yi_gg1 <= yo_gg1;
			end
		endcase
	end
	else begin
		xi_gg1 <= 0;
		yi_gg1 <= 0;
	end
end

//GG1 mk_cnt
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gg1 <= 0;
	end
	else if(MUL_K_wire) begin
		mk_cnt_gg1 <= mk_cnt_gg1 + 1;
	end
end


/*****************************************************************/
/**                              GR11                           **/
/*****************************************************************/
//GR11 current iteration number
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr11 	<= 0;	
		nop_gr11 	<= 0;
		d1_gr11 	<= 0;
		d2_gr11 	<= 0;
		d3_gr11 	<= 0;
		d4_gr11 	<= 0;
		neg_gr11 	<= 0;
		mk_cnt_gr11 <= 0;
	end
	else begin
		iter_gr11 	<= iter_gg1;
		nop_gr11 	<= nop_gg1;
		d1_gr11 	<= d1_gg1;
		d2_gr11 	<= d2_gg1;
		d3_gr11 	<= d3_gg1;
		d4_gr11 	<= d4_gg1;
		neg_gr11 	<= neg_gg1;
		mk_cnt_gr11 <= mk_cnt_gg1;
	end
end

//GR11 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr11 <= 0;
		yi_gr11 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gr11)
			0: begin
				if(start_gr11) begin
					xi_gr11 <= 0;
					yi_gr11 <= rd_A_data;
				end
				else if(nop_gr11 && !finish_gr11) begin
					xi_gr11 <= rd_A_data;
					yi_gr11 <= yo_gr11;
				end
				else begin
					xi_gr11 <= xo_gr11;
					yi_gr11 <= yo_gr11;
				end
			end
			ITER_K: begin
				if(finish_gr11) begin
					xi_gr11 <= xo_mk1; //propagate r12 to GG2 after 5 nop cycles
					yi_gr11 <= yo_mk1;
				end
				else begin
					xi_gr11 <= rd_A_data;
					yi_gr11 <= xo_mk1;
				end
			end
			default: begin
				xi_gr11 <= xo_gr11;
				yi_gr11 <= yo_gr11;
			end
		endcase
	end
	else begin
		xi_gr11 <= 0;
		xi_gr11 <= 0;
	end
end


/*****************************************************************/
/**                              GR12                           **/
/*****************************************************************/
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr12 	<= 0;	
		nop_gr12 	<= 0;
		d1_gr12 	<= 0;
		d2_gr12 	<= 0;
		d3_gr12 	<= 0;
		d4_gr12 	<= 0;
		neg_gr12 	<= 0;
		mk_cnt_gr12 <= 0;
	end
	else begin
		iter_gr12 	<= iter_gr11;
		nop_gr12 	<= nop_gr11;
		d1_gr12 	<= d1_gr11;
		d2_gr12 	<= d2_gr11;
		d3_gr12 	<= d3_gr11;
		d4_gr12 	<= d4_gr11;
		neg_gr12 	<= neg_gr11;
		mk_cnt_gr12 <= mk_cnt_gr11;
	end
end

//GR11 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr12 <= 0;
		yi_gr12 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gr12)
			0: begin
				if(start_gr12) begin
					xi_gr12 <= 0;
					yi_gr12 <= rd_A_data;
				end
				else if(nop_gr12 && !finish_gr12) begin
					xi_gr12 <= rd_A_data;
					yi_gr12 <= yo_gr12;
				end
				else begin
					xi_gr12 <= xo_gr12;
					yi_gr12 <= yo_gr12;
				end
			end
			ITER_K: begin
				if(finish_gr12) begin
					xi_gr12 <= xo_mk1; //propagate r13 to GG2 after 5 nop cycles
					yi_gr12 <= yo_mk1;
				end
				else begin
					xi_gr12 <= rd_A_data;
					yi_gr12 <= xo_mk1;
				end
			end
			default: begin
				xi_gr12 <= xo_gr12;
				yi_gr12 <= yo_gr12;
			end
		endcase
	end
	else begin
		xi_gr12 <= 0;
		xi_gr12 <= 0;
	end
end


/*****************************************************************/
/**                              GR13                           **/
/*****************************************************************/
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr13 	<= 0;	
		nop_gr13 	<= 0;
		d1_gr13 	<= 0;
		d2_gr13 	<= 0;
		d3_gr13 	<= 0;
		d4_gr13 	<= 0;
		neg_gr13 	<= 0;
		mk_cnt_gr13 <= 0;
	end
	else begin
		iter_gr13 	<= iter_gr12;
		nop_gr13 	<= nop_gr12;
		d1_gr13 	<= d1_gr12;
		d2_gr13 	<= d2_gr12;
		d3_gr13 	<= d3_gr12;
		d4_gr13 	<= d4_gr12;
		neg_gr13 	<= neg_gr12;
		mk_cnt_gr13 <= mk_cnt_gr12;
	end
end

//GR12 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr13 <= 0;
		yi_gr13 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gr13)
			0: begin
				if(start_gr13) begin
					xi_gr13 <= 0;
					yi_gr13 <= rd_A_data;
				end
				else if(nop_gr13 && !finish_gr13) begin
					xi_gr13 <= rd_A_data;
					yi_gr13 <= yo_gr13;
				end
				else begin
					xi_gr13 <= xo_gr13;
					yi_gr13 <= yo_gr13;
				end
			end
			ITER_K: begin
				if(finish_gr13) begin
					xi_gr13 <= xo_mk1; //propagate r13 to GG2 after 5 nop cycles
					yi_gr13 <= yo_mk1;
				end
				else begin
					xi_gr13 <= rd_A_data;
					yi_gr13 <= xo_mk1;
				end
			end
			default: begin
				xi_gr13 <= xo_gr13;
				yi_gr13 <= yo_gr13;
			end
		endcase
	end
	else begin
		xi_gr13 <= 0;
		xi_gr13 <= 0;
	end
end


/*****************************************************************/
/**                              GG2                            **/
/*****************************************************************/
//GG2 current iteration number
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gg2 <= 0;
	end
	else if(OP_wire) begin
		if(nop_gg2) begin
			iter_gg2 <= 0;
		end
		else if(iter_last_gg2) begin
			iter_gg2 <= iter_gg2 + 1;
		end
		else begin
			iter_gg2 <= iter_gg2 + ITER_ONE_CYCLE;
		end
	end
	else begin
		iter_gg2 <= 0;
	end
end

// GG2 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg2 <= 0;
		yi_gg2 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gg2)
			0: begin
				if(start_gg2) begin
					xi_gg2 <= 0;
					yi_gg2 <= yo_mk1;
				end
				else if(nop_gg2 && !finish_gg2) begin
					xi_gg2 <= yo_mk1;
					yi_gg2 <= yo_gg2;
				end
				else begin
					xi_gg2 <= xo_gg2;
					yi_gg2 <= yo_gg2;
				end
			end
			ITER_K: begin
				if(finish_gg2) begin
					xi_gg2 <= xo_gr11; //output r23 propagated from GR21 after 1 nop cycles
					yi_gg2 <= yo_gr11; //output r13 propagated from GR12 and GR21 after 2 nop cycles
				end
				else begin
					xi_gg2 <= yo_mk1;
					yi_gg2 <= xo_mk2;
				end
			end
			default: begin
				xi_gg2 <= xo_gg2;
				yi_gg2 <= yo_gg2;
			end
		endcase
	end
	else begin
		xi_gg2 <= 0;
		yi_gg2 <= 0;
	end
end

//GG2 mk_cnt
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gg2 <= 0;
	end
	else if(multk_gg2) begin
		mk_cnt_gg2 <= mk_cnt_gg2 + 1;
	end
end


/*****************************************************************/
/**                              GR21                           **/
/*****************************************************************/
//GR21 current iteration number
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr21 	<= 0;	
		nop_gr21 	<= 0;
		d1_gr21 	<= 0;
		d2_gr21 	<= 0;
		d3_gr21 	<= 0;
		d4_gr21 	<= 0;
		neg_gr21 	<= 0;
		mk_cnt_gr21 <= 0;
	end
	else begin
		iter_gr21 	<= iter_gg2;
		nop_gr21 	<= nop_gg2;
		d1_gr21 	<= d1_gg2;
		d2_gr21 	<= d2_gg2;
		d3_gr21 	<= d3_gg2;
		d4_gr21 	<= d4_gg2;
		neg_gr21 	<= neg_gg2;
		mk_cnt_gr21 <= mk_cnt_gg2;
	end
end

//GR21 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr21 <= 0;
		yi_gr21 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gr21)
			0: begin
				if(start_gr21) begin
					xi_gr21 <= 0;
					yi_gr21 <= yo_mk1;
				end
				else if(nop_gr21 && !finish_gr21) begin
					xi_gr21 <= yo_mk1;
					yi_gr21 <= yo_gr21;
				end
				else begin
					xi_gr21 <= xo_gr21;
					yi_gr21 <= yo_gr21;
				end
			end
			ITER_K: begin
				if(finish_gr21) begin
					xi_gr21 <= xo_mk2; //propagate r21 to GG2 after 5 nop cycles
					yi_gr21 <= xo_gr12;
				end
				else begin
					xi_gr21 <= yo_mk1;
					yi_gr21 <= xo_mk2;
				end
			end
			default: begin
				xi_gr21 <= xo_gr21;
				yi_gr21 <= yo_gr21;
			end
		endcase
	end
	else begin
		xi_gr21 <= 0;
		xi_gr21 <= 0;
	end
end



/*****************************************************************/
/**                              GR22                           **/
/*****************************************************************/
always @(posedge clk or posedge rst) begin
    if (rst) begin
        iter_gr22 	<= 0;
        nop_gr22 	<= 0;
        d1_gr22 	<= 0;
        d2_gr22 	<= 0;
		d3_gr21 	<= 0;
		d4_gr21 	<= 0;
        neg_gr22 	<= 0;
        mk_cnt_gr22 <= 0;
    end
    else begin
        iter_gr22 	<= iter_gr21;
        nop_gr22 	<= nop_gr21;
        d1_gr22 	<= d1_gr21;
        d2_gr22 	<= d2_gr21;
		d3_gr22 	<= d3_gr21;
		d4_gr22 	<= d4_gr21;
        neg_gr22 	<= neg_gr21;
        mk_cnt_gr22 <= mk_cnt_gr21;
    end
end


//GR22 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr22 <= 0;
		yi_gr22 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gr22)
			0: begin
				if(start_gr22) begin
					xi_gr22 <= 0;
					yi_gr22 <= yo_mk1;
				end
				else if(nop_gr22 && !finish_gr22) begin
					xi_gr22 <= yo_mk1;
					yi_gr22 <= yo_gr22;
				end
				else begin
					xi_gr22 <= xo_gr22;
					yi_gr22 <= yo_gr22;
				end
			end
			ITER_K: begin
				if(finish_gr22) begin
					xi_gr22 <= xo_mk2; //propagate r22 to GG2 after 5 nop cycles
					yi_gr22 <= xo_gr13;
				end
				else begin
					xi_gr22 <= yo_mk1;
					yi_gr22 <= xo_mk2;
				end
			end
			default: begin
				xi_gr22 <= xo_gr22;
				yi_gr22 <= yo_gr22;
			end
		endcase
	end
	else begin
		xi_gr22 <= 0;
		xi_gr22 <= 0;
	end
end


/*****************************************************************/
/**                              GG3                            **/
/*****************************************************************/
// GG3 current iteration number
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gg3 <= 0;
	end
	else if(OP_wire) begin
		if(nop_gg3) begin
			iter_gg3 <= 0;
		end
		else if(iter_last_gg3) begin
			iter_gg3 <= iter_gg3 + 1;
		end
		else begin
			iter_gg3 <= iter_gg3 + ITER_ONE_CYCLE;
		end
	end
	else begin
		iter_gg3 <= 0;
	end
end

//GG3 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg3 <= 0;
		yi_gg3 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gg3)
			0: begin
				if(start_gg3) begin
					xi_gg3 <= 0;
					yi_gg3 <= yo_mk2;
				end
				else if(nop_gg3 && !finish_gg3) begin
					xi_gg3 <= yo_mk2;
					yi_gg3 <= yo_gg3;
				end
				else begin
					xi_gg3 <= xo_gg3;
					yi_gg3 <= yo_gg3;
				end
			end
			ITER_K: begin
				if(finish_gg3) begin
					xi_gg3 <= xo_gr21; //output r23 propagated from GR21 after 1 nop cycles
					yi_gg3 <= yo_gr21; //output r13 propagated from GR12 and GR21 after 2 nop cycles
				end
				else begin
					xi_gg3 <= yo_mk2;
					yi_gg3 <= xo_mk3;
				end
			end
			default: begin
				xi_gg3 <= xo_gg3;
				yi_gg3 <= yo_gg3;
			end
		endcase
	end
	else begin
		xi_gg3 <= 0;
		yi_gg3 <= 0;
	end
end

//GG3 mk_cnt
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gg3 <= 0;
	end
	else if(multk_gg3) begin
		mk_cnt_gg3 <= mk_cnt_gg3 + 1;
	end
end



/*****************************************************************/
/**                              GR31                           **/
/*****************************************************************/
//GR31 current iteration number
always @(posedge clk or posedge rst) begin
    if (rst) begin
        iter_gr31 	<= 0;
        nop_gr31 	<= 0;
        d1_gr31 	<= 0;
        d2_gr31 	<= 0;
		d3_gr31 	<= 0;
		d4_gr31 	<= 0;
        neg_gr31 	<= 0;
        mk_cnt_gr31 <= 0;
    end
    else begin
        iter_gr31 	<= iter_gg3;
        nop_gr31 	<= nop_gg3;
        d1_gr31 	<= d1_gg3;
        d2_gr31 	<= d2_gg3;
		d3_gr31 	<= d3_gg3;
		d4_gr31 	<= d4_gg3;
        neg_gr31 	<= neg_gg3;
        mk_cnt_gr31 <= mk_cnt_gg3;
    end
end

//GR31 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr31 <= 0;
		yi_gr31 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gr31)
			0: begin
				if(start_gr31) begin
					xi_gr31 <= 0;
					yi_gr31 <= yo_mk2;
				end
				else if(nop_gr31 && !finish_gr31) begin
					xi_gr31 <= yo_mk2;
					yi_gr31 <= yo_gr31;
				end
				else if(finish_gg4) begin
					xi_gr31 <= xo_gr31; 
					yi_gr31 <= yo_gr22; //propagate r14 to GG4 (from GR13 and GR22) after 2 nop cycles
				end
				else begin
					xi_gr31 <= xo_gr31;
					yi_gr31 <= yo_gr31;
				end
			end
			ITER_K: begin
				if(finish_gr31) begin
					xi_gr31 <= xo_mk3; //propagate r31 to GG2 after 5 nop cycles
					yi_gr31 <= xo_gr22;
				end
				else begin
					xi_gr31 <= yo_mk2;
					yi_gr31 <= xo_mk3;
				end
			end
			default: begin
				xi_gr31 <= xo_gr31;
				yi_gr31 <= yo_gr31;
			end
		endcase
	end
	else begin
		xi_gr31 <= 0;
		xi_gr31 <= 0;
	end
end


/*****************************************************************/
/**                              GG4                            **/
/*****************************************************************/
//GG4 current iteration number
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gg4 <= 0;
	end
	else if(OP_wire) begin
		if(nop_gg4 && !finish_gg4) begin
			iter_gg4 <= 0;
		end
		else if(nop_gg4 || iter_last_gg4) begin
			iter_gg4 <= (iter_gg4 == 13) ? 0 :iter_gg4 + 1;
		end
		else begin
			iter_gg4 <= iter_gg4 + ITER_ONE_CYCLE;
		end
	end
	else begin
		iter_gg4 <= 0;
	end
end


//GG4 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg4 <= 0;
		yi_gg4 <= 0;
	end
	else if(OP_wire) begin
		case(iter_gg4)
			0: begin
				if(start_gg4) begin
					xi_gg4 <= 0;
					yi_gg4 <= yo_mk3;
				end
				else if(nop_gg4 && !finish_gg4) begin
					xi_gg4 <= yo_mk3;
					yi_gg4 <= yo_gg4;
				end
				else begin
					xi_gg4 <= xo_gg4;
					yi_gg4 <= yo_gg4;
				end
			end
			1: begin
					xi_gg4 <= xo_gg4;
					yi_gg4 <= yo_gr31; // output r14 propagated from GR13, GR22 and GR31 after 1 nop cycles
				end
			ITER_K: begin
				if(finish_gg4) begin
					xi_gg4 <= xo_gr31; // output r23 propagated from GR21 after 1 nop cycles
					yi_gg4 <= yo_gr31; // output r13 propagated from GR12 and GR21 after 2 nop cycles
				end
				else begin
					xi_gg4 <= yo_mk3;
					yi_gg4 <= xo_mk4;
				end
			end
			default: begin
				xi_gg4 <= xo_gg4;
				yi_gg4 <= yo_gg4;
			end
		endcase
	end
	else begin
		xi_gg4 <= 0;
		yi_gg4 <= 0;
	end
end

//GG4 mk_cnt
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gg4 <= 0;
	end
	else if(multk_gg4) begin
		mk_cnt_gg4 <= mk_cnt_gg4 + 1;
	end
end



/*****************************************************************/
/**                              MK1                            **/
/*****************************************************************/
//MK1 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk1 <= 0;
		yi_mk1 <= 0;
	end
	else if(OP_wire) begin
		case(1)
			iter_last_gg1: begin
				xi_mk1 <= xo_gg1;
				yi_mk1 <= yo_gg1;
			end
			iter_last_gr11: begin
				xi_mk1 <= xo_gr11;
				yi_mk1 <= yo_gr11;
			end
			iter_last_gr12: begin
				xi_mk1 <= xo_gr12;
				yi_mk1 <= yo_gr12;
			end
			iter_last_gr13: begin
				xi_mk1 <= xo_gr13;
				yi_mk1 <= yo_gr13;
			end
			default: begin
				xi_mk1 <= 0;
				yi_mk1 <= 0;
			end
		endcase
	end
	else begin
		xi_mk1 <= 0;
		yi_mk1 <= 0;
	end
end



/*****************************************************************/
/**                              MK2                            **/
/*****************************************************************/
//MK2 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk2 <= 0;
		yi_mk2 <= 0;
	end
	else if(OP_wire) begin
		case(1)
			iter_last_gg2: begin
				xi_mk2 <= xo_gg2;
				yi_mk2 <= yo_gg2;
			end
			iter_last_gr21: begin
				xi_mk2 <= xo_gr21;
				yi_mk2 <= yo_gr21;
			end
			iter_last_gr22: begin
				xi_mk2 <= xo_gr22;
				yi_mk2 <= yo_gr22;
			end
			default: begin
				xi_mk2 <= 0;
				yi_mk2 <= 0;
			end
		endcase
	end
	else begin
		xi_mk2 <= 0;
		yi_mk2 <= 0;
	end
end


/*****************************************************************/
/**                              MK3                            **/
/*****************************************************************/
//MK3 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk3 <= 0;
		yi_mk3 <= 0;
	end
	else if(OP_wire) begin
		case(1)
			iter_last_gg3: begin
				xi_mk3 <= xo_gg3;
				yi_mk3 <= yo_gg3;
			end
			iter_last_gr31: begin
				xi_mk3 <= xo_gr31;
				yi_mk3 <= yo_gr31;
			end
			default: begin
				xi_mk3 <= 0;
				yi_mk3 <= 0;
			end
		endcase
	end
	else begin
		xi_mk3 <= 0;
		yi_mk3 <= 0;
	end
end

/*****************************************************************/
/**                              MK4                            **/
/*****************************************************************/
//MK4 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk4 <= 0;
		yi_mk4 <= 0;
	end
	else if(OP_wire) begin
		case(1)
			iter_last_gg4: begin
				xi_mk4 <= xo_gg4;
				yi_mk4 <= yo_gg4;
			end
			default: begin
				xi_mk4 <= 0;
				yi_mk4 <= 0;
			end
		endcase
	end
	else begin
		xi_mk4 <= 0;
		yi_mk4 <= 0;
	end
end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                 module instantiation                                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

GG GG1_inst (
	.nop  (nop_gg1),
	.xi   (xi_gg1),
	.yi   (yi_gg1),
	.iter (iter_gg1),
	.d1   (d1_gg1),
	.d2   (d2_gg1),
	.d3   (d3_gg1),
	.d4   (d4_gg1),
	.neg  (neg_gg1),
	.xo   (xo_gg1),
	.yo   (yo_gg1)
);

GR GR11_inst (
	.nop  (nop_gr11),
	.xi   (xi_gr11),
	.yi   (yi_gr11),
	.iter (iter_gr11),
	.d1   (d1_gr11),
	.d2   (d2_gr11),
	.d3   (d3_gr11),
	.d4   (d4_gr11),
	.neg  (neg_gr11),
	.xo   (xo_gr11),
	.yo   (yo_gr11)
);

GR GR12_inst (
	.nop  (nop_gr12),
	.xi   (xi_gr12),
	.yi   (yi_gr12),
	.iter (iter_gr12),
	.d1   (d1_gr12),
	.d2   (d2_gr12),
	.d3   (d3_gr12),
	.d4   (d4_gr12),
	.neg  (neg_gr12),
	.xo   (xo_gr12),
	.yo   (yo_gr12)
);

GR GR13_inst (
	.nop  (nop_gr13),
	.xi   (xi_gr13),
	.yi   (yi_gr13),
	.iter (iter_gr13),
	.d1   (d1_gr13),
	.d2   (d2_gr13),
	.d3   (d3_gr13),
	.d4   (d4_gr13),
	.neg  (neg_gr13),
	.xo   (xo_gr13),
	.yo   (yo_gr13)
);

GG GG2_inst (
	.nop  (nop_gg2),
	.xi   (xi_gg2),
	.yi   (yi_gg2),
	.iter (iter_gg2),
	.d1   (d1_gg2),
	.d2   (d2_gg2),
	.d3   (d3_gg2),
	.d4   (d4_gg2),
	.neg  (neg_gg2),
	.xo   (xo_gg2),
	.yo   (yo_gg2)
);

GR GR21_inst (
	.nop  (nop_gr21),
	.xi   (xi_gr21),
	.yi   (yi_gr21),
	.iter (iter_gr21),
	.d1   (d1_gr21),
	.d2   (d2_gr21),
	.d3   (d3_gr21),
	.d4   (d4_gr21),
	.neg  (neg_gr21),
	.xo   (xo_gr21),
	.yo   (yo_gr21)
);

GR GR22_inst (
	.nop  (nop_gr22),
	.xi   (xi_gr22),
	.yi   (yi_gr22),
	.iter (iter_gr22),
	.d1   (d1_gr22),
	.d2   (d2_gr22),
	.d3   (d3_gr22),
	.d4   (d4_gr22),
	.neg  (neg_gr22),
	.xo   (xo_gr22),
	.yo   (yo_gr22)
);

GG GG3_inst (
	.nop  (nop_gg3),
	.xi   (xi_gg3),
	.yi   (yi_gg3),
	.iter (iter_gg3),
	.d1   (d1_gg3),
	.d2   (d2_gg3),
	.d3   (d3_gg3),
	.d4   (d4_gg3),
	.neg  (neg_gg3),
	.xo   (xo_gg3),
	.yo   (yo_gg3)
);

GR GR31_inst (
	.nop  (nop_gr31),
	.xi   (xi_gr31),
	.yi   (yi_gr31),
	.iter (iter_gr31),
	.d1   (d1_gr31),
	.d2   (d2_gr31),
	.d3   (d3_gr31),
	.d4   (d4_gr31),
	.neg  (neg_gr31),
	.xo   (xo_gr31),
	.yo   (yo_gr31)
);

GG GG4_inst (
	.nop  (nop_gg4),
	.xi   (xi_gg4),
	.yi   (yi_gg4),
	.iter (iter_gg4),
	.d1   (d1_gg4),
	.d2   (d2_gg4),
	.d3   (d3_gg4),
	.d4   (d4_gg4),
	.neg  (neg_gg4),
	.xo   (xo_gg4),
	.yo   (yo_gg4)
);

MK MK1_inst (
	.xi (xi_mk1),
	.yi (yi_mk1),
	.xo (xo_mk1),
	.yo (yo_mk1)
);

MK MK2_inst (
	.xi (xi_mk2),
	.yi (yi_mk2),
	.xo (xo_mk2),
	.yo (yo_mk2)
);

MK MK3_inst (
	.xi (xi_mk3),
	.yi (yi_mk3),
	.xo (xo_mk3),
	.yo (yo_mk3)
);

MK MK4_inst (
	.xi (xi_mk4),
	.yi (yi_mk4),
	.xo (xo_mk4),
	.yo (yo_mk4)
);


endmodule
