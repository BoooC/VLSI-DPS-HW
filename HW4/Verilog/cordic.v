module qr_cordic #(
	parameter R_LEN     	= 12,
	parameter R_FRAC    	= 2,
	parameter Q_LEN     	= 12,
	parameter Q_FRAC    	= 10,
	parameter K_LEN     	= 10,
	parameter K_FRAC    	= 9,
		
	parameter ROW_LEN_R		= 3,	// 8
	parameter COL_LEN_R		= 2,	// 4
	parameter ROW_LEN_Q		= 3,	// 8
	parameter COL_LEN_Q		= 3,	// 8
	
	parameter ITER_NUM  	= 12,
	parameter ITER_K		= ITER_NUM + 1,
	parameter ITER_ONE_CYCLE= 4,
	parameter ITER_LEN  	= 4
)
(	input                                   clk,
	input                                   rst,
	input                                   en,
	
	output                                  rd_A,
	input      signed    [R_LEN-1:0]        rd_A_data,
	output reg           [ROW_LEN_R-1:0]    rd_A_row_addr,
	output reg           [COL_LEN_R-1:0]    rd_A_col_addr,
	
	output reg                              wr_R,
	output reg signed    [R_LEN-1:0]        wr_R_data,
	output reg           [ROW_LEN_R-1:0]    wr_R_row_addr,
	output reg           [COL_LEN_R-1:0]    wr_R_col_addr,
	
	output reg                              wr_Q,
	output reg signed    [Q_LEN-1:0]        wr_Q_data,
	output reg           [ROW_LEN_Q-1:0]    wr_Q_row_addr,
	output reg           [COL_LEN_Q-1:0]    wr_Q_col_addr,
	
	output reg                              valid
);


/***********************************************************************************/
/**                           Signals of other module                             **/
/***********************************************************************************/
// GG1
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

// GR11
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

// GR12
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

// GR13
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

// GG2
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

// GR21
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

// GR22
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

// GG3
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

// GR31
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

// GG4
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

// Q11
reg                                         nop_q11;
reg            signed 	[Q_LEN-1:0]         xi_q11;
reg            signed 	[Q_LEN-1:0]         yi_q11;
reg                   	[ITER_LEN-1:0]      iter_q11;
reg                   	[1:0]               d1_q11;
reg                   	[1:0]				d2_q11;
reg                  	[1:0]				d3_q11;
reg                  	[1:0]				d4_q11;
reg                   	                    neg_q11;
wire           signed 	[Q_LEN-1:0]         xo_q11;
wire           signed 	[Q_LEN-1:0]         yo_q11;

// Q12
reg                                         nop_q12;
reg            signed 	[Q_LEN-1:0]         xi_q12;
reg            signed 	[Q_LEN-1:0]         yi_q12;
reg                   	[ITER_LEN-1:0]      iter_q12;
reg                   	[1:0]               d1_q12;
reg                   	[1:0]				d2_q12;
reg                  	[1:0]				d3_q12;
reg                  	[1:0]				d4_q12;
reg                   	                    neg_q12;
wire           signed 	[Q_LEN-1:0]         xo_q12;
wire           signed 	[Q_LEN-1:0]         yo_q12;

// Q13
reg                                         nop_q13;
reg            signed 	[Q_LEN-1:0]         xi_q13;
reg            signed 	[Q_LEN-1:0]         yi_q13;
reg                   	[ITER_LEN-1:0]      iter_q13;
reg                   	[1:0]               d1_q13;
reg                   	[1:0]				d2_q13;
reg                  	[1:0]				d3_q13;
reg                  	[1:0]				d4_q13;
reg                   	                    neg_q13;
wire           signed 	[Q_LEN-1:0]         xo_q13;
wire           signed 	[Q_LEN-1:0]         yo_q13;

// Q14
reg                                         nop_q14;
reg            signed 	[Q_LEN-1:0]         xi_q14;
reg            signed 	[Q_LEN-1:0]         yi_q14;
reg                   	[ITER_LEN-1:0]      iter_q14;
reg                   	[1:0]               d1_q14;
reg                   	[1:0]				d2_q14;
reg                  	[1:0]				d3_q14;
reg                  	[1:0]				d4_q14;
reg                   	                    neg_q14;
wire           signed 	[Q_LEN-1:0]         xo_q14;
wire           signed 	[Q_LEN-1:0]         yo_q14;

// Q15
reg                                         nop_q15;
reg            signed 	[Q_LEN-1:0]         xi_q15;
reg            signed 	[Q_LEN-1:0]         yi_q15;
reg                   	[ITER_LEN-1:0]      iter_q15;
reg                   	[1:0]               d1_q15;
reg                   	[1:0]				d2_q15;
reg                  	[1:0]				d3_q15;
reg                  	[1:0]				d4_q15;
reg                   	                    neg_q15;
wire           signed 	[Q_LEN-1:0]         xo_q15;
wire           signed 	[Q_LEN-1:0]         yo_q15;

// Q16
reg                                         nop_q16;
reg            signed 	[Q_LEN-1:0]         xi_q16;
reg            signed 	[Q_LEN-1:0]         yi_q16;
reg                   	[ITER_LEN-1:0]      iter_q16;
reg                   	[1:0]               d1_q16;
reg                   	[1:0]				d2_q16;
reg                  	[1:0]				d3_q16;
reg                  	[1:0]				d4_q16;
reg                   	                    neg_q16;
wire           signed 	[Q_LEN-1:0]         xo_q16;
wire           signed 	[Q_LEN-1:0]         yo_q16;

// Q17
reg                                         nop_q17;
reg            signed 	[Q_LEN-1:0]         xi_q17;
reg            signed 	[Q_LEN-1:0]         yi_q17;
reg                   	[ITER_LEN-1:0]      iter_q17;
reg                   	[1:0]               d1_q17;
reg                   	[1:0]				d2_q17;
reg                  	[1:0]				d3_q17;
reg                  	[1:0]				d4_q17;
reg                   	                    neg_q17;
wire           signed 	[Q_LEN-1:0]         xo_q17;
wire           signed 	[Q_LEN-1:0]         yo_q17;

// Q18
reg                                         nop_q18;
reg            signed 	[Q_LEN-1:0]         xi_q18;
reg            signed 	[Q_LEN-1:0]         yi_q18;
reg                   	[ITER_LEN-1:0]      iter_q18;
reg                   	[1:0]               d1_q18;
reg                   	[1:0]				d2_q18;
reg                  	[1:0]				d3_q18;
reg                  	[1:0]				d4_q18;
reg                   	                    neg_q18;
wire           signed 	[Q_LEN-1:0]         xo_q18;
wire           signed 	[Q_LEN-1:0]         yo_q18;

// Q21
reg                                         nop_q21;
reg            signed 	[Q_LEN-1:0]         xi_q21;
reg            signed 	[Q_LEN-1:0]         yi_q21;
reg                   	[ITER_LEN-1:0]      iter_q21;
reg                   	[1:0]               d1_q21;
reg                   	[1:0]				d2_q21;
reg                  	[1:0]				d3_q21;
reg                  	[1:0]				d4_q21;
reg                   	                    neg_q21;
wire           signed 	[Q_LEN-1:0]         xo_q21;
wire           signed 	[Q_LEN-1:0]         yo_q21;

// Q22
reg                                         nop_q22;
reg            signed 	[Q_LEN-1:0]         xi_q22;
reg            signed 	[Q_LEN-1:0]         yi_q22;
reg                   	[ITER_LEN-1:0]      iter_q22;
reg                   	[1:0]               d1_q22;
reg                   	[1:0]				d2_q22;
reg                  	[1:0]				d3_q22;
reg                  	[1:0]				d4_q22;
reg                   	                    neg_q22;
wire           signed 	[Q_LEN-1:0]         xo_q22;
wire           signed 	[Q_LEN-1:0]         yo_q22;

// Q23
reg                                         nop_q23;
reg            signed 	[Q_LEN-1:0]         xi_q23;
reg            signed 	[Q_LEN-1:0]         yi_q23;
reg                   	[ITER_LEN-1:0]      iter_q23;
reg                   	[1:0]               d1_q23;
reg                   	[1:0]				d2_q23;
reg                  	[1:0]				d3_q23;
reg                  	[1:0]				d4_q23;
reg                   	                    neg_q23;
wire           signed 	[Q_LEN-1:0]         xo_q23;
wire           signed 	[Q_LEN-1:0]         yo_q23;

// Q24
reg                                         nop_q24;
reg            signed 	[Q_LEN-1:0]         xi_q24;
reg            signed 	[Q_LEN-1:0]         yi_q24;
reg                   	[ITER_LEN-1:0]      iter_q24;
reg                   	[1:0]               d1_q24;
reg                   	[1:0]				d2_q24;
reg                  	[1:0]				d3_q24;
reg                  	[1:0]				d4_q24;
reg                   	                    neg_q24;
wire           signed 	[Q_LEN-1:0]         xo_q24;
wire           signed 	[Q_LEN-1:0]         yo_q24;

// Q25
reg                                         nop_q25;
reg            signed 	[Q_LEN-1:0]         xi_q25;
reg            signed 	[Q_LEN-1:0]         yi_q25;
reg                   	[ITER_LEN-1:0]      iter_q25;
reg                   	[1:0]               d1_q25;
reg                   	[1:0]				d2_q25;
reg                  	[1:0]				d3_q25;
reg                  	[1:0]				d4_q25;
reg                   	                    neg_q25;
wire           signed 	[Q_LEN-1:0]         xo_q25;
wire           signed 	[Q_LEN-1:0]         yo_q25;

// Q26
reg                                         nop_q26;
reg            signed 	[Q_LEN-1:0]         xi_q26;
reg            signed 	[Q_LEN-1:0]         yi_q26;
reg                   	[ITER_LEN-1:0]      iter_q26;
reg                   	[1:0]               d1_q26;
reg                   	[1:0]				d2_q26;
reg                  	[1:0]				d3_q26;
reg                  	[1:0]				d4_q26;
reg                   	                    neg_q26;
wire           signed 	[Q_LEN-1:0]         xo_q26;
wire           signed 	[Q_LEN-1:0]         yo_q26;

// Q27
reg                                         nop_q27;
reg            signed 	[Q_LEN-1:0]         xi_q27;
reg            signed 	[Q_LEN-1:0]         yi_q27;
reg                   	[ITER_LEN-1:0]      iter_q27;
reg                   	[1:0]               d1_q27;
reg                   	[1:0]				d2_q27;
reg                  	[1:0]				d3_q27;
reg                  	[1:0]				d4_q27;
reg                   	                    neg_q27;
wire           signed 	[Q_LEN-1:0]         xo_q27;
wire           signed 	[Q_LEN-1:0]         yo_q27;

// Q28
reg                                         nop_q28;
reg            signed 	[Q_LEN-1:0]         xi_q28;
reg            signed 	[Q_LEN-1:0]         yi_q28;
reg                   	[ITER_LEN-1:0]      iter_q28;
reg                   	[1:0]               d1_q28;
reg                   	[1:0]				d2_q28;
reg                  	[1:0]				d3_q28;
reg                  	[1:0]				d4_q28;
reg                   	                    neg_q28;
wire           signed 	[Q_LEN-1:0]         xo_q28;
wire           signed 	[Q_LEN-1:0]         yo_q28;

// Q31
reg                                         nop_q31;
reg            signed 	[Q_LEN-1:0]         xi_q31;
reg            signed 	[Q_LEN-1:0]         yi_q31;
reg                   	[ITER_LEN-1:0]      iter_q31;
reg                   	[1:0]               d1_q31;
reg                   	[1:0]				d2_q31;
reg                  	[1:0]				d3_q31;
reg                  	[1:0]				d4_q31;
reg                   	                    neg_q31;
wire           signed 	[Q_LEN-1:0]         xo_q31;
wire           signed 	[Q_LEN-1:0]         yo_q31;

// Q32
reg                                         nop_q32;
reg            signed 	[Q_LEN-1:0]         xi_q32;
reg            signed 	[Q_LEN-1:0]         yi_q32;
reg                   	[ITER_LEN-1:0]      iter_q32;
reg                   	[1:0]               d1_q32;
reg                   	[1:0]				d2_q32;
reg                  	[1:0]				d3_q32;
reg                  	[1:0]				d4_q32;
reg                   	                    neg_q32;
wire           signed 	[Q_LEN-1:0]         xo_q32;
wire           signed 	[Q_LEN-1:0]         yo_q32;

// Q33
reg                                         nop_q33;
reg            signed 	[Q_LEN-1:0]         xi_q33;
reg            signed 	[Q_LEN-1:0]         yi_q33;
reg                   	[ITER_LEN-1:0]      iter_q33;
reg                   	[1:0]               d1_q33;
reg                   	[1:0]				d2_q33;
reg                  	[1:0]				d3_q33;
reg                  	[1:0]				d4_q33;
reg                   	                    neg_q33;
wire           signed 	[Q_LEN-1:0]         xo_q33;
wire           signed 	[Q_LEN-1:0]         yo_q33;

// Q34
reg                                         nop_q34;
reg            signed 	[Q_LEN-1:0]         xi_q34;
reg            signed 	[Q_LEN-1:0]         yi_q34;
reg                   	[ITER_LEN-1:0]      iter_q34;
reg                   	[1:0]               d1_q34;
reg                   	[1:0]				d2_q34;
reg                  	[1:0]				d3_q34;
reg                  	[1:0]				d4_q34;
reg                   	                    neg_q34;
wire           signed 	[Q_LEN-1:0]         xo_q34;
wire           signed 	[Q_LEN-1:0]         yo_q34;

// Q35
reg                                         nop_q35;
reg            signed 	[Q_LEN-1:0]         xi_q35;
reg            signed 	[Q_LEN-1:0]         yi_q35;
reg                   	[ITER_LEN-1:0]      iter_q35;
reg                   	[1:0]               d1_q35;
reg                   	[1:0]				d2_q35;
reg                  	[1:0]				d3_q35;
reg                  	[1:0]				d4_q35;
reg                   	                    neg_q35;
wire           signed 	[Q_LEN-1:0]         xo_q35;
wire           signed 	[Q_LEN-1:0]         yo_q35;

// Q36
reg                                         nop_q36;
reg            signed 	[Q_LEN-1:0]         xi_q36;
reg            signed 	[Q_LEN-1:0]         yi_q36;
reg                   	[ITER_LEN-1:0]      iter_q36;
reg                   	[1:0]               d1_q36;
reg                   	[1:0]				d2_q36;
reg                  	[1:0]				d3_q36;
reg                  	[1:0]				d4_q36;
reg                   	                    neg_q36;
wire           signed 	[Q_LEN-1:0]         xo_q36;
wire           signed 	[Q_LEN-1:0]         yo_q36;

// Q37
reg                                         nop_q37;
reg            signed 	[Q_LEN-1:0]         xi_q37;
reg            signed 	[Q_LEN-1:0]         yi_q37;
reg                   	[ITER_LEN-1:0]      iter_q37;
reg                   	[1:0]               d1_q37;
reg                   	[1:0]				d2_q37;
reg                  	[1:0]				d3_q37;
reg                  	[1:0]				d4_q37;
reg                   	                    neg_q37;
wire           signed 	[Q_LEN-1:0]         xo_q37;
wire           signed 	[Q_LEN-1:0]         yo_q37;

// Q38
reg                                         nop_q38;
reg            signed 	[Q_LEN-1:0]         xi_q38;
reg            signed 	[Q_LEN-1:0]         yi_q38;
reg                   	[ITER_LEN-1:0]      iter_q38;
reg                   	[1:0]               d1_q38;
reg                   	[1:0]				d2_q38;
reg                  	[1:0]				d3_q38;
reg                  	[1:0]				d4_q38;
reg                   	                    neg_q38;
wire           signed 	[Q_LEN-1:0]         xo_q38;
wire           signed 	[Q_LEN-1:0]         yo_q38;

// Q41
reg                                         nop_q41;
reg            signed 	[Q_LEN-1:0]         xi_q41;
reg            signed 	[Q_LEN-1:0]         yi_q41;
reg                   	[ITER_LEN-1:0]      iter_q41;
reg                   	[1:0]               d1_q41;
reg                   	[1:0]				d2_q41;
reg                  	[1:0]				d3_q41;
reg                  	[1:0]				d4_q41;
reg                   	                    neg_q41;
wire           signed 	[Q_LEN-1:0]         xo_q41;
wire           signed 	[Q_LEN-1:0]         yo_q41;

// Q42
reg                                         nop_q42;
reg            signed 	[Q_LEN-1:0]         xi_q42;
reg            signed 	[Q_LEN-1:0]         yi_q42;
reg                   	[ITER_LEN-1:0]      iter_q42;
reg                   	[1:0]               d1_q42;
reg                   	[1:0]				d2_q42;
reg                  	[1:0]				d3_q42;
reg                  	[1:0]				d4_q42;
reg                   	                    neg_q42;
wire           signed 	[Q_LEN-1:0]         xo_q42;
wire           signed 	[Q_LEN-1:0]         yo_q42;

// Q43
reg                                         nop_q43;
reg            signed 	[Q_LEN-1:0]         xi_q43;
reg            signed 	[Q_LEN-1:0]         yi_q43;
reg                   	[ITER_LEN-1:0]      iter_q43;
reg                   	[1:0]               d1_q43;
reg                   	[1:0]				d2_q43;
reg                  	[1:0]				d3_q43;
reg                  	[1:0]				d4_q43;
reg                   	                    neg_q43;
wire           signed 	[Q_LEN-1:0]         xo_q43;
wire           signed 	[Q_LEN-1:0]         yo_q43;

// Q44
reg                                         nop_q44;
reg            signed 	[Q_LEN-1:0]         xi_q44;
reg            signed 	[Q_LEN-1:0]         yi_q44;
reg                   	[ITER_LEN-1:0]      iter_q44;
reg                   	[1:0]               d1_q44;
reg                   	[1:0]				d2_q44;
reg                  	[1:0]				d3_q44;
reg                  	[1:0]				d4_q44;
reg                   	                    neg_q44;
wire           signed 	[Q_LEN-1:0]         xo_q44;
wire           signed 	[Q_LEN-1:0]         yo_q44;

// Q45
reg                                         nop_q45;
reg            signed 	[Q_LEN-1:0]         xi_q45;
reg            signed 	[Q_LEN-1:0]         yi_q45;
reg                   	[ITER_LEN-1:0]      iter_q45;
reg                   	[1:0]               d1_q45;
reg                   	[1:0]				d2_q45;
reg                  	[1:0]				d3_q45;
reg                  	[1:0]				d4_q45;
reg                   	                    neg_q45;
wire           signed 	[Q_LEN-1:0]         xo_q45;
wire           signed 	[Q_LEN-1:0]         yo_q45;

// Q46
reg                                         nop_q46;
reg            signed 	[Q_LEN-1:0]         xi_q46;
reg            signed 	[Q_LEN-1:0]         yi_q46;
reg                   	[ITER_LEN-1:0]      iter_q46;
reg                   	[1:0]               d1_q46;
reg                   	[1:0]				d2_q46;
reg                  	[1:0]				d3_q46;
reg                  	[1:0]				d4_q46;
reg                   	                    neg_q46;
wire           signed 	[Q_LEN-1:0]         xo_q46;
wire           signed 	[Q_LEN-1:0]         yo_q46;

// Q47
reg                                         nop_q47;
reg            signed 	[Q_LEN-1:0]         xi_q47;
reg            signed 	[Q_LEN-1:0]         yi_q47;
reg                   	[ITER_LEN-1:0]      iter_q47;
reg                   	[1:0]               d1_q47;
reg                   	[1:0]				d2_q47;
reg                  	[1:0]				d3_q47;
reg                  	[1:0]				d4_q47;
reg                   	                    neg_q47;
wire           signed 	[Q_LEN-1:0]         xo_q47;
wire           signed 	[Q_LEN-1:0]         yo_q47;

// Q48
reg                                         nop_q48;
reg            signed 	[Q_LEN-1:0]         xi_q48;
reg            signed 	[Q_LEN-1:0]         yi_q48;
reg                   	[ITER_LEN-1:0]      iter_q48;
reg                   	[1:0]               d1_q48;
reg                   	[1:0]				d2_q48;
reg                  	[1:0]				d3_q48;
reg                  	[1:0]				d4_q48;
reg                   	                    neg_q48;
wire           signed 	[Q_LEN-1:0]         xo_q48;
wire           signed 	[Q_LEN-1:0]         yo_q48;

// Q_MK1
reg            signed	[Q_LEN-1:0]         xi_mk1_q;
reg            signed	[Q_LEN-1:0]         yi_mk1_q;
wire           signed	[Q_LEN-1:0]         xo_mk1_q;
wire           signed	[Q_LEN-1:0]         yo_mk1_q;
// Q_MK2
reg            signed	[Q_LEN-1:0]         xi_mk2_q;
reg            signed	[Q_LEN-1:0]         yi_mk2_q;
wire           signed	[Q_LEN-1:0]         xo_mk2_q;
wire           signed	[Q_LEN-1:0]         yo_mk2_q;
// Q_MK3
reg            signed	[Q_LEN-1:0]         xi_mk3_q;
reg            signed	[Q_LEN-1:0]         yi_mk3_q;
wire           signed	[Q_LEN-1:0]         xo_mk3_q;
wire           signed	[Q_LEN-1:0]         yo_mk3_q;
// Q_MK4
reg            signed	[Q_LEN-1:0]         xi_mk4_q;
reg            signed	[Q_LEN-1:0]         yi_mk4_q;
wire           signed	[Q_LEN-1:0]         xo_mk4_q;
wire           signed	[Q_LEN-1:0]         yo_mk4_q;


/***********************************************************************************/
/**                                state parameters                               **/
/***********************************************************************************/
localparam IDLE		= 0;
localparam ROT		= 1;
localparam MUL_K	= 2;
localparam DONE		= 3;


/***********************************************************************************/
/**                                   Registers                                   **/
/***********************************************************************************/
reg	[3:0]	state, next_state;

// R mult k counter
reg	[2:0]	mk_cnt_gg1;
reg	[2:0]	mk_cnt_gr11;
reg	[2:0]	mk_cnt_gr12;
reg	[2:0]	mk_cnt_gr13;
reg	[2:0]	mk_cnt_gg2;
reg	[2:0]	mk_cnt_gr21;
reg	[2:0]	mk_cnt_gr22;
reg	[2:0]	mk_cnt_gg3;
reg	[2:0]	mk_cnt_gr31;
reg	[2:0]	mk_cnt_gg4;

// Q mult k counter
reg	[2:0]	mk_cnt_q11;
reg	[2:0]	mk_cnt_q12;
reg	[2:0]	mk_cnt_q13;
reg	[2:0]	mk_cnt_q14;
reg	[2:0]	mk_cnt_q15;
reg	[2:0]	mk_cnt_q16;
reg	[2:0]	mk_cnt_q17;
reg	[2:0]	mk_cnt_q18;
reg	[2:0]	mk_cnt_q21;
reg	[2:0]	mk_cnt_q22;
reg	[2:0]	mk_cnt_q23;
reg	[2:0]	mk_cnt_q24;
reg	[2:0]	mk_cnt_q25;
reg	[2:0]	mk_cnt_q26;
reg	[2:0]	mk_cnt_q27;
reg	[2:0]	mk_cnt_q28;
reg	[2:0]	mk_cnt_q31;
reg	[2:0]	mk_cnt_q32;
reg	[2:0]	mk_cnt_q33;
reg	[2:0]	mk_cnt_q34;
reg	[2:0]	mk_cnt_q35;
reg	[2:0]	mk_cnt_q36;
reg	[2:0]	mk_cnt_q37;
reg	[2:0]	mk_cnt_q38;
reg	[2:0]	mk_cnt_q41;
reg	[2:0]	mk_cnt_q42;
reg	[2:0]	mk_cnt_q43;
reg	[2:0]	mk_cnt_q44;
reg	[2:0]	mk_cnt_q45;
reg	[2:0]	mk_cnt_q46;
reg	[2:0]	mk_cnt_q47;
reg	[2:0]	mk_cnt_q48;


/***********************************************************************************/
/**                                 Combination                                   **/
/***********************************************************************************/
// state wire
wire IDLE_wire 	= state == IDLE;      
wire ROT_wire 	= state == ROT;
wire MUL_K_wire = state == MUL_K;  
wire DONE_wire 	= state == DONE;
wire OP_wire 	= ROT_wire | MUL_K_wire;

// control signals
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

wire iter_last_gg1  = iter_gg1  == ITER_NUM;
wire iter_last_gr11 = iter_gr11 == ITER_NUM;
wire iter_last_gr12 = iter_gr12 == ITER_NUM;
wire iter_last_gr13 = iter_gr13 == ITER_NUM;
wire iter_last_gg2  = iter_gg2  == ITER_NUM;
wire iter_last_gr21 = iter_gr21 == ITER_NUM;
wire iter_last_gr22 = iter_gr22 == ITER_NUM;
wire iter_last_gg3  = iter_gg3  == ITER_NUM;
wire iter_last_gr31 = iter_gr31 == ITER_NUM;
wire iter_last_gg4	= iter_gg4  == ITER_NUM;

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

// wire start_Q11 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q12 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q13 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q14 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q15 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q16 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q17 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q18 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q21 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q22 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q23 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q24 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q25 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q26 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q27 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q28 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q31 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q32 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q33 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q34 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q35 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q36 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q37 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q38 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q41 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q42 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q43 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q44 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q45 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q46 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q47 		= rd_row_addr ==  && rd_col_addr == ;
// wire start_Q48 		= rd_row_addr ==  && rd_col_addr == ;
// 
// wire iter_last_Q11	= iter_Q11  == ;
// wire iter_last_Q12	= iter_Q12  == ;
// wire iter_last_Q13	= iter_Q13  == ;
// wire iter_last_Q14	= iter_Q14  == ;
// wire iter_last_Q15	= iter_Q15  == ;
// wire iter_last_Q16	= iter_Q16  == ;
// wire iter_last_Q17	= iter_Q17  == ;
// wire iter_last_Q18	= iter_Q18  == ;
// wire iter_last_Q21	= iter_Q21  == ;
// wire iter_last_Q22	= iter_Q22  == ;
// wire iter_last_Q23	= iter_Q23  == ;
// wire iter_last_Q24	= iter_Q24  == ;
// wire iter_last_Q25	= iter_Q25  == ;
// wire iter_last_Q26	= iter_Q26  == ;
// wire iter_last_Q27	= iter_Q27  == ;
// wire iter_last_Q28	= iter_Q28  == ;
// wire iter_last_Q31	= iter_Q31  == ;
// wire iter_last_Q32	= iter_Q32  == ;
// wire iter_last_Q33	= iter_Q33  == ;
// wire iter_last_Q34	= iter_Q34  == ;
// wire iter_last_Q35	= iter_Q35  == ;
// wire iter_last_Q36	= iter_Q36  == ;
// wire iter_last_Q37	= iter_Q37  == ;
// wire iter_last_Q38	= iter_Q38  == ;
// wire iter_last_Q41	= iter_Q41  == ;
// wire iter_last_Q42	= iter_Q42  == ;
// wire iter_last_Q43	= iter_Q43  == ;
// wire iter_last_Q44	= iter_Q44  == ;
// wire iter_last_Q45	= iter_Q45  == ;
// wire iter_last_Q46	= iter_Q46  == ;
// wire iter_last_Q47	= iter_Q47  == ;
// wire iter_last_Q48	= iter_Q48  == ;
// 
// wire multk_Q11		= iter_Q11  == ;
// wire multk_Q12		= iter_Q12  == ;
// wire multk_Q13		= iter_Q13  == ;
// wire multk_Q14		= iter_Q14  == ;
// wire multk_Q15		= iter_Q15  == ;
// wire multk_Q16		= iter_Q16  == ;
// wire multk_Q17		= iter_Q17  == ;
// wire multk_Q18		= iter_Q18  == ;
// wire multk_Q21		= iter_Q21  == ;
// wire multk_Q22		= iter_Q22  == ;
// wire multk_Q23		= iter_Q23  == ;
// wire multk_Q24		= iter_Q24  == ;
// wire multk_Q25		= iter_Q25  == ;
// wire multk_Q26		= iter_Q26  == ;
// wire multk_Q27		= iter_Q27  == ;
// wire multk_Q28		= iter_Q28  == ;
// wire multk_Q31		= iter_Q31  == ;
// wire multk_Q32		= iter_Q32  == ;
// wire multk_Q33		= iter_Q33  == ;
// wire multk_Q34		= iter_Q34  == ;
// wire multk_Q35		= iter_Q35  == ;
// wire multk_Q36		= iter_Q36  == ;
// wire multk_Q37		= iter_Q37  == ;
// wire multk_Q38		= iter_Q38  == ;
// wire multk_Q41		= iter_Q41  == ;
// wire multk_Q42		= iter_Q42  == ;
// wire multk_Q43		= iter_Q43  == ;
// wire multk_Q44		= iter_Q44  == ;
// wire multk_Q45		= iter_Q45  == ;
// wire multk_Q46		= iter_Q46  == ;
// wire multk_Q47		= iter_Q47  == ;
// wire multk_Q48		= iter_Q48  == ;
// 
// wire last_multk_Q11	= mk_cnt_Q11  ==  && multk_Q11;
// wire last_multk_Q12	= mk_cnt_Q12  ==  && multk_Q12;
// wire last_multk_Q13	= mk_cnt_Q13  ==  && multk_Q13;
// wire last_multk_Q14	= mk_cnt_Q14  ==  && multk_Q14;
// wire last_multk_Q15	= mk_cnt_Q15  ==  && multk_Q15;
// wire last_multk_Q16	= mk_cnt_Q16  ==  && multk_Q16;
// wire last_multk_Q17	= mk_cnt_Q17  ==  && multk_Q17;
// wire last_multk_Q18	= mk_cnt_Q18  ==  && multk_Q18;
// wire last_multk_Q21	= mk_cnt_Q21  ==  && multk_Q21;
// wire last_multk_Q22	= mk_cnt_Q22  ==  && multk_Q22;
// wire last_multk_Q23	= mk_cnt_Q23  ==  && multk_Q23;
// wire last_multk_Q24	= mk_cnt_Q24  ==  && multk_Q24;
// wire last_multk_Q25	= mk_cnt_Q25  ==  && multk_Q25;
// wire last_multk_Q26	= mk_cnt_Q26  ==  && multk_Q26;
// wire last_multk_Q27	= mk_cnt_Q27  ==  && multk_Q27;
// wire last_multk_Q28	= mk_cnt_Q28  ==  && multk_Q28;
// wire last_multk_Q31	= mk_cnt_Q31  ==  && multk_Q31;
// wire last_multk_Q32	= mk_cnt_Q32  ==  && multk_Q32;
// wire last_multk_Q33	= mk_cnt_Q33  ==  && multk_Q33;
// wire last_multk_Q34	= mk_cnt_Q34  ==  && multk_Q34;
// wire last_multk_Q35	= mk_cnt_Q35  ==  && multk_Q35;
// wire last_multk_Q36	= mk_cnt_Q36  ==  && multk_Q36;
// wire last_multk_Q37	= mk_cnt_Q37  ==  && multk_Q37;
// wire last_multk_Q38	= mk_cnt_Q38  ==  && multk_Q38;
// wire last_multk_Q41	= mk_cnt_Q41  ==  && multk_Q41;
// wire last_multk_Q42	= mk_cnt_Q42  ==  && multk_Q42;
// wire last_multk_Q43	= mk_cnt_Q43  ==  && multk_Q43;
// wire last_multk_Q44	= mk_cnt_Q44  ==  && multk_Q44;
// wire last_multk_Q45	= mk_cnt_Q45  ==  && multk_Q45;
// wire last_multk_Q46	= mk_cnt_Q46  ==  && multk_Q46;
// wire last_multk_Q47	= mk_cnt_Q47  ==  && multk_Q47;
// wire last_multk_Q48	= mk_cnt_Q48  ==  && multk_Q48;

// wire end_Q11  = last_multk_Q11  || (mk_cnt_Q11  ==  && iter_Q11  == );
// wire end_Q12  = last_multk_Q12  || (mk_cnt_Q12  ==  && iter_Q12  == );
// wire end_Q13  = last_multk_Q13  || (mk_cnt_Q13  ==  && iter_Q13  == );
// wire end_Q14  = last_multk_Q14  || (mk_cnt_Q14  ==  && iter_Q14  == );
// wire end_Q15  = last_multk_Q15  || (mk_cnt_Q15  ==  && iter_Q15  == );
// wire end_Q16  = last_multk_Q16  || (mk_cnt_Q16  ==  && iter_Q16  == );
// wire end_Q17  = last_multk_Q17  || (mk_cnt_Q17  ==  && iter_Q17  == );
// wire end_Q18  = last_multk_Q18  || (mk_cnt_Q18  ==  && iter_Q18  == );
// wire end_Q21  = last_multk_Q21  || (mk_cnt_Q21  ==  && iter_Q21  == );
// wire end_Q22  = last_multk_Q22  || (mk_cnt_Q22  ==  && iter_Q22  == );
// wire end_Q23  = last_multk_Q23  || (mk_cnt_Q23  ==  && iter_Q23  == );
// wire end_Q24  = last_multk_Q24  || (mk_cnt_Q24  ==  && iter_Q24  == );
// wire end_Q25  = last_multk_Q25  || (mk_cnt_Q25  ==  && iter_Q25  == );
// wire end_Q26  = last_multk_Q26  || (mk_cnt_Q26  ==  && iter_Q26  == );
// wire end_Q27  = last_multk_Q27  || (mk_cnt_Q27  ==  && iter_Q27  == );
// wire end_Q28  = last_multk_Q28  || (mk_cnt_Q28  ==  && iter_Q28  == );
// wire end_Q31  = last_multk_Q31  || (mk_cnt_Q31  ==  && iter_Q31  == );
// wire end_Q32  = last_multk_Q32  || (mk_cnt_Q32  ==  && iter_Q32  == );
// wire end_Q33  = last_multk_Q33  || (mk_cnt_Q33  ==  && iter_Q33  == );
// wire end_Q34  = last_multk_Q34  || (mk_cnt_Q34  ==  && iter_Q34  == );
// wire end_Q35  = last_multk_Q35  || (mk_cnt_Q35  ==  && iter_Q35  == );
// wire end_Q36  = last_multk_Q36  || (mk_cnt_Q36  ==  && iter_Q36  == );
// wire end_Q37  = last_multk_Q37  || (mk_cnt_Q37  ==  && iter_Q37  == );
// wire end_Q38  = last_multk_Q38  || (mk_cnt_Q38  ==  && iter_Q38  == );
// wire end_Q41  = last_multk_Q41  || (mk_cnt_Q41  ==  && iter_Q41  == );
// wire end_Q42  = last_multk_Q42  || (mk_cnt_Q42  ==  && iter_Q42  == );
// wire end_Q43  = last_multk_Q43  || (mk_cnt_Q43  ==  && iter_Q43  == );
// wire end_Q44  = last_multk_Q44  || (mk_cnt_Q44  ==  && iter_Q44  == );
// wire end_Q45  = last_multk_Q45  || (mk_cnt_Q45  ==  && iter_Q45  == );
// wire end_Q46  = last_multk_Q46  || (mk_cnt_Q46  ==  && iter_Q46  == );
// wire end_Q47  = last_multk_Q47  || (mk_cnt_Q47  ==  && iter_Q47  == );
// wire end_Q48  = last_multk_Q48  || (mk_cnt_Q48  ==  && iter_Q48  == );

wire wr_R_r13 		= mk_cnt_gg4 == 3 && iter_gg4 == 0;
wire wr_R_r34 		= mk_cnt_gg4 == 4 && iter_gg4 == 0;
wire wr_R_r24 		= mk_cnt_gg4 == 4 && iter_gg4 == 1;
wire wr_R_r14 		= mk_cnt_gg4 == 4 && iter_gg4 == 2;

wire nop_gg1 		= (~OP_wire) | read_store 		| finish_gg1;
wire nop_gg2 		= (~OP_wire) | mk_cnt_gr11 <= 1 | finish_gg2 | multk_gg2;
wire nop_gg3 		= (~OP_wire) | mk_cnt_gr21 <= 1 | finish_gg3 | multk_gg3;
wire nop_gg4 		= (~OP_wire) | mk_cnt_gr31 <= 1 | finish_gg4 | multk_gg4;

wire qr_finish		= mk_cnt_gg4 == 4 && iter_gg4 == 2;

// output
assign rd_A = (!rst) && en && (~iter_last_gg1);


/*****************************************************************/
/**                              FSM                            **/
/*****************************************************************/
// next state logic
always @(*) begin
	case(state)
		IDLE 	: next_state = en 		 ? ROT : IDLE;
		ROT 	: next_state = qr_finish ? DONE : iter_last_gg1 ? MUL_K : ROT;
		MUL_K	: next_state = ROT;
		DONE	: next_state = IDLE;
		default	: next_state = IDLE;
	endcase
end

// FSM
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state <= IDLE;
	end
	else begin
		state <= next_state;
	end
end

/*****************************************************************/
/**                             I/O                             **/
/*****************************************************************/
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

// GG1 mk_cnt
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
					xi_gr11 <= xo_mk1; // propagate r12 to GG2 after 5 nop cycles
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
					xi_gr12 <= xo_mk1; // propagate r13 to GG2 after 5 nop cycles
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
					xi_gr13 <= xo_mk1; // propagate r13 to GG2 after 5 nop cycles
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
					xi_gg2 <= xo_gr11; // output r23 propagated from GR21 after 1 nop cycles
					yi_gg2 <= yo_gr11; // output r13 propagated from GR12 and GR21 after 2 nop cycles
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
					xi_gr21 <= xo_mk2; // propagate r21 to GG2 after 5 nop cycles
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
					xi_gr22 <= xo_mk2; // propagate r22 to GG2 after 5 nop cycles
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
					xi_gg3 <= xo_gr21; // output r23 propagated from GR21 after 1 nop cycles
					yi_gg3 <= yo_gr21; // output r13 propagated from GR12 and GR21 after 2 nop cycles
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
					yi_gr31 <= yo_gr22; // propagate r14 to GG4 (from GR13 and GR22) after 2 nop cycles
				end
				else begin
					xi_gr31 <= xo_gr31;
					yi_gr31 <= yo_gr31;
				end
			end
			ITER_K: begin
				if(finish_gr31) begin
					xi_gr31 <= xo_mk3; // propagate r31 to GG2 after 5 nop cycles
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



GR Q11_inst (
	.nop  (nop_q11),
	.xi   (xi_q11),
	.yi   (yi_q11),
	.iter (iter_q11),
	.d1   (d1_q11),
	.d2   (d2_q11),
	.d3   (d3_q11),
	.d4   (d4_q11),
	.neg  (neg_q11),
	.xo   (xo_q11),
	.yo   (yo_q11)
);

GR Q12_inst (
	.nop  (nop_q12),
	.xi   (xi_q12),
	.yi   (yi_q12),
	.iter (iter_q12),
	.d1   (d1_q12),
	.d2   (d2_q12),
	.d3   (d3_q12),
	.d4   (d4_q12),
	.neg  (neg_q12),
	.xo   (xo_q12),
	.yo   (yo_q12)
);

GR Q13_inst (
	.nop  (nop_q13),
	.xi   (xi_q13),
	.yi   (yi_q13),
	.iter (iter_q13),
	.d1   (d1_q13),
	.d2   (d2_q13),
	.d3   (d3_q13),
	.d4   (d4_q13),
	.neg  (neg_q13),
	.xo   (xo_q13),
	.yo   (yo_q13)
);

GR Q14_inst (
	.nop  (nop_q14),
	.xi   (xi_q14),
	.yi   (yi_q14),
	.iter (iter_q14),
	.d1   (d1_q14),
	.d2   (d2_q14),
	.d3   (d3_q14),
	.d4   (d4_q14),
	.neg  (neg_q14),
	.xo   (xo_q14),
	.yo   (yo_q14)
);

GR Q15_inst (
	.nop  (nop_q15),
	.xi   (xi_q15),
	.yi   (yi_q15),
	.iter (iter_q15),
	.d1   (d1_q15),
	.d2   (d2_q15),
	.d3   (d3_q15),
	.d4   (d4_q15),
	.neg  (neg_q15),
	.xo   (xo_q15),
	.yo   (yo_q15)
);

GR Q16_inst (
	.nop  (nop_q16),
	.xi   (xi_q16),
	.yi   (yi_q16),
	.iter (iter_q16),
	.d1   (d1_q16),
	.d2   (d2_q16),
	.d3   (d3_q16),
	.d4   (d4_q16),
	.neg  (neg_q16),
	.xo   (xo_q16),
	.yo   (yo_q16)
);

GR Q17_inst (
	.nop  (nop_q17),
	.xi   (xi_q17),
	.yi   (yi_q17),
	.iter (iter_q17),
	.d1   (d1_q17),
	.d2   (d2_q17),
	.d3   (d3_q17),
	.d4   (d4_q17),
	.neg  (neg_q17),
	.xo   (xo_q17),
	.yo   (yo_q17)
);

GR Q18_inst (
	.nop  (nop_q18),
	.xi   (xi_q18),
	.yi   (yi_q18),
	.iter (iter_q18),
	.d1   (d1_q18),
	.d2   (d2_q18),
	.d3   (d3_q18),
	.d4   (d4_q18),
	.neg  (neg_q18),
	.xo   (xo_q18),
	.yo   (yo_q18)
);

GR Q21_inst (
	.nop  (nop_q21),
	.xi   (xi_q21),
	.yi   (yi_q21),
	.iter (iter_q21),
	.d1   (d1_q21),
	.d2   (d2_q21),
	.d3   (d3_q21),
	.d4   (d4_q21),
	.neg  (neg_q21),
	.xo   (xo_q21),
	.yo   (yo_q21)
);

GR Q22_inst (
	.nop  (nop_q22),
	.xi   (xi_q22),
	.yi   (yi_q22),
	.iter (iter_q22),
	.d1   (d1_q22),
	.d2   (d2_q22),
	.d3   (d3_q22),
	.d4   (d4_q22),
	.neg  (neg_q22),
	.xo   (xo_q22),
	.yo   (yo_q22)
);

GR Q23_inst (
	.nop  (nop_q23),
	.xi   (xi_q23),
	.yi   (yi_q23),
	.iter (iter_q23),
	.d1   (d1_q23),
	.d2   (d2_q23),
	.d3   (d3_q23),
	.d4   (d4_q23),
	.neg  (neg_q23),
	.xo   (xo_q23),
	.yo   (yo_q23)
);

GR Q24_inst (
	.nop  (nop_q24),
	.xi   (xi_q24),
	.yi   (yi_q24),
	.iter (iter_q24),
	.d1   (d1_q24),
	.d2   (d2_q24),
	.d3   (d3_q24),
	.d4   (d4_q24),
	.neg  (neg_q24),
	.xo   (xo_q24),
	.yo   (yo_q24)
);

GR Q25_inst (
	.nop  (nop_q25),
	.xi   (xi_q25),
	.yi   (yi_q25),
	.iter (iter_q25),
	.d1   (d1_q25),
	.d2   (d2_q25),
	.d3   (d3_q25),
	.d4   (d4_q25),
	.neg  (neg_q25),
	.xo   (xo_q25),
	.yo   (yo_q25)
);

GR Q26_inst (
	.nop  (nop_q26),
	.xi   (xi_q26),
	.yi   (yi_q26),
	.iter (iter_q26),
	.d1   (d1_q26),
	.d2   (d2_q26),
	.d3   (d3_q26),
	.d4   (d4_q26),
	.neg  (neg_q26),
	.xo   (xo_q26),
	.yo   (yo_q26)
);

GR Q27_inst (
	.nop  (nop_q27),
	.xi   (xi_q27),
	.yi   (yi_q27),
	.iter (iter_q27),
	.d1   (d1_q27),
	.d2   (d2_q27),
	.d3   (d3_q27),
	.d4   (d4_q27),
	.neg  (neg_q27),
	.xo   (xo_q27),
	.yo   (yo_q27)
);

GR Q28_inst (
	.nop  (nop_q28),
	.xi   (xi_q28),
	.yi   (yi_q28),
	.iter (iter_q28),
	.d1   (d1_q28),
	.d2   (d2_q28),
	.d3   (d3_q28),
	.d4   (d4_q28),
	.neg  (neg_q28),
	.xo   (xo_q28),
	.yo   (yo_q28)
);

GR Q31_inst (
	.nop  (nop_q31),
	.xi   (xi_q31),
	.yi   (yi_q31),
	.iter (iter_q31),
	.d1   (d1_q31),
	.d2   (d2_q31),
	.d3   (d3_q31),
	.d4   (d4_q31),
	.neg  (neg_q31),
	.xo   (xo_q31),
	.yo   (yo_q31)
);

GR Q32_inst (
	.nop  (nop_q32),
	.xi   (xi_q32),
	.yi   (yi_q32),
	.iter (iter_q32),
	.d1   (d1_q32),
	.d2   (d2_q32),
	.d3   (d3_q32),
	.d4   (d4_q32),
	.neg  (neg_q32),
	.xo   (xo_q32),
	.yo   (yo_q32)
);

GR Q33_inst (
	.nop  (nop_q33),
	.xi   (xi_q33),
	.yi   (yi_q33),
	.iter (iter_q33),
	.d1   (d1_q33),
	.d2   (d2_q33),
	.d3   (d3_q33),
	.d4   (d4_q33),
	.neg  (neg_q33),
	.xo   (xo_q33),
	.yo   (yo_q33)
);

GR Q34_inst (
	.nop  (nop_q34),
	.xi   (xi_q34),
	.yi   (yi_q34),
	.iter (iter_q34),
	.d1   (d1_q34),
	.d2   (d2_q34),
	.d3   (d3_q34),
	.d4   (d4_q34),
	.neg  (neg_q34),
	.xo   (xo_q34),
	.yo   (yo_q34)
);

GR Q35_inst (
	.nop  (nop_q35),
	.xi   (xi_q35),
	.yi   (yi_q35),
	.iter (iter_q35),
	.d1   (d1_q35),
	.d2   (d2_q35),
	.d3   (d3_q35),
	.d4   (d4_q35),
	.neg  (neg_q35),
	.xo   (xo_q35),
	.yo   (yo_q35)
);

GR Q36_inst (
	.nop  (nop_q36),
	.xi   (xi_q36),
	.yi   (yi_q36),
	.iter (iter_q36),
	.d1   (d1_q36),
	.d2   (d2_q36),
	.d3   (d3_q36),
	.d4   (d4_q36),
	.neg  (neg_q36),
	.xo   (xo_q36),
	.yo   (yo_q36)
);

GR Q37_inst (
	.nop  (nop_q37),
	.xi   (xi_q37),
	.yi   (yi_q37),
	.iter (iter_q37),
	.d1   (d1_q37),
	.d2   (d2_q37),
	.d3   (d3_q37),
	.d4   (d4_q37),
	.neg  (neg_q37),
	.xo   (xo_q37),
	.yo   (yo_q37)
);

GR Q38_inst (
	.nop  (nop_q38),
	.xi   (xi_q38),
	.yi   (yi_q38),
	.iter (iter_q38),
	.d1   (d1_q38),
	.d2   (d2_q38),
	.d3   (d3_q38),
	.d4   (d4_q38),
	.neg  (neg_q38),
	.xo   (xo_q38),
	.yo   (yo_q38)
);

GR Q41_inst (
	.nop  (nop_q41),
	.xi   (xi_q41),
	.yi   (yi_q41),
	.iter (iter_q41),
	.d1   (d1_q41),
	.d2   (d2_q41),
	.d3   (d3_q41),
	.d4   (d4_q41),
	.neg  (neg_q41),
	.xo   (xo_q41),
	.yo   (yo_q41)
);

GR Q42_inst (
	.nop  (nop_q42),
	.xi   (xi_q42),
	.yi   (yi_q42),
	.iter (iter_q42),
	.d1   (d1_q42),
	.d2   (d2_q42),
	.d3   (d3_q42),
	.d4   (d4_q42),
	.neg  (neg_q42),
	.xo   (xo_q42),
	.yo   (yo_q42)
);

GR Q43_inst (
	.nop  (nop_q43),
	.xi   (xi_q43),
	.yi   (yi_q43),
	.iter (iter_q43),
	.d1   (d1_q43),
	.d2   (d2_q43),
	.d3   (d3_q43),
	.d4   (d4_q43),
	.neg  (neg_q43),
	.xo   (xo_q43),
	.yo   (yo_q43)
);

GR Q44_inst (
	.nop  (nop_q44),
	.xi   (xi_q44),
	.yi   (yi_q44),
	.iter (iter_q44),
	.d1   (d1_q44),
	.d2   (d2_q44),
	.d3   (d3_q44),
	.d4   (d4_q44),
	.neg  (neg_q44),
	.xo   (xo_q44),
	.yo   (yo_q44)
);

GR Q45_inst (
	.nop  (nop_q45),
	.xi   (xi_q45),
	.yi   (yi_q45),
	.iter (iter_q45),
	.d1   (d1_q45),
	.d2   (d2_q45),
	.d3   (d3_q45),
	.d4   (d4_q45),
	.neg  (neg_q45),
	.xo   (xo_q45),
	.yo   (yo_q45)
);

GR Q46_inst (
	.nop  (nop_q46),
	.xi   (xi_q46),
	.yi   (yi_q46),
	.iter (iter_q46),
	.d1   (d1_q46),
	.d2   (d2_q46),
	.d3   (d3_q46),
	.d4   (d4_q46),
	.neg  (neg_q46),
	.xo   (xo_q46),
	.yo   (yo_q46)
);

GR Q47_inst (
	.nop  (nop_q47),
	.xi   (xi_q47),
	.yi   (yi_q47),
	.iter (iter_q47),
	.d1   (d1_q47),
	.d2   (d2_q47),
	.d3   (d3_q47),
	.d4   (d4_q47),
	.neg  (neg_q47),
	.xo   (xo_q47),
	.yo   (yo_q47)
);

GR Q48_inst (
	.nop  (nop_q48),
	.xi   (xi_q48),
	.yi   (yi_q48),
	.iter (iter_q48),
	.d1   (d1_q48),
	.d2   (d2_q48),
	.d3   (d3_q48),
	.d4   (d4_q48),
	.neg  (neg_q48),
	.xo   (xo_q48),
	.yo   (yo_q48)
);


MK MK1_Q_inst (
	.xi (xi_mk1_q),
	.yi (yi_mk1_q),
	.xo (xo_mk1_q),
	.yo (yo_mk1_q)
);

MK MK2_Q_inst (
	.xi (xi_mk2_q),
	.yi (yi_mk2_q),
	.xo (xo_mk2_q),
	.yo (yo_mk2_q)
);

MK MK3_Q_inst (
	.xi (xi_mk3_q),
	.yi (yi_mk3_q),
	.xo (xo_mk3_q),
	.yo (yo_mk3_q)
);

MK MK4_Q_inst (
	.xi (xi_mk4),
	.yi (yi_mk4),
	.xo (xo_mk4),
	.yo (yo_mk4)
);



endmodule
