`include "GG.v"
`include "GR.v"
`include "Q.v"
`include "MK.v"

module qr_cordic #(
	parameter A_WID 	= 8, 	parameter A_FRAC 	= 0,
	parameter R_WID 	= 12, 	parameter R_FRAC 	= 2,
	parameter Q_WID 	= 12,	parameter Q_FRAC 	= 10,
	parameter K_WID 	= 10,	parameter K_FRAC 	= 9,
	
	parameter ROW_WID_R	= 3,	parameter COL_WID_R	= 2,
	parameter ROW_WID_Q	= 3,	parameter COL_WID_Q	= 3,
	parameter ROW_NUM_R = 8,	parameter COL_NUM_R = 4,
	parameter ROW_NUM_Q = 8,	parameter COL_NUM_Q = 8,
	
	parameter ITER_NUM 	= 8,	parameter ITER_K 	= 9, 	parameter ITER_ONE_CYCLE = 4,
	parameter ITER_WID 	= 4
)
(	input 	   	      	                     clk,
	input 	   	      	                     rst,
	input 	   	      	                     en,
				
	output	   	      	                    rd_A,
	input 	   	signed	[A_WID-1:0]        	rd_A_data,
	output	reg	      	[ROW_WID_R-1:0]    	rd_A_row_addr,
	output	reg	      	[COL_WID_R-1:0]    	rd_A_col_addr,
					
	output	reg	      	                   	wr_R,
	output	reg	signed	[R_WID-1:0]        	wr_R_data,
	output	reg	      	[ROW_WID_R-1:0]    	wr_R_row_addr,
	output	reg	      	[COL_WID_R-1:0]    	wr_R_col_addr,
	
	// Store data separately for each row as multiple records may be output simultaneously
	output           	                	wr_Q_1, wr_Q_2, wr_Q_3, wr_Q_4, wr_Q_5, wr_Q_6, wr_Q_7, wr_Q_8, 
	output 	   	signed	[Q_WID-1:0]        	wr_Q_data_1, wr_Q_data_2, wr_Q_data_3, wr_Q_data_4, wr_Q_data_5, wr_Q_data_6, wr_Q_data_7, wr_Q_data_8, 
	output 	reg	       	[COL_WID_Q-1:0]    	wr_Q_addr_1, wr_Q_addr_2, wr_Q_addr_3, wr_Q_addr_4, wr_Q_addr_5, wr_Q_addr_6, wr_Q_addr_7, wr_Q_addr_8, 
	
	output 	                              	done
);

// extend INT-8 input into 12b (signed: 1b, int: 9b, fraction: 2b)
wire [R_WID-1:0] rd_A_data_ext = {rd_A_data[7], rd_A_data[7], rd_A_data, 2'b00};

/***********************************************************************************/
/**                           Signals of other module                             **/
/***********************************************************************************/
// GG1
reg		signed 	[R_WID-1:0]         xi_gg1;
reg		signed 	[R_WID-1:0]         yi_gg1;
reg 	       	[ITER_WID-1:0]      iter_gg1;
wire	       	[1:0]               d1_gg1;
wire	       	[1:0]				d2_gg1;
wire	       	[1:0]				d3_gg1;
wire	       	[1:0]				d4_gg1;
wire	       	                    neg_gg1;
wire	signed 	[R_WID-1:0]         xo_gg1;
wire	signed 	[R_WID-1:0]         yo_gg1;

// GR11
reg 	                            nop_gr11;
reg 	signed	[R_WID-1:0]         xi_gr11;
reg 	signed	[R_WID-1:0]         yi_gr11;
reg 	      	[ITER_WID-1:0]      iter_gr11;
reg 	      	[1:0]               d1_gr11;
reg 	      	[1:0]				d2_gr11;
reg 	      	[1:0]				d3_gr11;
reg 	      	[1:0]				d4_gr11;
reg 	                            neg_gr11;
wire	signed 	[R_WID-1:0]         xo_gr11;
wire	signed 	[R_WID-1:0]         yo_gr11;

// GR12
reg 	                            nop_gr12;
reg 	signed	[R_WID-1:0]         xi_gr12;
reg 	signed	[R_WID-1:0]         yi_gr12;
reg 	      	[ITER_WID-1:0]      iter_gr12;
reg 	      	[1:0]               d1_gr12;
reg 	      	[1:0]				d2_gr12;
reg 	      	[1:0]				d3_gr12;
reg 	      	[1:0]				d4_gr12;
reg 	                           	neg_gr12;
wire	signed 	[R_WID-1:0]         xo_gr12;
wire	signed 	[R_WID-1:0]         yo_gr12;

// GR13
reg  	                          	nop_gr13;
reg 	signed	[R_WID-1:0]         xi_gr13;
reg 	signed	[R_WID-1:0]         yi_gr13;
reg 	      	[ITER_WID-1:0]      iter_gr13;
reg 	      	[1:0]               d1_gr13;
reg 	      	[1:0]				d2_gr13;
reg 	      	[1:0]				d3_gr13;
reg 	      	[1:0]				d4_gr13;
reg 	                            neg_gr13;
wire	signed 	[R_WID-1:0]         xo_gr13;
wire	signed 	[R_WID-1:0]         yo_gr13;

// GG2
reg     signed 	[R_WID-1:0]         xi_gg2;
reg     signed 	[R_WID-1:0]         yi_gg2;
reg            	[ITER_WID-1:0]      iter_gg2;
wire           	[1:0]               d1_gg2;
wire           	[1:0]				d2_gg2;
wire           	[1:0]				d3_gg2;
wire           	[1:0]				d4_gg2;
wire           	                    neg_gg2;
wire    signed 	[R_WID-1:0]         xo_gg2;
wire    signed 	[R_WID-1:0]         yo_gg2;

// GR21
reg                                 nop_gr21;
reg     signed	[R_WID-1:0]         xi_gr21;
reg     signed	[R_WID-1:0]         yi_gr21;
reg           	[ITER_WID-1:0]      iter_gr21;
reg           	[1:0]               d1_gr21;
reg           	[1:0]				d2_gr21;
reg           	[1:0]				d3_gr21;
reg           	[1:0]				d4_gr21;
reg                                 neg_gr21;
wire    signed 	[R_WID-1:0]         xo_gr21;
wire    signed 	[R_WID-1:0]         yo_gr21;

// GR22
reg                                 nop_gr22;
reg     signed 	[R_WID-1:0]         xi_gr22;
reg     signed 	[R_WID-1:0]         yi_gr22;
reg            	[ITER_WID-1:0]      iter_gr22;
reg            	[1:0]               d1_gr22;
reg            	[1:0]				d2_gr22;
reg           	[1:0]				d3_gr22;
reg           	[1:0]				d4_gr22;
reg            	                    neg_gr22;
wire    signed 	[R_WID-1:0]         xo_gr22;
wire    signed 	[R_WID-1:0]         yo_gr22;

// GG3
reg     signed 	[R_WID-1:0]         xi_gg3;
reg     signed 	[R_WID-1:0]         yi_gg3;
reg            	[ITER_WID-1:0]      iter_gg3;
wire           	[1:0]               d1_gg3;
wire           	[1:0]				d2_gg3;
wire           	[1:0]				d3_gg3;
wire           	[1:0]				d4_gg3;
wire           	                    neg_gg3;
wire    signed 	[R_WID-1:0]         xo_gg3;
wire    signed 	[R_WID-1:0]         yo_gg3;

// GR31
reg                                 nop_gr31;
reg     signed 	[R_WID-1:0]         xi_gr31;
reg     signed 	[R_WID-1:0]         yi_gr31;
reg            	[ITER_WID-1:0]      iter_gr31;
reg            	[1:0]               d1_gr31;
reg            	[1:0]				d2_gr31;
reg           	[1:0]				d3_gr31;
reg           	[1:0]				d4_gr31;
reg            	                    neg_gr31;
wire    signed 	[R_WID-1:0]         xo_gr31;
wire    signed 	[R_WID-1:0]         yo_gr31;

// GG4
reg     signed 	[R_WID-1:0]         xi_gg4;
reg     signed 	[R_WID-1:0]         yi_gg4;
reg            	[ITER_WID-1:0]      iter_gg4;
wire           	[1:0]               d1_gg4;
wire           	[1:0]				d2_gg4;
wire           	[1:0]				d3_gg4;
wire           	[1:0]				d4_gg4;
wire           	                    neg_gg4;
wire    signed 	[R_WID-1:0]         xo_gg4;
wire    signed 	[R_WID-1:0]         yo_gg4;

// Q11
reg                                 nop_q11;
reg     signed 	[Q_WID-1:0]         xi_q11;
reg     signed 	[Q_WID-1:0]         yi_q11;
reg            	[ITER_WID-1:0]      iter_q11;
reg            	[1:0]               d1_q11;
reg            	[1:0]				d2_q11;
reg           	[1:0]				d3_q11;
reg           	[1:0]				d4_q11;
reg            	                    neg_q11;
wire    signed 	[Q_WID-1:0]         xo_q11;
wire    signed 	[Q_WID-1:0]         yo_q11;

// Q12
reg                                 nop_q12;
reg     signed 	[Q_WID-1:0]         xi_q12;
reg     signed 	[Q_WID-1:0]         yi_q12;
reg            	[ITER_WID-1:0]      iter_q12;
reg            	[1:0]               d1_q12;
reg            	[1:0]				d2_q12;
reg           	[1:0]				d3_q12;
reg           	[1:0]				d4_q12;
reg            	                    neg_q12;
wire    signed 	[Q_WID-1:0]         xo_q12;
wire    signed 	[Q_WID-1:0]         yo_q12;

// Q13
reg                                 nop_q13;
reg     signed 	[Q_WID-1:0]         xi_q13;
reg     signed 	[Q_WID-1:0]         yi_q13;
reg            	[ITER_WID-1:0]      iter_q13;
reg            	[1:0]               d1_q13;
reg            	[1:0]				d2_q13;
reg           	[1:0]				d3_q13;
reg           	[1:0]				d4_q13;
reg            	                    neg_q13;
wire    signed 	[Q_WID-1:0]         xo_q13;
wire    signed 	[Q_WID-1:0]         yo_q13;

// Q14
reg                                 nop_q14;
reg     signed 	[Q_WID-1:0]         xi_q14;
reg     signed 	[Q_WID-1:0]         yi_q14;
reg            	[ITER_WID-1:0]      iter_q14;
reg            	[1:0]               d1_q14;
reg            	[1:0]				d2_q14;
reg           	[1:0]				d3_q14;
reg           	[1:0]				d4_q14;
reg            	                    neg_q14;
wire    signed 	[Q_WID-1:0]         xo_q14;
wire    signed 	[Q_WID-1:0]         yo_q14;

// Q15
reg                                 nop_q15;
reg     signed 	[Q_WID-1:0]         xi_q15;
reg     signed 	[Q_WID-1:0]         yi_q15;
reg            	[ITER_WID-1:0]      iter_q15;
reg            	[1:0]               d1_q15;
reg            	[1:0]				d2_q15;
reg           	[1:0]				d3_q15;
reg           	[1:0]				d4_q15;
reg            	                    neg_q15;
wire    signed 	[Q_WID-1:0]         xo_q15;
wire    signed 	[Q_WID-1:0]         yo_q15;

// Q16
reg                                 nop_q16;
reg     signed 	[Q_WID-1:0]         xi_q16;
reg     signed 	[Q_WID-1:0]         yi_q16;
reg            	[ITER_WID-1:0]      iter_q16;
reg            	[1:0]               d1_q16;
reg            	[1:0]				d2_q16;
reg           	[1:0]				d3_q16;
reg           	[1:0]				d4_q16;
reg            	                    neg_q16;
wire    signed 	[Q_WID-1:0]         xo_q16;
wire    signed 	[Q_WID-1:0]         yo_q16;

// Q17
reg                                 nop_q17;
reg     signed 	[Q_WID-1:0]         xi_q17;
reg     signed 	[Q_WID-1:0]         yi_q17;
reg            	[ITER_WID-1:0]      iter_q17;
reg            	[1:0]               d1_q17;
reg            	[1:0]				d2_q17;
reg           	[1:0]				d3_q17;
reg           	[1:0]				d4_q17;
reg            	                    neg_q17;
wire    signed 	[Q_WID-1:0]         xo_q17;
wire    signed 	[Q_WID-1:0]         yo_q17;

// Q18
reg                                 nop_q18;
reg     signed 	[Q_WID-1:0]         xi_q18;
reg     signed 	[Q_WID-1:0]         yi_q18;
reg            	[ITER_WID-1:0]      iter_q18;
reg            	[1:0]               d1_q18;
reg            	[1:0]				d2_q18;
reg           	[1:0]				d3_q18;
reg           	[1:0]				d4_q18;
reg            	                    neg_q18;
wire    signed 	[Q_WID-1:0]         xo_q18;
wire    signed 	[Q_WID-1:0]         yo_q18;

// Q21
reg                                 nop_q21;
reg     signed 	[Q_WID-1:0]         xi_q21;
reg     signed 	[Q_WID-1:0]         yi_q21;
reg            	[ITER_WID-1:0]      iter_q21;
reg            	[1:0]               d1_q21;
reg           	[1:0]				d2_q21;
reg           	[1:0]				d3_q21;
reg           	[1:0]				d4_q21;
reg            	                    neg_q21;
wire    signed 	[Q_WID-1:0]         xo_q21;
wire    signed 	[Q_WID-1:0]         yo_q21;

// Q22
reg                                 nop_q22;
reg     signed 	[Q_WID-1:0]         xi_q22;
reg     signed 	[Q_WID-1:0]         yi_q22;
reg            	[ITER_WID-1:0]      iter_q22;
reg            	[1:0]               d1_q22;
reg            	[1:0]				d2_q22;
reg           	[1:0]				d3_q22;
reg           	[1:0]				d4_q22;
reg            	                    neg_q22;
wire    signed 	[Q_WID-1:0]         xo_q22;
wire    signed 	[Q_WID-1:0]         yo_q22;

// Q23
reg                                 nop_q23;
reg     signed 	[Q_WID-1:0]         xi_q23;
reg     signed 	[Q_WID-1:0]         yi_q23;
reg            	[ITER_WID-1:0]      iter_q23;
reg            	[1:0]               d1_q23;
reg            	[1:0]				d2_q23;
reg           	[1:0]				d3_q23;
reg           	[1:0]				d4_q23;
reg            	                    neg_q23;
wire    signed 	[Q_WID-1:0]         xo_q23;
wire    signed 	[Q_WID-1:0]         yo_q23;

// Q24
reg                                 nop_q24;
reg     signed 	[Q_WID-1:0]         xi_q24;
reg     signed 	[Q_WID-1:0]         yi_q24;
reg            	[ITER_WID-1:0]      iter_q24;
reg            	[1:0]               d1_q24;
reg            	[1:0]				d2_q24;
reg           	[1:0]				d3_q24;
reg           	[1:0]				d4_q24;
reg            	                    neg_q24;
wire    signed 	[Q_WID-1:0]         xo_q24;
wire    signed 	[Q_WID-1:0]         yo_q24;

// Q25
reg                                 nop_q25;
reg     signed 	[Q_WID-1:0]         xi_q25;
reg     signed 	[Q_WID-1:0]         yi_q25;
reg            	[ITER_WID-1:0]      iter_q25;
reg            	[1:0]               d1_q25;
reg            	[1:0]				d2_q25;
reg           	[1:0]				d3_q25;
reg           	[1:0]				d4_q25;
reg            	                    neg_q25;
wire    signed 	[Q_WID-1:0]         xo_q25;
wire    signed 	[Q_WID-1:0]         yo_q25;

// Q26
reg                                 nop_q26;
reg     signed 	[Q_WID-1:0]         xi_q26;
reg     signed 	[Q_WID-1:0]         yi_q26;
reg            	[ITER_WID-1:0]      iter_q26;
reg            	[1:0]               d1_q26;
reg            	[1:0]				d2_q26;
reg           	[1:0]				d3_q26;
reg           	[1:0]				d4_q26;
reg            	                    neg_q26;
wire    signed 	[Q_WID-1:0]         xo_q26;
wire    signed 	[Q_WID-1:0]         yo_q26;

// Q27
reg                                 nop_q27;
reg     signed 	[Q_WID-1:0]         xi_q27;
reg     signed 	[Q_WID-1:0]         yi_q27;
reg            	[ITER_WID-1:0]      iter_q27;
reg            	[1:0]               d1_q27;
reg            	[1:0]				d2_q27;
reg           	[1:0]				d3_q27;
reg           	[1:0]				d4_q27;
reg            	                    neg_q27;
wire    signed 	[Q_WID-1:0]         xo_q27;
wire    signed 	[Q_WID-1:0]         yo_q27;

// Q28
reg                                 nop_q28;
reg     signed 	[Q_WID-1:0]         xi_q28;
reg     signed 	[Q_WID-1:0]         yi_q28;
reg            	[ITER_WID-1:0]      iter_q28;
reg            	[1:0]               d1_q28;
reg            	[1:0]				d2_q28;
reg           	[1:0]				d3_q28;
reg           	[1:0]				d4_q28;
reg            	                    neg_q28;
wire    signed 	[Q_WID-1:0]         xo_q28;
wire    signed 	[Q_WID-1:0]         yo_q28;

// Q31
reg                                 nop_q31;
reg     signed 	[Q_WID-1:0]         xi_q31;
reg     signed 	[Q_WID-1:0]         yi_q31;
reg            	[ITER_WID-1:0]      iter_q31;
reg            	[1:0]               d1_q31;
reg            	[1:0]				d2_q31;
reg           	[1:0]				d3_q31;
reg           	[1:0]				d4_q31;
reg            	                    neg_q31;
wire    signed 	[Q_WID-1:0]         xo_q31;
wire    signed 	[Q_WID-1:0]         yo_q31;

// Q32
reg                                 nop_q32;
reg     signed 	[Q_WID-1:0]         xi_q32;
reg     signed 	[Q_WID-1:0]         yi_q32;
reg            	[ITER_WID-1:0]      iter_q32;
reg            	[1:0]               d1_q32;
reg            	[1:0]				d2_q32;
reg           	[1:0]				d3_q32;
reg           	[1:0]				d4_q32;
reg            	                    neg_q32;
wire    signed 	[Q_WID-1:0]         xo_q32;
wire    signed 	[Q_WID-1:0]         yo_q32;

// Q33
reg                                 nop_q33;
reg     signed 	[Q_WID-1:0]         xi_q33;
reg     signed 	[Q_WID-1:0]         yi_q33;
reg            	[ITER_WID-1:0]      iter_q33;
reg            	[1:0]               d1_q33;
reg            	[1:0]				d2_q33;
reg           	[1:0]				d3_q33;
reg           	[1:0]				d4_q33;
reg            	                    neg_q33;
wire    signed 	[Q_WID-1:0]         xo_q33;
wire    signed 	[Q_WID-1:0]         yo_q33;

// Q34
reg                                 nop_q34;
reg     signed 	[Q_WID-1:0]         xi_q34;
reg     signed 	[Q_WID-1:0]         yi_q34;
reg            	[ITER_WID-1:0]      iter_q34;
reg            	[1:0]               d1_q34;
reg            	[1:0]				d2_q34;
reg           	[1:0]				d3_q34;
reg           	[1:0]				d4_q34;
reg            	                    neg_q34;
wire    signed 	[Q_WID-1:0]         xo_q34;
wire    signed 	[Q_WID-1:0]         yo_q34;

// Q35
reg                                 nop_q35;
reg     signed 	[Q_WID-1:0]         xi_q35;
reg     signed 	[Q_WID-1:0]         yi_q35;
reg            	[ITER_WID-1:0]      iter_q35;
reg            	[1:0]               d1_q35;
reg            	[1:0]				d2_q35;
reg           	[1:0]				d3_q35;
reg           	[1:0]				d4_q35;
reg            	                    neg_q35;
wire    signed 	[Q_WID-1:0]         xo_q35;
wire    signed 	[Q_WID-1:0]         yo_q35;

// Q36
reg                                 nop_q36;
reg     signed 	[Q_WID-1:0]         xi_q36;
reg     signed 	[Q_WID-1:0]         yi_q36;
reg            	[ITER_WID-1:0]      iter_q36;
reg            	[1:0]               d1_q36;
reg            	[1:0]				d2_q36;
reg           	[1:0]				d3_q36;
reg           	[1:0]				d4_q36;
reg            	                    neg_q36;
wire    signed 	[Q_WID-1:0]         xo_q36;
wire    signed 	[Q_WID-1:0]         yo_q36;

// Q37
reg                                 nop_q37;
reg     signed 	[Q_WID-1:0]         xi_q37;
reg     signed 	[Q_WID-1:0]         yi_q37;
reg            	[ITER_WID-1:0]      iter_q37;
reg            	[1:0]               d1_q37;
reg            	[1:0]				d2_q37;
reg           	[1:0]				d3_q37;
reg           	[1:0]				d4_q37;
reg            	                    neg_q37;
wire    signed 	[Q_WID-1:0]         xo_q37;
wire    signed 	[Q_WID-1:0]         yo_q37;

// Q38
reg                                 nop_q38;
reg     signed 	[Q_WID-1:0]         xi_q38;
reg     signed 	[Q_WID-1:0]         yi_q38;
reg            	[ITER_WID-1:0]      iter_q38;
reg            	[1:0]               d1_q38;
reg            	[1:0]				d2_q38;
reg           	[1:0]				d3_q38;
reg           	[1:0]				d4_q38;
reg            	                    neg_q38;
wire    signed 	[Q_WID-1:0]         xo_q38;
wire    signed 	[Q_WID-1:0]         yo_q38;

// Q41
reg                                 nop_q41;
reg     signed 	[Q_WID-1:0]         xi_q41;
reg     signed 	[Q_WID-1:0]         yi_q41;
reg            	[ITER_WID-1:0]      iter_q41;
reg            	[1:0]               d1_q41;
reg            	[1:0]				d2_q41;
reg           	[1:0]				d3_q41;
reg           	[1:0]				d4_q41;
reg            	                    neg_q41;
wire    signed 	[Q_WID-1:0]         xo_q41;
wire    signed 	[Q_WID-1:0]         yo_q41;

// Q42
reg                                 nop_q42;
reg     signed 	[Q_WID-1:0]         xi_q42;
reg     signed 	[Q_WID-1:0]         yi_q42;
reg            	[ITER_WID-1:0]      iter_q42;
reg            	[1:0]               d1_q42;
reg            	[1:0]				d2_q42;
reg           	[1:0]				d3_q42;
reg           	[1:0]				d4_q42;
reg            	                    neg_q42;
wire    signed 	[Q_WID-1:0]         xo_q42;
wire    signed 	[Q_WID-1:0]         yo_q42;

// Q43
reg                                 nop_q43;
reg     signed 	[Q_WID-1:0]         xi_q43;
reg     signed 	[Q_WID-1:0]         yi_q43;
reg            	[ITER_WID-1:0]      iter_q43;
reg            	[1:0]               d1_q43;
reg            	[1:0]				d2_q43;
reg           	[1:0]				d3_q43;
reg           	[1:0]				d4_q43;
reg            	                    neg_q43;
wire    signed 	[Q_WID-1:0]         xo_q43;
wire    signed 	[Q_WID-1:0]         yo_q43;

// Q44
reg                                 nop_q44;
reg     signed 	[Q_WID-1:0]         xi_q44;
reg     signed 	[Q_WID-1:0]         yi_q44;
reg            	[ITER_WID-1:0]      iter_q44;
reg            	[1:0]               d1_q44;
reg            	[1:0]				d2_q44;
reg           	[1:0]				d3_q44;
reg           	[1:0]				d4_q44;
reg            	                    neg_q44;
wire    signed 	[Q_WID-1:0]         xo_q44;
wire    signed 	[Q_WID-1:0]         yo_q44;

// Q45
reg                                 nop_q45;
reg     signed 	[Q_WID-1:0]         xi_q45;
reg     signed 	[Q_WID-1:0]         yi_q45;
reg            	[ITER_WID-1:0]      iter_q45;
reg            	[1:0]               d1_q45;
reg            	[1:0]				d2_q45;
reg           	[1:0]				d3_q45;
reg           	[1:0]				d4_q45;
reg            	                    neg_q45;
wire    signed 	[Q_WID-1:0]         xo_q45;
wire    signed 	[Q_WID-1:0]         yo_q45;

// Q46
reg                                 nop_q46;
reg     signed 	[Q_WID-1:0]         xi_q46;
reg     signed 	[Q_WID-1:0]         yi_q46;
reg            	[ITER_WID-1:0]      iter_q46;
reg            	[1:0]               d1_q46;
reg            	[1:0]				d2_q46;
reg           	[1:0]				d3_q46;
reg           	[1:0]				d4_q46;
reg            	                    neg_q46;
wire    signed 	[Q_WID-1:0]         xo_q46;
wire    signed 	[Q_WID-1:0]         yo_q46;

// Q47
reg                                 nop_q47;
reg     signed 	[Q_WID-1:0]         xi_q47;
reg     signed 	[Q_WID-1:0]         yi_q47;
reg            	[ITER_WID-1:0]      iter_q47;
reg            	[1:0]               d1_q47;
reg            	[1:0]				d2_q47;
reg           	[1:0]				d3_q47;
reg           	[1:0]				d4_q47;
reg            	                    neg_q47;
wire    signed 	[Q_WID-1:0]         xo_q47;
wire    signed 	[Q_WID-1:0]         yo_q47;

// Q48
reg                                 nop_q48;
reg     signed 	[Q_WID-1:0]         xi_q48;
reg     signed 	[Q_WID-1:0]         yi_q48;
reg            	[ITER_WID-1:0]      iter_q48;
reg            	[1:0]               d1_q48;
reg            	[1:0]				d2_q48;
reg           	[1:0]				d3_q48;
reg           	[1:0]				d4_q48;
reg            	                    neg_q48;
wire    signed 	[Q_WID-1:0]         xo_q48;
wire    signed 	[Q_WID-1:0]         yo_q48;

// MK1_R
reg     signed	[R_WID-1:0]         xi_mk1;
reg     signed	[R_WID-1:0]         yi_mk1;
wire    signed	[R_WID-1:0]         xo_mk1;
wire    signed	[R_WID-1:0]         yo_mk1;
	
// MK2_R	
reg     signed	[R_WID-1:0]         xi_mk2;
reg     signed	[R_WID-1:0]         yi_mk2;
wire    signed	[R_WID-1:0]         xo_mk2;
wire    signed	[R_WID-1:0]         yo_mk2;
	
// MK3_R	
reg     signed	[R_WID-1:0]         xi_mk3;
reg     signed	[R_WID-1:0]         yi_mk3;
wire    signed	[R_WID-1:0]         xo_mk3;
wire    signed	[R_WID-1:0]         yo_mk3;
	
// MK4_R	
reg     signed	[R_WID-1:0]         xi_mk4;
reg     signed	[R_WID-1:0]         yi_mk4;
wire    signed	[R_WID-1:0]         xo_mk4;
wire    signed	[R_WID-1:0]         yo_mk4;

// Since Q will output multiple data points
// MK1_Q
reg     signed	[Q_WID-1:0]         xi_mk1_q;
reg     signed	[Q_WID-1:0]         yi_mk1_q;
wire    signed	[Q_WID-1:0]         xo_mk1_q;
wire    signed	[Q_WID-1:0]         yo_mk1_q;

// MK2_Q
reg     signed	[Q_WID-1:0]         xi_mk2_q;
reg      signed	[Q_WID-1:0]         yi_mk2_q;
wire     signed	[Q_WID-1:0]         xo_mk2_q;
wire     signed	[Q_WID-1:0]         yo_mk2_q;

// MK3_Q
reg      signed	[Q_WID-1:0]         xi_mk3_q;
reg      signed	[Q_WID-1:0]         yi_mk3_q;
wire     signed	[Q_WID-1:0]         xo_mk3_q;
wire     signed	[Q_WID-1:0]         yo_mk3_q;

// MK4_Q
reg      signed	[Q_WID-1:0]         xi_mk4_q;
reg      signed	[Q_WID-1:0]         yi_mk4_q;
wire     signed	[Q_WID-1:0]         xo_mk4_q;
wire     signed	[Q_WID-1:0]         yo_mk4_q;

// MK5_Q
reg      signed	[Q_WID-1:0]         xi_mk5_q;
reg      signed	[Q_WID-1:0]         yi_mk5_q;
wire     signed	[Q_WID-1:0]         xo_mk5_q;
wire     signed	[Q_WID-1:0]         yo_mk5_q;

// MK6_Q
reg      signed	[Q_WID-1:0]         xi_mk6_q;
reg      signed	[Q_WID-1:0]         yi_mk6_q;
wire     signed	[Q_WID-1:0]         xo_mk6_q;
wire     signed	[Q_WID-1:0]         yo_mk6_q;

// MK7_Q
reg      signed	[Q_WID-1:0]         xi_mk7_q;
reg      signed	[Q_WID-1:0]         yi_mk7_q;
wire     signed	[Q_WID-1:0]         xo_mk7_q;
wire     signed	[Q_WID-1:0]         yo_mk7_q;

// MK8_Q
reg      signed	[Q_WID-1:0]         xi_mk8_q;
reg      signed	[Q_WID-1:0]         yi_mk8_q;
wire     signed	[Q_WID-1:0]         xo_mk8_q;
wire     signed	[Q_WID-1:0]         yo_mk8_q;

/***********************************************************************************/
/**                     state parameters (Only control GG1)                       **/
/***********************************************************************************/
localparam IDLE		= 2'd0;
localparam ROT		= 2'd1;
localparam MUL_K	= 2'd2;
localparam DONE		= 2'd3;


/***********************************************************************************/
/**                                   Registers                                   **/
/***********************************************************************************/
// FSM state signals
reg	[1:0]	state, next_state;

// multiply k counter (rotation times)
reg	[2:0]	mk_count_gg1;
reg	[2:0]	mk_count_gr11;
reg	[2:0]	mk_count_gr12;
reg	[2:0]	mk_count_gr13;
reg	[2:0]	mk_count_gg2;
reg	[2:0]	mk_count_gr21;
reg	[2:0]	mk_count_gr22;
reg	[2:0]	mk_count_gg3;
reg	[2:0]	mk_count_gr31;
reg	[2:0]	mk_count_gg4;
reg	[2:0]	mk_count_q11;
reg	[2:0]	mk_count_q12;
reg	[2:0]	mk_count_q13;
reg	[2:0]	mk_count_q14;
reg	[2:0]	mk_count_q15;
reg	[2:0]	mk_count_q16;
reg	[2:0]	mk_count_q17;
reg	[2:0]	mk_count_q18;
reg	[2:0]	mk_count_q21;
reg	[2:0]	mk_count_q22;
reg	[2:0]	mk_count_q23;
reg	[2:0]	mk_count_q24;
reg	[2:0]	mk_count_q25;
reg	[2:0]	mk_count_q26;
reg	[2:0]	mk_count_q27;
reg	[2:0]	mk_count_q28;
reg	[2:0]	mk_count_q31;
reg	[2:0]	mk_count_q32;
reg	[2:0]	mk_count_q33;
reg	[2:0]	mk_count_q34;
reg	[2:0]	mk_count_q35;
reg	[2:0]	mk_count_q36;
reg	[2:0]	mk_count_q37;
reg	[2:0]	mk_count_q38;
reg	[2:0]	mk_count_q41;
reg	[2:0]	mk_count_q42;
reg	[2:0]	mk_count_q43;
reg	[2:0]	mk_count_q44;
reg	[2:0]	mk_count_q45;
reg	[2:0]	mk_count_q46;
reg	[2:0]	mk_count_q47;
reg	[2:0]	mk_count_q48;

// control signals (reg)
reg start_gr11_reg;
reg start_gr12_reg;
reg start_gr13_reg;
reg start_gr21_reg;
reg start_gr22_reg;
reg start_gr31_reg;
reg start_q11_reg;
reg start_q12_reg;
reg start_q13_reg;
reg start_q14_reg;
reg start_q15_reg;
reg start_q16_reg;
reg start_q17_reg;
reg start_q18_reg;
reg start_q21_reg;
reg start_q22_reg;
reg start_q23_reg;
reg start_q24_reg;
reg start_q25_reg;
reg start_q26_reg;
reg start_q27_reg;
reg start_q28_reg;
reg start_q31_reg;
reg start_q32_reg;
reg start_q33_reg;
reg start_q34_reg;
reg start_q35_reg;
reg start_q36_reg;
reg start_q37_reg;
reg start_q38_reg;
reg start_q41_reg;
reg start_q42_reg;
reg start_q43_reg;
reg start_q44_reg;
reg start_q45_reg;
reg start_q46_reg;
reg start_q47_reg;
reg start_q48_reg;

reg last_multk_gg1_reg;
reg last_multk_gr11_reg; 
reg last_multk_gr12_reg; 
reg last_multk_gr13_reg; 
reg last_multk_gg2_reg; 
reg last_multk_gr21_reg; 
reg last_multk_gr22_reg; 
reg last_multk_gg3_reg; 
reg last_multk_gr31_reg; 
reg last_multk_gg4_reg; 
reg last_multk_q11_reg;
reg last_multk_q12_reg;
reg last_multk_q13_reg;
reg last_multk_q14_reg;
reg last_multk_q15_reg;
reg last_multk_q16_reg;
reg last_multk_q17_reg;
reg last_multk_q18_reg;
reg last_multk_q21_reg;
reg last_multk_q22_reg;
reg last_multk_q23_reg;
reg last_multk_q24_reg;
reg last_multk_q25_reg;
reg last_multk_q26_reg;
reg last_multk_q27_reg;
reg last_multk_q28_reg;
reg last_multk_q31_reg;
reg last_multk_q32_reg;
reg last_multk_q33_reg;
reg last_multk_q34_reg;
reg last_multk_q35_reg;
reg last_multk_q36_reg;
reg last_multk_q37_reg;
reg last_multk_q38_reg;
reg last_multk_q41_reg;
reg last_multk_q42_reg;
reg last_multk_q43_reg;
reg last_multk_q44_reg;
reg last_multk_q45_reg;
reg last_multk_q46_reg;
reg last_multk_q47_reg;
reg last_multk_q48_reg;

reg last_multk_gr31_dly1;
reg last_multk_gg4_dly1;
reg last_multk_gg4_dly2;
reg last_multk_gg4_dly3;

// Q is a ROM stored 8x8 identity matrix
reg signed [Q_WID-1:0] Q_ROM [0:ROW_NUM_Q-1][0:COL_NUM_Q-1];

// numbers stand for row, e.g.: q_col_1 for row1. Use counters to input Q into GG or GR
reg [2:0] q_col_1, q_col_2, q_col_3, q_col_4, q_col_5, q_col_6, q_col_7, q_col_8;

// Q output end flag
reg wr_Q_1_end, wr_Q_2_end, wr_Q_3_end, wr_Q_4_end, wr_Q_5_end, wr_Q_6_end, wr_Q_7_end, wr_Q_8_end;


/***********************************************************************************/
/**                                 Combination                                   **/
/***********************************************************************************/
// state wire for GG1
wire IDLE_wire 	= state == IDLE;      
wire ROT_wire 	= state == ROT;
wire MUL_K_wire = state == MUL_K;  
wire DONE_wire 	= state == DONE;

// control signals
wire initial_read 	= rd_A_row_addr == 'd7 || (rd_A_row_addr == 'd6 && rd_A_col_addr == 'd0);	// at least read 1 row at first
wire rd_A_col_end 	= rd_A_col_addr == 'd3;
wire rd_A_end		= rd_A_row_addr == 'd0 && rd_A_col_end && mk_count_gg1 >= 'd6;

wire start_gg1		= rd_A_row_addr == 'd7 && rd_A_col_addr == 'd0;
wire start_gg2  	= rd_A_row_addr == 'd5 && rd_A_col_addr == 'd1;
wire start_gg3  	= rd_A_row_addr == 'd3 && rd_A_col_addr == 'd2;
wire start_gg4  	= rd_A_row_addr == 'd1 && rd_A_col_addr == 'd3;

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
wire iter_last_q11	= iter_q11  == ITER_NUM;
wire iter_last_q12	= iter_q12  == ITER_NUM;
wire iter_last_q13	= iter_q13  == ITER_NUM;
wire iter_last_q14	= iter_q14  == ITER_NUM;
wire iter_last_q15	= iter_q15  == ITER_NUM;
wire iter_last_q16	= iter_q16  == ITER_NUM;
wire iter_last_q17	= iter_q17  == ITER_NUM;
wire iter_last_q18	= iter_q18  == ITER_NUM;
wire iter_last_q21	= iter_q21  == ITER_NUM;
wire iter_last_q22	= iter_q22  == ITER_NUM;
wire iter_last_q23	= iter_q23  == ITER_NUM;
wire iter_last_q24	= iter_q24  == ITER_NUM;
wire iter_last_q25	= iter_q25  == ITER_NUM;
wire iter_last_q26	= iter_q26  == ITER_NUM;
wire iter_last_q27	= iter_q27  == ITER_NUM;
wire iter_last_q28	= iter_q28  == ITER_NUM;
wire iter_last_q31	= iter_q31  == ITER_NUM;
wire iter_last_q32	= iter_q32  == ITER_NUM;
wire iter_last_q33	= iter_q33  == ITER_NUM;
wire iter_last_q34	= iter_q34  == ITER_NUM;
wire iter_last_q35	= iter_q35  == ITER_NUM;
wire iter_last_q36	= iter_q36  == ITER_NUM;
wire iter_last_q37	= iter_q37  == ITER_NUM;
wire iter_last_q38	= iter_q38  == ITER_NUM;
wire iter_last_q41	= iter_q41  == ITER_NUM;
wire iter_last_q42	= iter_q42  == ITER_NUM;
wire iter_last_q43	= iter_q43  == ITER_NUM;
wire iter_last_q44	= iter_q44  == ITER_NUM;
wire iter_last_q45	= iter_q45  == ITER_NUM;
wire iter_last_q46	= iter_q46  == ITER_NUM;
wire iter_last_q47	= iter_q47  == ITER_NUM;
wire iter_last_q48	= iter_q48  == ITER_NUM;

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
wire multk_q11		= iter_q11  == ITER_K;
wire multk_q12		= iter_q12  == ITER_K;
wire multk_q13		= iter_q13  == ITER_K;
wire multk_q14		= iter_q14  == ITER_K;
wire multk_q15		= iter_q15  == ITER_K;
wire multk_q16		= iter_q16  == ITER_K;
wire multk_q17		= iter_q17  == ITER_K;
wire multk_q18		= iter_q18  == ITER_K;
wire multk_q21		= iter_q21  == ITER_K;
wire multk_q22		= iter_q22  == ITER_K;
wire multk_q23		= iter_q23  == ITER_K;
wire multk_q24		= iter_q24  == ITER_K;
wire multk_q25		= iter_q25  == ITER_K;
wire multk_q26		= iter_q26  == ITER_K;
wire multk_q27		= iter_q27  == ITER_K;
wire multk_q28		= iter_q28  == ITER_K;
wire multk_q31		= iter_q31  == ITER_K;
wire multk_q32		= iter_q32  == ITER_K;
wire multk_q33		= iter_q33  == ITER_K;
wire multk_q34		= iter_q34  == ITER_K;
wire multk_q35		= iter_q35  == ITER_K;
wire multk_q36		= iter_q36  == ITER_K;
wire multk_q37		= iter_q37  == ITER_K;
wire multk_q38		= iter_q38  == ITER_K;
wire multk_q41		= iter_q41  == ITER_K;
wire multk_q42		= iter_q42  == ITER_K;
wire multk_q43		= iter_q43  == ITER_K;
wire multk_q44		= iter_q44  == ITER_K;
wire multk_q45		= iter_q45  == ITER_K;
wire multk_q46		= iter_q46  == ITER_K;
wire multk_q47		= iter_q47  == ITER_K;
wire multk_q48		= iter_q48  == ITER_K;

wire last_multk_gg1	= mk_count_gg1  == 'd6 && multk_gg1;
wire last_multk_gr11= mk_count_gr11 == 'd6 && multk_gr11;
wire last_multk_gr12= mk_count_gr12 == 'd6 && multk_gr12;
wire last_multk_gr13= mk_count_gr13 == 'd6 && multk_gr13;
wire last_multk_gg2 = mk_count_gg2  == 'd5 && multk_gg2;
wire last_multk_gr21= mk_count_gr21 == 'd5 && multk_gr21;
wire last_multk_gr22= mk_count_gr22 == 'd5 && multk_gr22;
wire last_multk_gg3 = mk_count_gg3  == 'd4 && multk_gg3;
wire last_multk_gr31= mk_count_gr31 == 'd4 && multk_gr31;
wire last_multk_gg4 = mk_count_gg4  == 'd3 && multk_gg4;
wire last_multk_q11	= mk_count_q11  == 'd6 && multk_q11;
wire last_multk_q12	= mk_count_q12  == 'd6 && multk_q12;
wire last_multk_q13	= mk_count_q13  == 'd6 && multk_q13;
wire last_multk_q14	= mk_count_q14  == 'd6 && multk_q14;
wire last_multk_q15	= mk_count_q15  == 'd6 && multk_q15;
wire last_multk_q16	= mk_count_q16  == 'd6 && multk_q16;
wire last_multk_q17	= mk_count_q17  == 'd6 && multk_q17;
wire last_multk_q18	= mk_count_q18  == 'd6 && multk_q18;
wire last_multk_q21	= mk_count_q21  == 'd5 && multk_q21;
wire last_multk_q22	= mk_count_q22  == 'd5 && multk_q22;
wire last_multk_q23	= mk_count_q23  == 'd5 && multk_q23;
wire last_multk_q24	= mk_count_q24  == 'd5 && multk_q24;
wire last_multk_q25	= mk_count_q25  == 'd5 && multk_q25;
wire last_multk_q26	= mk_count_q26  == 'd5 && multk_q26;
wire last_multk_q27	= mk_count_q27  == 'd5 && multk_q27;
wire last_multk_q28	= mk_count_q28  == 'd5 && multk_q28;
wire last_multk_q31	= mk_count_q31  == 'd4 && multk_q31;
wire last_multk_q32	= mk_count_q32  == 'd4 && multk_q32;
wire last_multk_q33	= mk_count_q33  == 'd4 && multk_q33;
wire last_multk_q34	= mk_count_q34  == 'd4 && multk_q34;
wire last_multk_q35	= mk_count_q35  == 'd4 && multk_q35;
wire last_multk_q36	= mk_count_q36  == 'd4 && multk_q36;
wire last_multk_q37	= mk_count_q37  == 'd4 && multk_q37;
wire last_multk_q38	= mk_count_q38  == 'd4 && multk_q38;
wire last_multk_q41	= mk_count_q41  == 'd3 && multk_q41;
wire last_multk_q42	= mk_count_q42  == 'd3 && multk_q42;
wire last_multk_q43	= mk_count_q43  == 'd3 && multk_q43;
wire last_multk_q44	= mk_count_q44  == 'd3 && multk_q44;
wire last_multk_q45	= mk_count_q45  == 'd3 && multk_q45;
wire last_multk_q46	= mk_count_q46  == 'd3 && multk_q46;
wire last_multk_q47	= mk_count_q47  == 'd3 && multk_q47;
wire last_multk_q48	= mk_count_q48  == 'd3 && multk_q48;

wire finish_gg1		= last_multk_gg1  || last_multk_gg1_reg;
wire finish_gr11	= last_multk_gr11 || last_multk_gr11_reg;
wire finish_gr12	= last_multk_gr12 || last_multk_gr12_reg;
wire finish_gr13	= last_multk_gr13 || last_multk_gr13_reg;
wire finish_gg2 	= last_multk_gg2  || last_multk_gg2_reg; 
wire finish_gr21	= last_multk_gr21 || last_multk_gr21_reg;
wire finish_gr22	= last_multk_gr22 || last_multk_gr22_reg;
wire finish_gg3 	= last_multk_gg3  || last_multk_gg3_reg; 
wire finish_gr31	= last_multk_gr31 || last_multk_gr31_reg;
wire finish_gg4 	= last_multk_gg4  || last_multk_gg4_reg; 
wire finish_q11		= last_multk_q11  || last_multk_q11_reg;
wire finish_q12		= last_multk_q12  || last_multk_q12_reg;
wire finish_q13		= last_multk_q13  || last_multk_q13_reg;
wire finish_q14		= last_multk_q14  || last_multk_q14_reg;
wire finish_q15		= last_multk_q15  || last_multk_q15_reg;
wire finish_q16		= last_multk_q16  || last_multk_q16_reg;
wire finish_q17		= last_multk_q17  || last_multk_q17_reg;
wire finish_q18		= last_multk_q18  || last_multk_q18_reg;
wire finish_q21		= last_multk_q21  || last_multk_q21_reg;
wire finish_q22		= last_multk_q22  || last_multk_q22_reg;
wire finish_q23		= last_multk_q23  || last_multk_q23_reg;
wire finish_q24		= last_multk_q24  || last_multk_q24_reg;
wire finish_q25		= last_multk_q25  || last_multk_q25_reg;
wire finish_q26		= last_multk_q26  || last_multk_q26_reg;
wire finish_q27		= last_multk_q27  || last_multk_q27_reg;
wire finish_q28		= last_multk_q28  || last_multk_q28_reg;
wire finish_q31		= last_multk_q31  || last_multk_q31_reg;
wire finish_q32		= last_multk_q32  || last_multk_q32_reg;
wire finish_q33		= last_multk_q33  || last_multk_q33_reg;
wire finish_q34		= last_multk_q34  || last_multk_q34_reg;
wire finish_q35		= last_multk_q35  || last_multk_q35_reg;
wire finish_q36		= last_multk_q36  || last_multk_q36_reg;
wire finish_q37		= last_multk_q37  || last_multk_q37_reg;
wire finish_q38		= last_multk_q38  || last_multk_q38_reg;
wire finish_q41		= last_multk_q41  || last_multk_q41_reg;
wire finish_q42		= last_multk_q42  || last_multk_q42_reg;
wire finish_q43		= last_multk_q43  || last_multk_q43_reg;
wire finish_q44		= last_multk_q44  || last_multk_q44_reg;
wire finish_q45		= last_multk_q45  || last_multk_q45_reg;
wire finish_q46		= last_multk_q46  || last_multk_q46_reg;
wire finish_q47		= last_multk_q47  || last_multk_q47_reg;
wire finish_q48		= last_multk_q48  || last_multk_q48_reg;

wire nop_gg1 		= initial_read 		| finish_gg1;
wire nop_gg2 		= mk_count_gr11 <= 'd1 | finish_gg2 | multk_gg2;
wire nop_gg3 		= mk_count_gr21 <= 'd1 | finish_gg3 | multk_gg3;
wire nop_gg4 		= mk_count_gr31 <= 'd1 | finish_gg4 | multk_gg4;

wire qr_finish		= last_multk_q48;

// output
assign rd_A 		= en;

assign wr_Q_1 		= finish_q11 & (!wr_Q_1_end);
assign wr_Q_2 		= finish_q21 & (!wr_Q_2_end);
assign wr_Q_3 		= finish_q31 & (!wr_Q_3_end);
assign wr_Q_4 		= finish_q41 & (!wr_Q_4_end);
assign wr_Q_5 		= finish_q41 & (!wr_Q_5_end);
assign wr_Q_6 		= finish_q31 & (!wr_Q_6_end);
assign wr_Q_7 		= finish_q21 & (!wr_Q_7_end);
assign wr_Q_8 		= finish_q11 & (!wr_Q_8_end);

assign wr_Q_data_1 	= (wr_Q_addr_1 >= 'd4) ? xo_mk1_q : xo_mk2_q;
assign wr_Q_data_2 	= (wr_Q_addr_2 >= 'd4) ? xo_mk3_q : xo_mk4_q;
assign wr_Q_data_3 	= (wr_Q_addr_3 >= 'd4) ? xo_mk5_q : xo_mk6_q;
assign wr_Q_data_4 	= (wr_Q_addr_4 >= 'd4) ? xo_mk7_q : xo_mk8_q;
assign wr_Q_data_5 	= (wr_Q_addr_5 >= 'd4) ? yo_mk7_q : yo_mk8_q;
assign wr_Q_data_6 	= (wr_Q_addr_6 >= 'd4) ? yo_mk7_q : yo_mk8_q;
assign wr_Q_data_7 	= (wr_Q_addr_7 >= 'd4) ? yo_mk7_q : yo_mk8_q;
assign wr_Q_data_8 	= (wr_Q_addr_8 >= 'd4) ? yo_mk7_q : yo_mk8_q;

assign done 		= DONE_wire;

/*****************************************************************/
/**                      FSM (control GG1)                      **/
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


/***********************************************************************************/
/**                                 Sequential                                    **/
/***********************************************************************************/
/*****************************************************************/
/**                             I/O                             **/
/*****************************************************************/
// A read addr
always @(posedge clk or posedge rst) begin
	if (rst) begin
		rd_A_row_addr <= 'd0;
		rd_A_col_addr <= 'd3;	// rd_A_col_end
	end
	else if(rd_A & ~rd_A_end) begin
		if(rd_A_col_end) begin
			rd_A_row_addr <= rd_A_row_addr - 'd1;
			rd_A_col_addr <= 'd0;
		end
		else begin
			rd_A_row_addr <= rd_A_row_addr;
			rd_A_col_addr <= rd_A_col_addr + 'd1;
		end
	end
end

// R write addr
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_R_row_addr <= 'd0;
		wr_R_col_addr <= 'd0;
	end
	else if(ROT_wire) begin
		if(last_multk_gg2 || last_multk_gg3 || last_multk_gg4) begin
			wr_R_row_addr <= wr_R_col_addr + 'd1;
			wr_R_col_addr <= wr_R_col_addr + 'd1;
		end
		else if(wr_R_row_addr != 0) begin
			wr_R_row_addr <= wr_R_row_addr - 'd1;
			wr_R_col_addr <= wr_R_col_addr;
		end
	end
	else begin
		wr_R_row_addr <= 'd0;
		wr_R_col_addr <= 'd0;
	end
end

// wr_R_data
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_R_data <= 'd0;
	end
	else begin
		case(1)
			last_multk_gg1 		: wr_R_data <= xo_mk1;
			last_multk_gg2 		: wr_R_data <= xo_mk2;
			last_multk_gr21 	: wr_R_data <= xo_gg2;
			last_multk_gg3 		: wr_R_data <= xo_mk3;
			last_multk_gr31 	: wr_R_data <= xo_gg3;
			last_multk_gr31_dly1: wr_R_data <= yo_gg3;
			last_multk_gg4 		: wr_R_data <= xo_mk4;
			last_multk_gg4_dly1 : wr_R_data <= xo_gg4;
			last_multk_gg4_dly2 : wr_R_data <= yo_gg4;
			last_multk_gg4_dly3 : wr_R_data <= yo_gg4;
			default 			: wr_R_data <= 'd0;
		endcase
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_R <= 'd0;
	end
	else begin
		wr_R <= last_multk_gg1 | 
				last_multk_gg2 | last_multk_gr21 | 
				last_multk_gg3 | last_multk_gr31 | last_multk_gr31_dly1 | 
				last_multk_gg4 | last_multk_gg4_dly1 | last_multk_gg4_dly2 | last_multk_gg4_dly3;
	end
end

// R out valid control
always @(posedge clk or posedge rst) begin
	if (rst) begin
		last_multk_gr31_dly1 	<= 1'b0;
		last_multk_gg4_dly1		<= 1'b0;
		last_multk_gg4_dly2		<= 1'b0;
		last_multk_gg4_dly3		<= 1'b0;
	end
	else begin
		last_multk_gr31_dly1 	<= last_multk_gr31;
		last_multk_gg4_dly1		<= last_multk_gg4;
		last_multk_gg4_dly2		<= last_multk_gg4_dly1;
		last_multk_gg4_dly3		<= last_multk_gg4_dly2;
	end
end


// Q outputs reversed data
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_Q_addr_1 <= 'd7;
		wr_Q_addr_2 <= 'd7;
		wr_Q_addr_3 <= 'd7;
		wr_Q_addr_4 <= 'd7;
		wr_Q_addr_5 <= 'd7;
		wr_Q_addr_6 <= 'd7;
		wr_Q_addr_7 <= 'd7;
		wr_Q_addr_8 <= 'd7;
	end
	else begin
		wr_Q_addr_1 <= wr_Q_1 ? (wr_Q_addr_1 - 1) : wr_Q_addr_1;
		wr_Q_addr_2 <= wr_Q_2 ? (wr_Q_addr_2 - 1) : wr_Q_addr_2;
		wr_Q_addr_3 <= wr_Q_3 ? (wr_Q_addr_3 - 1) : wr_Q_addr_3;
		wr_Q_addr_4 <= wr_Q_4 ? (wr_Q_addr_4 - 1) : wr_Q_addr_4;
		wr_Q_addr_5 <= wr_Q_5 ? (wr_Q_addr_5 - 1) : wr_Q_addr_5;
		wr_Q_addr_6 <= wr_Q_6 ? (wr_Q_addr_6 - 1) : wr_Q_addr_6;
		wr_Q_addr_7 <= wr_Q_7 ? (wr_Q_addr_7 - 1) : wr_Q_addr_7;
		wr_Q_addr_8 <= wr_Q_8 ? (wr_Q_addr_8 - 1) : wr_Q_addr_8;
	end
end

// Q write done control
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_Q_1_end <= 'd0;
		wr_Q_2_end <= 'd0;
		wr_Q_3_end <= 'd0;
		wr_Q_4_end <= 'd0;
		wr_Q_5_end <= 'd0;
		wr_Q_6_end <= 'd0;
		wr_Q_7_end <= 'd0;
		wr_Q_8_end <= 'd0;
	end
	else begin
		wr_Q_1_end <= (wr_Q_addr_1 == 'd0) ? 'd1 : wr_Q_1_end;
		wr_Q_2_end <= (wr_Q_addr_2 == 'd0) ? 'd1 : wr_Q_2_end;
		wr_Q_3_end <= (wr_Q_addr_3 == 'd0) ? 'd1 : wr_Q_3_end;
		wr_Q_4_end <= (wr_Q_addr_4 == 'd0) ? 'd1 : wr_Q_4_end;
		wr_Q_5_end <= (wr_Q_addr_5 == 'd0) ? 'd1 : wr_Q_5_end;
		wr_Q_6_end <= (wr_Q_addr_6 == 'd0) ? 'd1 : wr_Q_6_end;
		wr_Q_7_end <= (wr_Q_addr_7 == 'd0) ? 'd1 : wr_Q_7_end;
		wr_Q_8_end <= (wr_Q_addr_8 == 'd0) ? 'd1 : wr_Q_8_end;
	end
end


// ROM Q is an identity matrix
integer i, j;
always @(posedge clk or posedge rst) begin
	if(rst) begin
		for (i=0; i<8; i=i+1) begin
			for (j=0; j<8; j=j+1) begin
				Q_ROM[i][j] <= 12'd0;
			end
		end
		// signed: 1b, int: 1b, fraction: 10b
		Q_ROM[0][0] <= 12'b0100_0000_0000;
		Q_ROM[1][1] <= 12'b0100_0000_0000;
		Q_ROM[2][2] <= 12'b0100_0000_0000;
		Q_ROM[3][3] <= 12'b0100_0000_0000;
		Q_ROM[4][4] <= 12'b0100_0000_0000;
		Q_ROM[5][5] <= 12'b0100_0000_0000;
		Q_ROM[6][6] <= 12'b0100_0000_0000;
		Q_ROM[7][7] <= 12'b0100_0000_0000;
	end
end


/*****************************************************************/
/**                           Control                           **/
/*****************************************************************/
// Signals propagation (form left to right)
always @(posedge clk or posedge rst) begin
	if (rst) begin
		start_gr11_reg	<= 1'b0;
		start_gr12_reg	<= 1'b0;
		start_gr13_reg	<= 1'b0;
		start_q11_reg	<= 1'b0;
		start_q12_reg	<= 1'b0;
		start_q13_reg	<= 1'b0;
		start_q14_reg	<= 1'b0;
		start_q15_reg	<= 1'b0;
		start_q16_reg	<= 1'b0;
		start_q17_reg	<= 1'b0;
		start_q18_reg	<= 1'b0;
	end
	else begin
		start_gr11_reg	<= start_gg1;
		start_gr12_reg	<= start_gr11_reg;
		start_gr13_reg	<= start_gr12_reg;
		start_q11_reg	<= start_gr13_reg;
		start_q12_reg	<= start_q11_reg;
		start_q13_reg	<= start_q12_reg;
		start_q14_reg	<= start_q13_reg;
		start_q15_reg	<= start_q14_reg;
		start_q16_reg	<= start_q15_reg;
		start_q17_reg	<= start_q16_reg;
		start_q18_reg	<= start_q17_reg;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		start_gr21_reg	<= 1'b0;
		start_gr22_reg	<= 1'b0;
		start_q21_reg	<= 1'b0;
		start_q22_reg	<= 1'b0;
		start_q23_reg	<= 1'b0;
		start_q24_reg	<= 1'b0;
		start_q25_reg	<= 1'b0;
		start_q26_reg	<= 1'b0;
		start_q27_reg	<= 1'b0;
		start_q28_reg	<= 1'b0;
	end
	else begin
		start_gr21_reg 	<= start_gg2;
		start_gr22_reg 	<= start_gr21_reg;
		start_q21_reg	<= start_gr22_reg;
		start_q22_reg	<= start_q21_reg;
		start_q23_reg	<= start_q22_reg;
		start_q24_reg	<= start_q23_reg;
		start_q25_reg	<= start_q24_reg;
		start_q26_reg	<= start_q25_reg;
		start_q27_reg	<= start_q26_reg;
		start_q28_reg	<= start_q27_reg;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		start_gr31_reg	<= 1'b0;
		start_q31_reg	<= 1'b0;
		start_q32_reg	<= 1'b0;
		start_q33_reg	<= 1'b0;
		start_q34_reg	<= 1'b0;
		start_q35_reg	<= 1'b0;
		start_q36_reg	<= 1'b0;
		start_q37_reg	<= 1'b0;
		start_q38_reg	<= 1'b0;
	end 
	else begin
		start_gr31_reg 	<= start_gg3;
		start_q31_reg	<= start_gr31_reg;
		start_q32_reg	<= start_q31_reg;
		start_q33_reg	<= start_q32_reg;
		start_q34_reg	<= start_q33_reg;
		start_q35_reg	<= start_q34_reg;
		start_q36_reg	<= start_q35_reg;
		start_q37_reg	<= start_q36_reg;
		start_q38_reg	<= start_q37_reg;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		start_q41_reg	<= 1'b0;
		start_q42_reg	<= 1'b0;
		start_q43_reg	<= 1'b0;
		start_q44_reg	<= 1'b0;
		start_q45_reg	<= 1'b0;
		start_q46_reg	<= 1'b0;
		start_q47_reg	<= 1'b0;
		start_q48_reg	<= 1'b0;
	end
	else begin
		start_q41_reg	<= start_gg4;
		start_q42_reg	<= start_q41_reg;
		start_q43_reg	<= start_q42_reg;
		start_q44_reg	<= start_q43_reg;
		start_q45_reg	<= start_q44_reg;
		start_q46_reg	<= start_q45_reg;
		start_q47_reg	<= start_q46_reg;
		start_q48_reg	<= start_q47_reg;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		last_multk_gg1_reg	<= 1'b0;
		last_multk_gr11_reg <= 1'b0;
		last_multk_gr12_reg <= 1'b0;
		last_multk_gr13_reg <= 1'b0;
		last_multk_gg2_reg  <= 1'b0;
		last_multk_gr21_reg <= 1'b0;
		last_multk_gr22_reg <= 1'b0;
		last_multk_gg3_reg  <= 1'b0;
		last_multk_gr31_reg <= 1'b0;
		last_multk_gg4_reg  <= 1'b0;
		last_multk_q11_reg	<= 1'b0;
		last_multk_q12_reg	<= 1'b0;
		last_multk_q13_reg	<= 1'b0;
		last_multk_q14_reg	<= 1'b0;
		last_multk_q15_reg	<= 1'b0;
		last_multk_q16_reg	<= 1'b0;
		last_multk_q17_reg	<= 1'b0;
		last_multk_q18_reg	<= 1'b0;
		last_multk_q21_reg	<= 1'b0;
		last_multk_q22_reg	<= 1'b0;
		last_multk_q23_reg	<= 1'b0;
		last_multk_q24_reg	<= 1'b0;
		last_multk_q25_reg	<= 1'b0;
		last_multk_q26_reg	<= 1'b0;
		last_multk_q27_reg	<= 1'b0;
		last_multk_q28_reg	<= 1'b0;
		last_multk_q31_reg	<= 1'b0;
		last_multk_q32_reg	<= 1'b0;
		last_multk_q33_reg	<= 1'b0;
		last_multk_q34_reg	<= 1'b0;
		last_multk_q35_reg	<= 1'b0;
		last_multk_q36_reg	<= 1'b0;
		last_multk_q37_reg	<= 1'b0;
		last_multk_q38_reg	<= 1'b0;
		last_multk_q41_reg	<= 1'b0;
		last_multk_q42_reg	<= 1'b0;
		last_multk_q43_reg	<= 1'b0;
		last_multk_q44_reg	<= 1'b0;
		last_multk_q45_reg	<= 1'b0;
		last_multk_q46_reg	<= 1'b0;
		last_multk_q47_reg	<= 1'b0;
		last_multk_q48_reg	<= 1'b0;
	end
	else begin
		last_multk_gg1_reg	<= finish_gg1;
		last_multk_gr11_reg <= finish_gr11;
		last_multk_gr12_reg <= finish_gr12;
		last_multk_gr13_reg <= finish_gr13;
		last_multk_gg2_reg  <= finish_gg2;
		last_multk_gr21_reg <= finish_gr21;
		last_multk_gr22_reg <= finish_gr22;
		last_multk_gg3_reg  <= finish_gg3;
		last_multk_gr31_reg <= finish_gr31;
		last_multk_gg4_reg  <= finish_gg4;
		last_multk_q11_reg	<= finish_q11;
		last_multk_q12_reg	<= finish_q12;
		last_multk_q13_reg	<= finish_q13;
		last_multk_q14_reg	<= finish_q14;
		last_multk_q15_reg	<= finish_q15;
		last_multk_q16_reg	<= finish_q16;
		last_multk_q17_reg	<= finish_q17;
		last_multk_q18_reg	<= finish_q18;
		last_multk_q21_reg	<= finish_q21;
		last_multk_q22_reg	<= finish_q22;
		last_multk_q23_reg	<= finish_q23;
		last_multk_q24_reg	<= finish_q24;
		last_multk_q25_reg	<= finish_q25;
		last_multk_q26_reg	<= finish_q26;
		last_multk_q27_reg	<= finish_q27;
		last_multk_q28_reg	<= finish_q28;
		last_multk_q31_reg	<= finish_q31;
		last_multk_q32_reg	<= finish_q32;
		last_multk_q33_reg	<= finish_q33;
		last_multk_q34_reg	<= finish_q34;
		last_multk_q35_reg	<= finish_q35;
		last_multk_q36_reg	<= finish_q36;
		last_multk_q37_reg	<= finish_q37;
		last_multk_q38_reg	<= finish_q38;
		last_multk_q41_reg	<= finish_q41;
		last_multk_q42_reg	<= finish_q42;
		last_multk_q43_reg	<= finish_q43;
		last_multk_q44_reg	<= finish_q44;
		last_multk_q45_reg	<= finish_q45;
		last_multk_q46_reg	<= finish_q46;
		last_multk_q47_reg	<= finish_q47;
		last_multk_q48_reg	<= finish_q48;
	end
end


/*****************************************************************/
/**                              GG1                            **/
/*****************************************************************/
// iteration times
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gg1 <= 'd0;
	end
	else if(ROT_wire) begin
		if(nop_gg1) begin
			iter_gg1 <= 'd0;
		end
		else if(iter_last_gg1) begin
			iter_gg1 <= iter_gg1 + 'd1;
		end
		else begin
			iter_gg1 <= iter_gg1 + ITER_ONE_CYCLE;
		end
	end
	else begin
		iter_gg1 <= 'd0;
	end
end

// GG1 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg1 <= 'd0;
		yi_gg1 <= 'd0;
	end
	else begin
		case(iter_gg1)
			0: begin
				if(start_gg1) begin
					xi_gg1 <= 'd0;
					yi_gg1 <= rd_A_data_ext;
				end
				else if(nop_gg1 && !finish_gg1) begin
					xi_gg1 <= rd_A_data_ext;
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
					xi_gg1 <= rd_A_data_ext;
					yi_gg1 <= xo_mk1;
				end
			end
			default: begin
				xi_gg1 <= xo_gg1;
				yi_gg1 <= yo_gg1;
			end
		endcase
	end
end

// GG1 mk_count
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_count_gg1 <= 'd0;
	end
	else if(multk_gg1) begin
		mk_count_gg1 <= mk_count_gg1 + 'd1;
	end
end


/*****************************************************************/
/**                              GR11                           **/
/*****************************************************************/
// data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr11 	<= 'd0;	
		nop_gr11 	<= 'd0;
		d1_gr11 	<= 'd0;
		d2_gr11 	<= 'd0;
		d3_gr11 	<= 'd0;
		d4_gr11 	<= 'd0;
		neg_gr11 	<= 'd0;
		mk_count_gr11 <= 'd0;
	end
	else begin
		iter_gr11 	<= iter_gg1;
		nop_gr11 	<= nop_gg1;
		d1_gr11 	<= d1_gg1;
		d2_gr11 	<= d2_gg1;
		d3_gr11 	<= d3_gg1;
		d4_gr11 	<= d4_gg1;
		neg_gr11 	<= neg_gg1;
		mk_count_gr11 <= mk_count_gg1;
	end
end

// GR11 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr11 <= 'd0;
		yi_gr11 <= 'd0;
	end
	else begin
		case(iter_gr11)
			0: begin
				if(start_gr11_reg) begin
					xi_gr11 <= 'd0;
					yi_gr11 <= rd_A_data_ext;
				end
				else if(nop_gr11 && !finish_gr11) begin
					xi_gr11 <= rd_A_data_ext;
					yi_gr11 <= yo_gr11;
				end
				else begin
					xi_gr11 <= xo_gr11;
					yi_gr11 <= yo_gr11;
				end
			end
			ITER_K: begin
				if(finish_gr11) begin
					xi_gr11 <= xo_mk1;
					yi_gr11 <= yo_mk1;
				end
				else begin
					xi_gr11 <= rd_A_data_ext;
					yi_gr11 <= xo_mk1;
				end
			end
			default: begin
				xi_gr11 <= xo_gr11;
				yi_gr11 <= yo_gr11;
			end
		endcase
	end
end


/*****************************************************************/
/**                              GR12                           **/
/*****************************************************************/
// data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr12 	<= 'd0;	
		nop_gr12 	<= 'd0;
		d1_gr12 	<= 'd0;
		d2_gr12 	<= 'd0;
		d3_gr12 	<= 'd0;
		d4_gr12 	<= 'd0;
		neg_gr12 	<= 'd0;
		mk_count_gr12 <= 'd0;
	end
	else begin
		iter_gr12 	<= iter_gr11;
		nop_gr12 	<= nop_gr11;
		d1_gr12 	<= d1_gr11;
		d2_gr12 	<= d2_gr11;
		d3_gr12 	<= d3_gr11;
		d4_gr12 	<= d4_gr11;
		neg_gr12 	<= neg_gr11;
		mk_count_gr12 <= mk_count_gr11;
	end
end

// GR12 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr12 <= 'd0;
		yi_gr12 <= 'd0;
	end
	else begin
		case(iter_gr12)
			0: begin
				if(start_gr12_reg) begin
					xi_gr12 <= 'd0;
					yi_gr12 <= rd_A_data_ext;
				end
				else if(nop_gr12 && !finish_gr12) begin
					xi_gr12 <= rd_A_data_ext;
					yi_gr12 <= yo_gr12;
				end
				else begin
					xi_gr12 <= xo_gr12;
					yi_gr12 <= yo_gr12;
				end
			end
			ITER_K: begin
				if(finish_gr12) begin
					xi_gr12 <= xo_mk1;
					yi_gr12 <= yo_mk1;
				end
				else begin
					xi_gr12 <= rd_A_data_ext;
					yi_gr12 <= xo_mk1;
				end
			end
			default: begin
				xi_gr12 <= xo_gr12;
				yi_gr12 <= yo_gr12;
			end
		endcase
	end
end


/*****************************************************************/
/**                              GR13                           **/
/*****************************************************************/
// data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr13 	<= 'd0;	
		nop_gr13 	<= 'd0;
		d1_gr13 	<= 'd0;
		d2_gr13 	<= 'd0;
		d3_gr13 	<= 'd0;
		d4_gr13 	<= 'd0;
		neg_gr13 	<= 'd0;
		mk_count_gr13 <= 'd0;
	end
	else begin
		iter_gr13 	<= iter_gr12;
		nop_gr13 	<= nop_gr12;
		d1_gr13 	<= d1_gr12;
		d2_gr13 	<= d2_gr12;
		d3_gr13 	<= d3_gr12;
		d4_gr13 	<= d4_gr12;
		neg_gr13 	<= neg_gr12;
		mk_count_gr13 <= mk_count_gr12;
	end
end

// GR13 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr13 <= 'd0;
		yi_gr13 <= 'd0;
	end
	else begin
		case(iter_gr13)
			0: begin
				if(start_gr13_reg) begin
					xi_gr13 <= 'd0;
					yi_gr13 <= rd_A_data_ext;
				end
				else if(nop_gr13 && !finish_gr13) begin
					xi_gr13 <= rd_A_data_ext;
					yi_gr13 <= yo_gr13;
				end
				else begin
					xi_gr13 <= xo_gr13;
					yi_gr13 <= yo_gr13;
				end
			end
			ITER_K: begin
				if(finish_gr13) begin
					xi_gr13 <= xo_mk1;
					yi_gr13 <= yo_mk1;
				end
				else begin
					xi_gr13 <= rd_A_data_ext;
					yi_gr13 <= xo_mk1;
				end
			end
			default: begin
				xi_gr13 <= xo_gr13;
				yi_gr13 <= yo_gr13;
			end
		endcase
	end
end


/*****************************************************************/
/**                              GG2                            **/
/*****************************************************************/
// iteration times
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gg2 <= 'd0;
	end
	else begin
		if(nop_gg2) begin
			iter_gg2 <= 'd0;
		end
		else if(iter_last_gg2) begin
			iter_gg2 <= iter_gg2 + 'd1;
		end
		else begin
			iter_gg2 <= iter_gg2 + ITER_ONE_CYCLE;
		end
	end
end

// GG2 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg2 <= 'd0;
		yi_gg2 <= 'd0;
	end
	else begin
		case(iter_gg2)
			0: begin
				if(start_gg2) begin
					xi_gg2 <= 'd0;
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
					xi_gg2 <= xo_gr11;
					yi_gg2 <= yo_gr11;
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
end

// GG2 mk_count
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_count_gg2 <= 'd0;
	end
	else if(multk_gg2) begin
		mk_count_gg2 <= mk_count_gg2 + 'd1;
	end
end


/*****************************************************************/
/**                              GR21                           **/
/*****************************************************************/
// data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr21 	<= 'd0;	
		nop_gr21 	<= 'd0;
		d1_gr21 	<= 'd0;
		d2_gr21 	<= 'd0;
		d3_gr21 	<= 'd0;
		d4_gr21 	<= 'd0;
		neg_gr21 	<= 'd0;
		mk_count_gr21 <= 'd0;
	end
	else begin
		iter_gr21 	<= iter_gg2;
		nop_gr21 	<= nop_gg2;
		d1_gr21 	<= d1_gg2;
		d2_gr21 	<= d2_gg2;
		d3_gr21 	<= d3_gg2;
		d4_gr21 	<= d4_gg2;
		neg_gr21 	<= neg_gg2;
		mk_count_gr21 <= mk_count_gg2;
	end
end

// GR21 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr21 <= 'd0;
		yi_gr21 <= 'd0;
	end
	else begin
		case(iter_gr21)
			0: begin
				if(start_gr21_reg) begin
					xi_gr21 <= 'd0;
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
					xi_gr21 <= xo_mk2;
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
end


/*****************************************************************/
/**                              GR22                           **/
/*****************************************************************/
// data propagated from left to right
always @(posedge clk or posedge rst) begin
    if (rst) begin
        iter_gr22 	<= 'd0;
        nop_gr22 	<= 'd0;
        d1_gr22 	<= 'd0;
        d2_gr22 	<= 'd0;
		d3_gr22 	<= 'd0;
		d4_gr22 	<= 'd0;
        neg_gr22 	<= 'd0;
        mk_count_gr22 <= 'd0;
    end
    else begin
        iter_gr22 	<= iter_gr21;
        nop_gr22 	<= nop_gr21;
        d1_gr22 	<= d1_gr21;
        d2_gr22 	<= d2_gr21;
		d3_gr22 	<= d3_gr21;
		d4_gr22 	<= d4_gr21;
        neg_gr22 	<= neg_gr21;
        mk_count_gr22 <= mk_count_gr21;
    end
end


// GR22 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr22 <= 'd0;
		yi_gr22 <= 'd0;
	end
	else begin
		case(iter_gr22)
			0: begin
				if(start_gr22_reg) begin
					xi_gr22 <= 'd0;
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
					xi_gr22 <= xo_mk2;
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
end


/*****************************************************************/
/**                              GG3                            **/
/*****************************************************************/
// GG3 iteration times
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gg3 <= 'd0;
	end
	else begin
		if(nop_gg3) begin
			iter_gg3 <= 'd0;
		end
		else if(iter_last_gg3) begin
			iter_gg3 <= iter_gg3 + 'd1;
		end
		else begin
			iter_gg3 <= iter_gg3 + ITER_ONE_CYCLE;
		end
	end
end

// GG3 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg3 <= 'd0;
		yi_gg3 <= 'd0;
	end
	else begin
		case(iter_gg3)
			0: begin
				if(start_gg3) begin
					xi_gg3 <= 'd0;
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
					xi_gg3 <= xo_gr21;
					yi_gg3 <= yo_gr21;
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
end

// GG3 mk_count
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_count_gg3 <= 'd0;
	end
	else if(multk_gg3) begin
		mk_count_gg3 <= mk_count_gg3 + 'd1;
	end
end



/*****************************************************************/
/**                              GR31                           **/
/*****************************************************************/
// data propagated from left to right
always @(posedge clk or posedge rst) begin
    if (rst) begin
        iter_gr31 	<= 'd0;
        nop_gr31 	<= 'd0;
        d1_gr31 	<= 'd0;
        d2_gr31 	<= 'd0;
		d3_gr31 	<= 'd0;
		d4_gr31 	<= 'd0;
        neg_gr31 	<= 'd0;
        mk_count_gr31 <= 'd0;
    end
    else begin
        iter_gr31 	<= iter_gg3;
        nop_gr31 	<= nop_gg3;
        d1_gr31 	<= d1_gg3;
        d2_gr31 	<= d2_gg3;
		d3_gr31 	<= d3_gg3;
		d4_gr31 	<= d4_gg3;
        neg_gr31 	<= neg_gg3;
        mk_count_gr31 <= mk_count_gg3;
    end
end

// GR31 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr31 <= 'd0;
		yi_gr31 <= 'd0;
	end
	else begin
		case(iter_gr31)
			0: begin
				if(start_gr31_reg) begin
					xi_gr31 <= 'd0;
					yi_gr31 <= yo_mk2;
				end
				else if(nop_gr31 && !finish_gr31) begin
					xi_gr31 <= yo_mk2;
					yi_gr31 <= yo_gr31;
				end
				else if(finish_gg4) begin
					xi_gr31 <= xo_gr31; 
					yi_gr31 <= yo_gr22;
				end
				else begin
					xi_gr31 <= xo_gr31;
					yi_gr31 <= yo_gr31;
				end
			end
			ITER_K: begin
				if(finish_gr31) begin
					xi_gr31 <= xo_mk3;
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
end


/*****************************************************************/
/**                              GG4                            **/
/*****************************************************************/
// GG4 iteration times
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gg4 <= 'd0;
	end
	else begin
		if(nop_gg4 && !finish_gg4) begin
			iter_gg4 <= 'd0;
		end
		else if(nop_gg4 || iter_last_gg4) begin
			iter_gg4 <= (iter_gg4 == ITER_K) ? 0 :iter_gg4 + 'd1;
		end
		else begin
			iter_gg4 <= iter_gg4 + ITER_ONE_CYCLE;
		end
	end
end

// GG4 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg4 <= 'd0;
		yi_gg4 <= 'd0;
	end
	else begin
		case(iter_gg4)
			0: begin
				if(start_gg4) begin
					xi_gg4 <= 'd0;
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
					yi_gg4 <= yo_gr31;
				end
			ITER_K: begin
				if(finish_gg4) begin
					xi_gg4 <= xo_gr31;
					yi_gg4 <= yo_gr31;
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
end

// GG4 mk_count
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_count_gg4 <= 'd0;
	end
	else if(multk_gg4) begin
		mk_count_gg4 <= mk_count_gg4 + 'd1;
	end
end


/*****************************************************************/
/**                              MK1                            **/
/*****************************************************************/
// MK1 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk1 <= 'd0;
		yi_mk1 <= 'd0;
	end
	else begin
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
				xi_mk1 <= 'd0;
				yi_mk1 <= 'd0;
			end
		endcase
	end
end

/*****************************************************************/
/**                              MK2                            **/
/*****************************************************************/
// MK2 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk2 <= 'd0;
		yi_mk2 <= 'd0;
	end
	else begin
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
				xi_mk2 <= 'd0;
				yi_mk2 <= 'd0;
			end
		endcase
	end
end

/*****************************************************************/
/**                              MK3                            **/
/*****************************************************************/
// MK3 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk3 <= 'd0;
		yi_mk3 <= 'd0;
	end
	else begin
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
				xi_mk3 <= 'd0;
				yi_mk3 <= 'd0;
			end
		endcase
	end
end

/*****************************************************************/
/**                              MK4                            **/
/*****************************************************************/
// MK4 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk4 <= 'd0;
		yi_mk4 <= 'd0;
	end
	else begin
		case(1)
			iter_last_gg4: begin
				xi_mk4 <= xo_gg4;
				yi_mk4 <= yo_gg4;
			end
			default: begin
				xi_mk4 <= 'd0;
				yi_mk4 <= 'd0;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q11                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q11 	<= 'd0;	
		nop_q11 	<= 'd0;
		d1_q11 		<= 'd0;
		d2_q11 		<= 'd0;
		d3_q11 		<= 'd0;
		d4_q11 		<= 'd0;
		neg_q11 	<= 'd0;
		mk_count_q11<= 'd0;
	end
	else begin
		iter_q11 	<= iter_gr13;
		nop_q11 	<= nop_gr13;
		d1_q11 		<= d1_gr13;
		d2_q11 		<= d2_gr13;
		d3_q11 		<= d3_gr13;
		d4_q11 		<= d4_gr13;
		neg_q11 	<= neg_gr13;
		mk_count_q11<= mk_count_gr13;
	end
end

// Q11 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q11	<= 'd0;
		yi_q11	<= 'd0;
		q_col_1 <= 'd0;
	end
	else begin
		case(iter_q11)
			0: begin
				if(start_q11_reg) begin
					xi_q11 <= 'd0;
					yi_q11 <= Q_ROM[q_col_1][0];
				end
				else if(nop_q11 && !finish_q11) begin
					xi_q11 <= Q_ROM[q_col_1+1][0];
					yi_q11 <= yo_q11;
				end
				else begin
					xi_q11 <= xo_q11;
					yi_q11 <= yo_q11;
				end
			end
			ITER_NUM: q_col_1 <= q_col_1 + 'd1;
			ITER_K: begin
				if(finish_q11) begin
					xi_q11 <= 'd0;
					yi_q11 <= 'd0;
				end
				else begin
					xi_q11 <= Q_ROM[q_col_1+1][0];
					yi_q11 <= xo_mk1_q;
				end
			end
			default: begin
				xi_q11 <= xo_q11;
				yi_q11 <= yo_q11;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q12                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q12 	<= 'd0;	
		nop_q12 	<= 'd0;
		d1_q12 		<= 'd0;
		d2_q12 		<= 'd0;
		d3_q12 		<= 'd0;
		d4_q12 		<= 'd0;
		neg_q12 	<= 'd0;
		mk_count_q12<= 'd0;
	end
	else begin
		iter_q12 	<= iter_q11;
		nop_q12 	<= nop_q11;
		d1_q12 		<= d1_q11;
		d2_q12 		<= d2_q11;
		d3_q12 		<= d3_q11;
		d4_q12 		<= d4_q11;
		neg_q12 	<= neg_q11;
		mk_count_q12<= mk_count_q11;
	end
end

// Q11 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q12 	<= 'd0;
		yi_q12 	<= 'd0;
		q_col_2	<= 'd0;
	end
	else begin
		case(iter_q12)
			0: begin
				if(start_q12_reg) begin
					xi_q12 <= 'd0;
					yi_q12 <= Q_ROM[q_col_2][1];
				end
				else if(nop_q12 && !finish_q12) begin
					xi_q12 <= Q_ROM[q_col_2+1][1];
					yi_q12 <= yo_q12;
				end
				else begin
					xi_q12 <= xo_q12;
					yi_q12 <= yo_q12;
				end
			end
			ITER_NUM: q_col_2 <= q_col_2 + 'd1;
			ITER_K: begin
				if(finish_q12) begin
					xi_q12 <= 'd0;
					yi_q12 <= 'd0;
				end
				else begin
					xi_q12 <= Q_ROM[q_col_2+1][1];
					yi_q12 <= xo_mk1_q;
				end
			end
			default: begin
				xi_q12 <= xo_q12;
				yi_q12 <= yo_q12;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q13                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q13 	<= 'd0;	
		nop_q13 	<= 'd0;
		d1_q13 		<= 'd0;
		d2_q13 		<= 'd0;
		d3_q13 		<= 'd0;
		d4_q13 		<= 'd0;
		neg_q13 	<= 'd0;
		mk_count_q13<= 'd0;
	end
	else begin
		iter_q13 	<= iter_q12;
		nop_q13 	<= nop_q12;
		d1_q13 		<= d1_q12;
		d2_q13 		<= d2_q12;
		d3_q13 		<= d3_q12;
		d4_q13 		<= d4_q12;
		neg_q13 	<= neg_q12;
		mk_count_q13<= mk_count_q12;
	end
end

// Q13 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q13 	<= 'd0;
		yi_q13 	<= 'd0;
		q_col_3	<= 'd0;
	end
	else begin
		case(iter_q13)
			0: begin
				if(start_q13_reg) begin
					xi_q13 <= 'd0;
					yi_q13 <= Q_ROM[q_col_3][2];
				end
				else if(nop_q13 && !finish_q13) begin
					xi_q13 <= Q_ROM[q_col_3+1][2];
					yi_q13 <= yo_q13;
				end
				else begin
					xi_q13 <= xo_q13;
					yi_q13 <= yo_q13;
				end
			end
			ITER_NUM: q_col_3 <= q_col_3 + 'd1;
			ITER_K: begin
				if(finish_q13) begin
					xi_q13 <= 'd0;
					yi_q13 <= 'd0;
				end
				else begin
					xi_q13 <= Q_ROM[q_col_3+1][2];
					yi_q13 <= xo_mk1_q;
				end
			end
			default: begin
				xi_q13 <= xo_q13;
				yi_q13 <= yo_q13;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q14                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q14 	<= 'd0;	
		nop_q14 	<= 'd0;
		d1_q14 		<= 'd0;
		d2_q14 		<= 'd0;
		d3_q14 		<= 'd0;
		d4_q14 		<= 'd0;
		neg_q14 	<= 'd0;
		mk_count_q14<= 'd0;
	end
	else begin
		iter_q14 	<= iter_q13;
		nop_q14 	<= nop_q13;
		d1_q14 		<= d1_q13;
		d2_q14 		<= d2_q13;
		d3_q14 		<= d3_q13;
		d4_q14 		<= d4_q13;
		neg_q14 	<= neg_q13;
		mk_count_q14<= mk_count_q13;
	end
end

// Q14 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q14 	<= 'd0;
		yi_q14 	<= 'd0;
		q_col_4	<= 'd0;
	end
	else begin
		case(iter_q14)
			0: begin
				if(start_q14_reg) begin
					xi_q14 <= 'd0;
					yi_q14 <= Q_ROM[q_col_4][3];
				end
				else if(nop_q14 && !finish_q14) begin
					xi_q14 <= Q_ROM[q_col_4+1][3];
					yi_q14 <= yo_q14;
				end
				else begin
					xi_q14 <= xo_q14;
					yi_q14 <= yo_q14;
				end
			end
			ITER_NUM: q_col_4 <= q_col_4 + 'd1;
			ITER_K: begin
				if(finish_q14) begin
					xi_q14 <= 'd0;
					yi_q14 <= 'd0;
				end
				else begin
					xi_q14 <= Q_ROM[q_col_4+1][3];
					yi_q14 <= xo_mk1_q;
				end
			end
			default: begin
				xi_q14 <= xo_q14;
				yi_q14 <= yo_q14;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q15                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q15 	<= 'd0;	
		nop_q15 	<= 'd0;
		d1_q15 		<= 'd0;
		d2_q15 		<= 'd0;
		d3_q15 		<= 'd0;
		d4_q15 		<= 'd0;
		neg_q15 	<= 'd0;
		mk_count_q15<= 'd0;
	end
	else begin
		iter_q15 	<= iter_q14;
		nop_q15 	<= nop_q14;
		d1_q15 		<= d1_q14;
		d2_q15 		<= d2_q14;
		d3_q15 		<= d3_q14;
		d4_q15 		<= d4_q14;
		neg_q15 	<= neg_q14;
		mk_count_q15<= mk_count_q14;
	end
end

// Q15 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q15 	<= 'd0;
		yi_q15 	<= 'd0;
		q_col_5	<= 'd0;
	end
	else begin
		case(iter_q15)
			0: begin
				if(start_q15_reg) begin
					xi_q15 <= 'd0;
					yi_q15 <= Q_ROM[q_col_5][4];
				end
				else if(nop_q15 && !finish_q15) begin
					xi_q15 <= Q_ROM[q_col_5+1][4];
					yi_q15 <= yo_q15;
				end
				else begin
					xi_q15 <= xo_q15;
					yi_q15 <= yo_q15;
				end
			end
			ITER_NUM: q_col_5 <= q_col_5 + 'd1;
			ITER_K: begin
				if(finish_q15) begin
					xi_q15 <= 'd0;
					yi_q15 <= 'd0;
				end
				else begin
					xi_q15 <= Q_ROM[q_col_5+1][4];
					yi_q15 <= xo_mk2_q;
				end
			end
			default: begin
				xi_q15 <= xo_q15;
				yi_q15 <= yo_q15;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q16                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q16 	<= 'd0;	
		nop_q16 	<= 'd0;
		d1_q16 		<= 'd0;
		d2_q16 		<= 'd0;
		d3_q16 		<= 'd0;
		d4_q16 		<= 'd0;
		neg_q16 	<= 'd0;
		mk_count_q16<= 'd0;
	end
	else begin
		iter_q16 	<= iter_q15;
		nop_q16 	<= nop_q15;
		d1_q16 		<= d1_q15;
		d2_q16 		<= d2_q15;
		d3_q16 		<= d3_q15;
		d4_q16 		<= d4_q15;
		neg_q16 	<= neg_q15;
		mk_count_q16<= mk_count_q15;
	end
end

// Q16 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q16 	<= 'd0;
		yi_q16 	<= 'd0;
		q_col_6	<= 'd0;
	end
	else begin
		case(iter_q16)
			0: begin
				if(start_q16_reg) begin
					xi_q16 <= 'd0;
					yi_q16 <= Q_ROM[q_col_6][5];
				end
				else if(nop_q16 && !finish_q16) begin
					xi_q16 <= Q_ROM[q_col_6+1][5];
					yi_q16 <= yo_q16;
				end
				else begin
					xi_q16 <= xo_q16;
					yi_q16 <= yo_q16;
				end
			end
			ITER_NUM: q_col_6 <= q_col_6 + 'd1;
			ITER_K: begin
				if(finish_q16) begin
					xi_q16 <= 'd0;
					yi_q16 <= 'd0;
				end
				else begin
					xi_q16 <= Q_ROM[q_col_6+1][5];
					yi_q16 <= xo_mk2_q;
				end
			end
			default: begin
				xi_q16 <= xo_q16;
				yi_q16 <= yo_q16;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q17                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q17 	<= 'd0;	
		nop_q17 	<= 'd0;
		d1_q17 		<= 'd0;
		d2_q17 		<= 'd0;
		d3_q17 		<= 'd0;
		d4_q17 		<= 'd0;
		neg_q17 	<= 'd0;
		mk_count_q17<= 'd0;
	end
	else begin
		iter_q17 	<= iter_q16;
		nop_q17 	<= nop_q16;
		d1_q17 		<= d1_q16;
		d2_q17 		<= d2_q16;
		d3_q17 		<= d3_q16;
		d4_q17 		<= d4_q16;
		neg_q17 	<= neg_q16;
		mk_count_q17<= mk_count_q16;
	end
end

// Q17 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q17 	<= 'd0;
		yi_q17 	<= 'd0;
		q_col_7	<= 'd0;
	end
	else begin
		case(iter_q17)
			0: begin
				if(start_q17_reg) begin
					xi_q17 <= 'd0;
					yi_q17 <= Q_ROM[q_col_7][6];
				end
				else if(nop_q17 && !finish_q17) begin
					xi_q17 <= Q_ROM[q_col_7+1][6];
					yi_q17 <= yo_q17;
				end
				else begin
					xi_q17 <= xo_q17;
					yi_q17 <= yo_q17;
				end
			end
			ITER_NUM: q_col_7 <= q_col_7 + 'd1;
			ITER_K: begin
				if(finish_q17) begin
					xi_q17 <= 'd0;
					yi_q17 <= 'd0;
				end
				else begin
					xi_q17 <= Q_ROM[q_col_7+1][6];
					yi_q17 <= xo_mk2_q;
				end
			end
			default: begin
				xi_q17 <= xo_q17;
				yi_q17 <= yo_q17;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q18                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q18 	<= 'd0;	
		nop_q18 	<= 'd0;
		d1_q18 		<= 'd0;
		d2_q18 		<= 'd0;
		d3_q18 		<= 'd0;
		d4_q18 		<= 'd0;
		neg_q18 	<= 'd0;
		mk_count_q18<= 'd0;
	end
	else begin
		iter_q18 	<= iter_q17;
		nop_q18 	<= nop_q17;
		d1_q18 		<= d1_q17;
		d2_q18 		<= d2_q17;
		d3_q18 		<= d3_q17;
		d4_q18 		<= d4_q17;
		neg_q18 	<= neg_q17;
		mk_count_q18<= mk_count_q17;
	end
end

// Q18 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q18 	<= 'd0;
		yi_q18 	<= 'd0;
		q_col_8	<= 'd0;
	end
	else begin
		case(iter_q18)
			0: begin
				if(start_q18_reg) begin
					xi_q18 <= 'd0;
					yi_q18 <= Q_ROM[q_col_8][7];
				end
				else if(nop_q18 && !finish_q18) begin
					xi_q18 <= Q_ROM[q_col_8+1][7];
					yi_q18 <= yo_q18;
				end
				else begin
					xi_q18 <= xo_q18;
					yi_q18 <= yo_q18;
				end
			end
			ITER_NUM: q_col_8 <= q_col_8 + 'd1;
			ITER_K: begin
				if(finish_q18) begin
					xi_q18 <= 'd0;
					yi_q18 <= 'd0;
				end
				else begin
					xi_q18 <= Q_ROM[q_col_8+1][7];
					yi_q18 <= xo_mk2_q;
				end
			end
			default: begin
				xi_q18 <= xo_q18;
				yi_q18 <= yo_q18;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q21                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q21 	<= 'd0;	
		nop_q21 	<= 'd0;
		d1_q21 		<= 'd0;
		d2_q21 		<= 'd0;
		d3_q21 		<= 'd0;
		d4_q21 		<= 'd0;
		neg_q21 	<= 'd0;
		mk_count_q21<= 'd0;
	end
	else begin
		iter_q21 	<= iter_gr22;
		nop_q21 	<= nop_gr22;
		d1_q21 		<= d1_gr22;
		d2_q21 		<= d2_gr22;
		d3_q21 		<= d3_gr22;
		d4_q21 		<= d4_gr22;
		neg_q21 	<= neg_gr22;
		mk_count_q21<= mk_count_gr22;
	end
end

// Q21 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q21 <= 'd0;
		yi_q21 <= 'd0;
	end
	else begin
		case(iter_q21)
			0: begin
				if(start_q21_reg) begin
					xi_q21 <= 'd0;
					yi_q21 <= yo_mk1_q;
				end
				else if(nop_q21 && !finish_q21) begin
					xi_q21 <= yo_mk1_q;
					yi_q21 <= yo_q21;
				end
				else begin
					xi_q21 <= xo_q21;
					yi_q21 <= yo_q21;
				end
			end
			ITER_K: begin
				if(finish_q21) begin
					xi_q21 <= 'd0;
					yi_q21 <= 'd0;
				end
				else begin
					xi_q21 <= yo_mk1_q;
					yi_q21 <= xo_mk3_q;
				end
			end
			default: begin
				xi_q21 <= xo_q21;
				yi_q21 <= yo_q21;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q22                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q22 	<= 'd0;	
		nop_q22 	<= 'd0;
		d1_q22 		<= 'd0;
		d2_q22 		<= 'd0;
		d3_q22 		<= 'd0;
		d4_q22 		<= 'd0;
		neg_q22 	<= 'd0;
		mk_count_q22<= 'd0;
	end
	else begin
		iter_q22 	<= iter_q21;
		nop_q22 	<= nop_q21;
		d1_q22 		<= d1_q21;
		d2_q22 		<= d2_q21;
		d3_q22 		<= d3_q21;
		d4_q22 		<= d4_q21;
		neg_q22 	<= neg_q21;
		mk_count_q22<= mk_count_q21;
	end
end

// GR22 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q22 <= 'd0;
		yi_q22 <= 'd0;
	end
	else begin
		case(iter_q22)
			0: begin
				if(start_q22_reg) begin
					xi_q22 <= 'd0;
					yi_q22 <= yo_mk1_q;
				end
				else if(nop_q22 && !finish_q22) begin
					xi_q22 <= yo_mk1_q;
					yi_q22 <= yo_q22;
				end
				else begin
					xi_q22 <= xo_q22;
					yi_q22 <= yo_q22;
				end
			end
			ITER_K: begin
				if(finish_q22) begin
					xi_q22 <= 'd0;
					yi_q22 <= 'd0;
				end
				else begin
					xi_q22 <= yo_mk1_q;
					yi_q22 <= xo_mk3_q;
				end
			end
			default: begin
				xi_q22 <= xo_q22;
				yi_q22 <= yo_q22;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q23                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q23 	<= 'd0;	
		nop_q23 	<= 'd0;
		d1_q23 		<= 'd0;
		d2_q23 		<= 'd0;
		d3_q23 		<= 'd0;
		d4_q23 		<= 'd0;
		neg_q23 	<= 'd0;
		mk_count_q23<= 'd0;
	end
	else begin
		iter_q23 	<= iter_q22;
		nop_q23 	<= nop_q22;
		d1_q23 		<= d1_q22;
		d2_q23 		<= d2_q22;
		d3_q23 		<= d3_q22;
		d4_q23 		<= d4_q22;
		neg_q23 	<= neg_q22;
		mk_count_q23<= mk_count_q22;
	end
end

// GR23 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q23 <= 'd0;
		yi_q23 <= 'd0;
	end
	else begin
		case(iter_q23)
			0: begin
				if(start_q23_reg) begin
					xi_q23 <= 'd0;
					yi_q23 <= yo_mk1_q;
				end
				else if(nop_q23 && !finish_q23) begin
					xi_q23 <= yo_mk1_q;
					yi_q23 <= yo_q23;
				end
				else begin
					xi_q23 <= xo_q23;
					yi_q23 <= yo_q23;
				end
			end
			ITER_K: begin
				if(finish_q23) begin
					xi_q23 <= 'd0;
					yi_q23 <= 'd0;
				end
				else begin
					xi_q23 <= yo_mk1_q;
					yi_q23 <= xo_mk3_q;
				end
			end
			default: begin
				xi_q23 <= xo_q23;
				yi_q23 <= yo_q23;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q24                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q24 	<= 'd0;	
		nop_q24 	<= 'd0;
		d1_q24 		<= 'd0;
		d2_q24 		<= 'd0;
		d3_q24 		<= 'd0;
		d4_q24 		<= 'd0;
		neg_q24 	<= 'd0;
		mk_count_q24<= 'd0;
	end
	else begin
		iter_q24 	<= iter_q23;
		nop_q24 	<= nop_q23;
		d1_q24 		<= d1_q23;
		d2_q24 		<= d2_q23;
		d3_q24 		<= d3_q23;
		d4_q24 		<= d4_q23;
		neg_q24 	<= neg_q23;
		mk_count_q24<= mk_count_q23;
	end
end

// GR24 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q24 <= 'd0;
		yi_q24 <= 'd0;
	end
	else begin
		case(iter_q24)
			0: begin
				if(start_q24_reg) begin
					xi_q24 <= 'd0;
					yi_q24 <= yo_mk1_q;
				end
				else if(nop_q24 && !finish_q24) begin
					xi_q24 <= yo_mk1_q;
					yi_q24 <= yo_q24;
				end
				else begin
					xi_q24 <= xo_q24;
					yi_q24 <= yo_q24;
				end
			end
			ITER_K: begin
				if(finish_q24) begin
					xi_q24 <= 'd0;
					yi_q24 <= 'd0;
				end
				else begin
					xi_q24 <= yo_mk1_q;
					yi_q24 <= xo_mk3_q;
				end
			end
			default: begin
				xi_q24 <= xo_q24;
				yi_q24 <= yo_q24;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q25                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q25 	<= 'd0;	
		nop_q25 	<= 'd0;
		d1_q25 		<= 'd0;
		d2_q25 		<= 'd0;
		d3_q25 		<= 'd0;
		d4_q25 		<= 'd0;
		neg_q25 	<= 'd0;
		mk_count_q25<= 'd0;
	end
	else begin
		iter_q25 	<= iter_q24;
		nop_q25 	<= nop_q24;
		d1_q25 		<= d1_q24;
		d2_q25 		<= d2_q24;
		d3_q25 		<= d3_q24;
		d4_q25 		<= d4_q24;
		neg_q25 	<= neg_q24;
		mk_count_q25<= mk_count_q24;
	end
end

// GR25 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q25 <= 'd0;
		yi_q25 <= 'd0;
	end
	else begin
		case(iter_q25)
			0: begin
				if(start_q25_reg) begin
					xi_q25 <= 'd0;
					yi_q25 <= yo_mk2_q;
				end
				else if(nop_q25 && !finish_q25) begin
					xi_q25 <= yo_mk2_q;
					yi_q25 <= yo_q25;
				end
				else begin
					xi_q25 <= xo_q25;
					yi_q25 <= yo_q25;
				end
			end
			ITER_K: begin
				if(finish_q25) begin
					xi_q25 <= 'd0;
					yi_q25 <= 'd0;
				end
				else begin
					xi_q25 <= yo_mk2_q;
					yi_q25 <= xo_mk4_q;
				end
			end
			default: begin
				xi_q25 <= xo_q25;
				yi_q25 <= yo_q25;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q26                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q26 	<= 'd0;	
		nop_q26 	<= 'd0;
		d1_q26 		<= 'd0;
		d2_q26 		<= 'd0;
		d3_q26 		<= 'd0;
		d4_q26 		<= 'd0;
		neg_q26 	<= 'd0;
		mk_count_q26<= 'd0;
	end
	else begin
		iter_q26 	<= iter_q25;
		nop_q26 	<= nop_q25;
		d1_q26 		<= d1_q25;
		d2_q26 		<= d2_q25;
		d3_q26 		<= d3_q25;
		d4_q26 		<= d4_q25;
		neg_q26 	<= neg_q25;
		mk_count_q26<= mk_count_q25;
	end
end

// GR26 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q26 <= 'd0;
		yi_q26 <= 'd0;
	end
	else begin
		case(iter_q26)
			0: begin
				if(start_q26_reg) begin
					xi_q26 <= 'd0;
					yi_q26 <= yo_mk2_q;
				end
				else if(nop_q26 && !finish_q26) begin
					xi_q26 <= yo_mk2_q;
					yi_q26 <= yo_q26;
				end
				else begin
					xi_q26 <= xo_q26;
					yi_q26 <= yo_q26;
				end
			end
			ITER_K: begin
				if(finish_q26) begin
					xi_q26 <= 'd0;
					yi_q26 <= 'd0;
				end
				else begin
					xi_q26 <= yo_mk2_q;
					yi_q26 <= xo_mk4_q;
				end
			end
			default: begin
				xi_q26 <= xo_q26;
				yi_q26 <= yo_q26;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q27                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q27 	<= 'd0;	
		nop_q27 	<= 'd0;
		d1_q27 		<= 'd0;
		d2_q27 		<= 'd0;
		d3_q27 		<= 'd0;
		d4_q27 		<= 'd0;
		neg_q27 	<= 'd0;
		mk_count_q27<= 'd0;
	end
	else begin
		iter_q27 	<= iter_q26;
		nop_q27 	<= nop_q26;
		d1_q27 		<= d1_q26;
		d2_q27 		<= d2_q26;
		d3_q27 		<= d3_q26;
		d4_q27 		<= d4_q26;
		neg_q27 	<= neg_q26;
		mk_count_q27<= mk_count_q26;
	end
end

// GR27 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q27 <= 'd0;
		yi_q27 <= 'd0;
	end
	else begin
		case(iter_q27)
			0: begin
				if(start_q27_reg) begin
					xi_q27 <= 'd0;
					yi_q27 <= yo_mk2_q;
				end
				else if(nop_q27 && !finish_q27) begin
					xi_q27 <= yo_mk2_q;
					yi_q27 <= yo_q27;
				end
				else begin
					xi_q27 <= xo_q27;
					yi_q27 <= yo_q27;
				end
			end
			ITER_K: begin
				if(finish_q27) begin
					xi_q27 <= 'd0;
					yi_q27 <= 'd0;
				end
				else begin
					xi_q27 <= yo_mk2_q;
					yi_q27 <= xo_mk4_q;
				end
			end
			default: begin
				xi_q27 <= xo_q27;
				yi_q27 <= yo_q27;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q28                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q28 	<= 'd0;	
		nop_q28 	<= 'd0;
		d1_q28 		<= 'd0;
		d2_q28 		<= 'd0;
		d3_q28 		<= 'd0;
		d4_q28 		<= 'd0;
		neg_q28 	<= 'd0;
		mk_count_q28<= 'd0;
	end
	else begin
		iter_q28 	<= iter_q27;
		nop_q28 	<= nop_q27;
		d1_q28 		<= d1_q27;
		d2_q28 		<= d2_q27;
		d3_q28 		<= d3_q27;
		d4_q28 		<= d4_q27;
		neg_q28 	<= neg_q27;
		mk_count_q28<= mk_count_q27;
	end
end

// GR28 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q28 <= 'd0;
		yi_q28 <= 'd0;
	end
	else begin
		case(iter_q28)
			0: begin
				if(start_q28_reg) begin
					xi_q28 <= 'd0;
					yi_q28 <= yo_mk2_q;
				end
				else if(nop_q28 && !finish_q28) begin
					xi_q28 <= yo_mk2_q;
					yi_q28 <= yo_q28;
				end
				else begin
					xi_q28 <= xo_q28;
					yi_q28 <= yo_q28;
				end
			end
			ITER_K: begin
				if(finish_q28) begin
					xi_q28 <= 'd0;
					yi_q28 <= 'd0;
				end
				else begin
					xi_q28 <= yo_mk2_q;
					yi_q28 <= xo_mk4_q;
				end
			end
			default: begin
				xi_q28 <= xo_q28;
				yi_q28 <= yo_q28;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q31                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q31 	<= 'd0;	
		nop_q31 	<= 'd0;
		d1_q31 		<= 'd0;
		d2_q31 		<= 'd0;
		d3_q31 		<= 'd0;
		d4_q31 		<= 'd0;
		neg_q31 	<= 'd0;
		mk_count_q31<= 'd0;
	end
	else begin
		iter_q31 	<= iter_gr31;
		nop_q31 	<= nop_gr31;
		d1_q31 		<= d1_gr31;
		d2_q31 		<= d2_gr31;
		d3_q31 		<= d3_gr31;
		d4_q31 		<= d4_gr31;
		neg_q31 	<= neg_gr31;
		mk_count_q31<= mk_count_gr31;
	end
end

// Q31 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q31 <= 'd0;
		yi_q31 <= 'd0;
	end
	else begin
		case(iter_q31)
			0: begin
				if(start_q31_reg) begin
					xi_q31 <= 'd0;
					yi_q31 <= yo_mk3_q;
				end
				else if(nop_q31 && !finish_q31) begin
					xi_q31 <= yo_mk3_q;
					yi_q31 <= yo_q31;
				end
				else begin
					xi_q31 <= xo_q31;
					yi_q31 <= yo_q31;
				end
			end
			ITER_K: begin
				if(finish_q31) begin
					xi_q31 <= 'd0;
					yi_q31 <= 'd0;
				end
				else begin
					xi_q31 <= yo_mk3_q;
					yi_q31 <= xo_mk5_q;
				end
			end
			default: begin
				xi_q31 <= xo_q31;
				yi_q31 <= yo_q31;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q32                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q32 	<= 'd0;	
		nop_q32 	<= 'd0;
		d1_q32 		<= 'd0;
		d2_q32 		<= 'd0;
		d3_q32 		<= 'd0;
		d4_q32 		<= 'd0;
		neg_q32 	<= 'd0;
		mk_count_q32<= 'd0;
	end
	else begin
		iter_q32 	<= iter_q31; 	
		nop_q32 	<= nop_q31; 	
		d1_q32 		<= d1_q31;		
		d2_q32 		<= d2_q31;		
		d3_q32 		<= d3_q31;		
		d4_q32 		<= d4_q31; 		
		neg_q32 	<= neg_q31; 	
		mk_count_q32<= mk_count_q31; 	
	end
end

// Q32 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q32 <= 'd0;
		yi_q32 <= 'd0;
	end
	else begin
		case(iter_q32)
			0: begin
				if(start_q32_reg) begin
					xi_q32 <= 'd0;
					yi_q32 <= yo_mk3_q;
				end
				else if(nop_q32 && !finish_q32) begin
					xi_q32 <= yo_mk3_q;
					yi_q32 <= yo_q32;
				end
				else begin
					xi_q32 <= xo_q32;
					yi_q32 <= yo_q32;
				end
			end
			ITER_K: begin
				if(finish_q32) begin
					xi_q32 <= 'd0;
					yi_q32 <= 'd0;
				end
				else begin
					xi_q32 <= yo_mk3_q;
					yi_q32 <= xo_mk5_q;
				end
			end
			default: begin
				xi_q32 <= xo_q32;
				yi_q32 <= yo_q32;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q33                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q33 	<= 'd0;	
		nop_q33 	<= 'd0;
		d1_q33 		<= 'd0;
		d2_q33 		<= 'd0;
		d3_q33 		<= 'd0;
		d4_q33 		<= 'd0;
		neg_q33 	<= 'd0;
		mk_count_q33<= 'd0;
	end
	else begin
		iter_q33 	<= iter_q32; 	
		nop_q33 	<= nop_q32; 	
		d1_q33 		<= d1_q32;		
		d2_q33 		<= d2_q32;		
		d3_q33 		<= d3_q32;		
		d4_q33 		<= d4_q32; 		
		neg_q33 	<= neg_q32; 	
		mk_count_q33<= mk_count_q32; 	
	end
end

// Q33 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q33 <= 'd0;
		yi_q33 <= 'd0;
	end
	else begin
		case(iter_q33)
			0: begin
				if(start_q33_reg) begin
					xi_q33 <= 'd0;
					yi_q33 <= yo_mk3_q;
				end
				else if(nop_q33 && !finish_q33) begin
					xi_q33 <= yo_mk3_q;
					yi_q33 <= yo_q33;
				end
				else begin
					xi_q33 <= xo_q33;
					yi_q33 <= yo_q33;
				end
			end
			ITER_K: begin
				if(finish_q33) begin
					xi_q33 <= 'd0;
					yi_q33 <= 'd0;
				end
				else begin
					xi_q33 <= yo_mk3_q;
					yi_q33 <= xo_mk5_q;
				end
			end
			default: begin
				xi_q33 <= xo_q33;
				yi_q33 <= yo_q33;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q34                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q34 	<= 'd0;	
		nop_q34 	<= 'd0;
		d1_q34 		<= 'd0;
		d2_q34 		<= 'd0;
		d3_q34 		<= 'd0;
		d4_q34 		<= 'd0;
		neg_q34 	<= 'd0;
		mk_count_q34<= 'd0;
	end
	else begin
		iter_q34 	<= iter_q33; 	
		nop_q34 	<= nop_q33; 	
		d1_q34 		<= d1_q33;		
		d2_q34 		<= d2_q33;		
		d3_q34 		<= d3_q33;		
		d4_q34 		<= d4_q33; 		
		neg_q34 	<= neg_q33; 	
		mk_count_q34<= mk_count_q33; 	
	end
end

// Q34 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q34 <= 'd0;
		yi_q34 <= 'd0;
	end
	else begin
		case(iter_q34)
			0: begin
				if(start_q34_reg) begin
					xi_q34 <= 'd0;
					yi_q34 <= yo_mk3_q;
				end
				else if(nop_q34 && !finish_q34) begin
					xi_q34 <= yo_mk3_q;
					yi_q34 <= yo_q34;
				end
				else begin
					xi_q34 <= xo_q34;
					yi_q34 <= yo_q34;
				end
			end
			ITER_K: begin
				if(finish_q34) begin
					xi_q34 <= 'd0;
					yi_q34 <= 'd0;
				end
				else begin
					xi_q34 <= yo_mk3_q;
					yi_q34 <= xo_mk5_q;
				end
			end
			default: begin
				xi_q34 <= xo_q34;
				yi_q34 <= yo_q34;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q35                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q35 	<= 'd0;	
		nop_q35 	<= 'd0;
		d1_q35 		<= 'd0;
		d2_q35 		<= 'd0;
		d3_q35 		<= 'd0;
		d4_q35 		<= 'd0;
		neg_q35 	<= 'd0;
		mk_count_q35<= 'd0;
	end
	else begin
		iter_q35 	<= iter_q34; 	
		nop_q35 	<= nop_q34; 	
		d1_q35 		<= d1_q34;		
		d2_q35 		<= d2_q34;		
		d3_q35 		<= d3_q34;		
		d4_q35 		<= d4_q34; 		
		neg_q35 	<= neg_q34; 	
		mk_count_q35<= mk_count_q34; 	
	end
end

// Q35 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q35 <= 'd0;
		yi_q35 <= 'd0;
	end
	else begin
		case(iter_q35)
			0: begin
				if(start_q35_reg) begin
					xi_q35 <= 'd0;
					yi_q35 <= yo_mk4_q;
				end
				else if(nop_q35 && !finish_q35) begin
					xi_q35 <= yo_mk4_q;
					yi_q35 <= yo_q35;
				end
				else begin
					xi_q35 <= xo_q35;
					yi_q35 <= yo_q35;
				end
			end
			ITER_K: begin
				if(finish_q35) begin
					xi_q35 <= 'd0;
					yi_q35 <= 'd0;
				end
				else begin
					xi_q35 <= yo_mk4_q;
					yi_q35 <= xo_mk6_q;
				end
			end
			default: begin
				xi_q35 <= xo_q35;
				yi_q35 <= yo_q35;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q36                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q36 	<= 'd0;	
		nop_q36 	<= 'd0;
		d1_q36 		<= 'd0;
		d2_q36 		<= 'd0;
		d3_q36 		<= 'd0;
		d4_q36 		<= 'd0;
		neg_q36 	<= 'd0;
		mk_count_q36<= 'd0;
	end
	else begin
		iter_q36 	<= iter_q35; 	
		nop_q36 	<= nop_q35; 	
		d1_q36 		<= d1_q35;		
		d2_q36 		<= d2_q35;		
		d3_q36 		<= d3_q35;		
		d4_q36 		<= d4_q35; 		
		neg_q36 	<= neg_q35; 	
		mk_count_q36<= mk_count_q35; 	
	end
end

// Q36 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q36 <= 'd0;
		yi_q36 <= 'd0;
	end
	else begin
		case(iter_q36)
			0: begin
				if(start_q36_reg) begin
					xi_q36 <= 'd0;
					yi_q36 <= yo_mk4_q;
				end
				else if(nop_q36 && !finish_q36) begin
					xi_q36 <= yo_mk4_q;
					yi_q36 <= yo_q36;
				end
				else begin
					xi_q36 <= xo_q36;
					yi_q36 <= yo_q36;
				end
			end
			ITER_K: begin
				if(finish_q36) begin
					xi_q36 <= 'd0;
					yi_q36 <= 'd0;
				end
				else begin
					xi_q36 <= yo_mk4_q;
					yi_q36 <= xo_mk6_q;
				end
			end
			default: begin
				xi_q36 <= xo_q36;
				yi_q36 <= yo_q36;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q37                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q37 	<= 'd0;	
		nop_q37 	<= 'd0;
		d1_q37 		<= 'd0;
		d2_q37 		<= 'd0;
		d3_q37 		<= 'd0;
		d4_q37 		<= 'd0;
		neg_q37 	<= 'd0;
		mk_count_q37<= 'd0;
	end
	else begin
		iter_q37 	<= iter_q36; 	
		nop_q37 	<= nop_q36; 	
		d1_q37 		<= d1_q36;		
		d2_q37 		<= d2_q36;		
		d3_q37 		<= d3_q36;		
		d4_q37 		<= d4_q36; 		
		neg_q37 	<= neg_q36; 	
		mk_count_q37<= mk_count_q36; 	
	end
end

// Q37 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q37 <= 'd0;
		yi_q37 <= 'd0;
	end
	else begin
		case(iter_q37)
			0: begin
				if(start_q37_reg) begin
					xi_q37 <= 'd0;
					yi_q37 <= yo_mk4_q;
				end
				else if(nop_q37 && !finish_q37) begin
					xi_q37 <= yo_mk4_q;
					yi_q37 <= yo_q37;
				end
				else begin
					xi_q37 <= xo_q37;
					yi_q37 <= yo_q37;
				end
			end
			ITER_K: begin
				if(finish_q37) begin
					xi_q37 <= 'd0;
					yi_q37 <= 'd0;
				end
				else begin
					xi_q37 <= yo_mk4_q;
					yi_q37 <= xo_mk6_q;
				end
			end
			default: begin
				xi_q37 <= xo_q37;
				yi_q37 <= yo_q37;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q38                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q38 	<= 'd0;	
		nop_q38 	<= 'd0;
		d1_q38 		<= 'd0;
		d2_q38 		<= 'd0;
		d3_q38 		<= 'd0;
		d4_q38 		<= 'd0;
		neg_q38 	<= 'd0;
		mk_count_q38<= 'd0;
	end
	else begin
		iter_q38 	<= iter_q37; 	
		nop_q38 	<= nop_q37; 	
		d1_q38 		<= d1_q37;		
		d2_q38 		<= d2_q37;		
		d3_q38 		<= d3_q37;		
		d4_q38 		<= d4_q37; 		
		neg_q38 	<= neg_q37; 	
		mk_count_q38<= mk_count_q37; 	
	end
end

// Q38 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q38 <= 'd0;
		yi_q38 <= 'd0;
	end
	else begin
		case(iter_q38)
			0: begin
				if(start_q38_reg) begin
					xi_q38 <= 'd0;
					yi_q38 <= yo_mk4_q;
				end
				else if(nop_q38 && !finish_q38) begin
					xi_q38 <= yo_mk4_q;
					yi_q38 <= yo_q38;
				end
				else begin
					xi_q38 <= xo_q38;
					yi_q38 <= yo_q38;
				end
			end
			ITER_K: begin
				if(finish_q38) begin
					xi_q38 <= 'd0;
					yi_q38 <= 'd0;
				end
				else begin
					xi_q38 <= yo_mk4_q;
					yi_q38 <= xo_mk6_q;
				end
			end
			default: begin
				xi_q38 <= xo_q38;
				yi_q38 <= yo_q38;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q41                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q41 	<= 'd0;	
		nop_q41 	<= 'd0;
		d1_q41 		<= 'd0;
		d2_q41 		<= 'd0;
		d3_q41 		<= 'd0;
		d4_q41 		<= 'd0;
		neg_q41 	<= 'd0;
		mk_count_q41<= 'd0;
	end
	else begin
		iter_q41 	<= iter_gg4;
		nop_q41 	<= nop_gg4;
		d1_q41 		<= d1_gg4;
		d2_q41 		<= d2_gg4;
		d3_q41 		<= d3_gg4;
		d4_q41 		<= d4_gg4;
		neg_q41 	<= neg_gg4;
		mk_count_q41<= mk_count_gg4;
	end
end

// Q41 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q41 <= 'd0;
		yi_q41 <= 'd0;
	end
	else begin
		case(iter_q41)
			0: begin
				if(start_q41_reg) begin
					xi_q41 <= 'd0;
					yi_q41 <= yo_mk5_q;
				end
				else if(nop_q41 && !finish_q41) begin
					xi_q41 <= yo_mk5_q;
					yi_q41 <= yo_q41;
				end
				else begin
					xi_q41 <= xo_q41;
					yi_q41 <= yo_q41;
				end
			end
			ITER_K: begin
				if(finish_q41) begin
					xi_q41 <= 'd0;
					yi_q41 <= 'd0;
				end
				else begin
					xi_q41 <= yo_mk5_q;
					yi_q41 <= xo_mk7_q;
				end
			end
			default: begin
				xi_q41 <= xo_q41;
				yi_q41 <= yo_q41;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q42                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q42 	<= 'd0;	
		nop_q42 	<= 'd0;
		d1_q42 		<= 'd0;
		d2_q42 		<= 'd0;
		d3_q42 		<= 'd0;
		d4_q42 		<= 'd0;
		neg_q42 	<= 'd0;
		mk_count_q42<= 'd0;
	end
	else begin
		iter_q42 	<= iter_q41;
		nop_q42 	<= nop_q41;
		d1_q42 		<= d1_q41;
		d2_q42 		<= d2_q41;
		d3_q42 		<= d3_q41;
		d4_q42 		<= d4_q41;
		neg_q42 	<= neg_q41;
		mk_count_q42<= mk_count_q41;
	end
end

// Q42 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q42 <= 'd0;
		yi_q42 <= 'd0;
	end
	else begin
		case(iter_q42)
			0: begin
				if(start_q42_reg) begin
					xi_q42 <= 'd0;
					yi_q42 <= yo_mk5_q;
				end
				else if(nop_q42 && !finish_q42) begin
					xi_q42 <= yo_mk5_q;
					yi_q42 <= yo_q42;
				end
				else begin
					xi_q42 <= xo_q42;
					yi_q42 <= yo_q42;
				end
			end
			ITER_K: begin
				if(finish_q42) begin
					xi_q42 <= 'd0;
					yi_q42 <= 'd0;
				end
				else begin
					xi_q42 <= yo_mk5_q;
					yi_q42 <= xo_mk7_q;
				end
			end
			default: begin
				xi_q42 <= xo_q42;
				yi_q42 <= yo_q42;
			end
		endcase
	end
end

/*****************************************************************/
/**                              Q43                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q43 	<= 'd0;	
		nop_q43 	<= 'd0;
		d1_q43 		<= 'd0;
		d2_q43 		<= 'd0;
		d3_q43 		<= 'd0;
		d4_q43 		<= 'd0;
		neg_q43 	<= 'd0;
		mk_count_q43<= 'd0;
	end
	else begin
		iter_q43 	<= iter_q42;
		nop_q43 	<= nop_q42;
		d1_q43 		<= d1_q42;
		d2_q43 		<= d2_q42;
		d3_q43 		<= d3_q42;
		d4_q43 		<= d4_q42;
		neg_q43 	<= neg_q42;
		mk_count_q43<= mk_count_q42;
	end
end

// Q43 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q43 <= 'd0;
		yi_q43 <= 'd0;
	end
	else begin
		case(iter_q43)
			0: begin
				if(start_q43_reg) begin
					xi_q43 <= 'd0;
					yi_q43 <= yo_mk5_q;
				end
				else if(nop_q43 && !finish_q43) begin
					xi_q43 <= yo_mk5_q;
					yi_q43 <= yo_q43;
				end
				else begin
					xi_q43 <= xo_q43;
					yi_q43 <= yo_q43;
				end
			end
			ITER_K: begin
				if(finish_q43) begin
					xi_q43 <= 'd0;
					yi_q43 <= 'd0;
				end
				else begin
					xi_q43 <= yo_mk5_q;
					yi_q43 <= xo_mk7_q;
				end
			end
			default: begin
				xi_q43 <= xo_q43;
				yi_q43 <= yo_q43;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q44                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q44 	<= 'd0;	
		nop_q44 	<= 'd0;
		d1_q44 		<= 'd0;
		d2_q44 		<= 'd0;
		d3_q44 		<= 'd0;
		d4_q44 		<= 'd0;
		neg_q44 	<= 'd0;
		mk_count_q44<= 'd0;
	end
	else begin
		iter_q44 	<= iter_q43;
		nop_q44 	<= nop_q43;
		d1_q44 		<= d1_q43;
		d2_q44 		<= d2_q43;
		d3_q44 		<= d3_q43;
		d4_q44 		<= d4_q43;
		neg_q44 	<= neg_q43;
		mk_count_q44<= mk_count_q43;
	end
end

// Q44 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q44 <= 'd0;
		yi_q44 <= 'd0;
	end
	else begin
		case(iter_q44)
			0: begin
				if(start_q44_reg) begin
					xi_q44 <= 'd0;
					yi_q44 <= yo_mk5_q;
				end
				else if(nop_q44 && !finish_q44) begin
					xi_q44 <= yo_mk5_q;
					yi_q44 <= yo_q44;
				end
				else begin
					xi_q44 <= xo_q44;
					yi_q44 <= yo_q44;
				end
			end
			ITER_K: begin
				if(finish_q44) begin
					xi_q44 <= 'd0;
					yi_q44 <= 'd0;
				end
				else begin
					xi_q44 <= yo_mk5_q;
					yi_q44 <= xo_mk7_q;
				end
			end
			default: begin
				xi_q44 <= xo_q44;
				yi_q44 <= yo_q44;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q45                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q45 	<= 'd0;	
		nop_q45 	<= 'd0;
		d1_q45 		<= 'd0;
		d2_q45 		<= 'd0;
		d3_q45 		<= 'd0;
		d4_q45 		<= 'd0;
		neg_q45 	<= 'd0;
		mk_count_q45<= 'd0;
	end
	else begin
		iter_q45 	<= iter_q44;
		nop_q45 	<= nop_q44;
		d1_q45 		<= d1_q44;
		d2_q45 		<= d2_q44;
		d3_q45 		<= d3_q44;
		d4_q45 		<= d4_q44;
		neg_q45 	<= neg_q44;
		mk_count_q45<= mk_count_q44;
	end
end

// Q45 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q45 <= 'd0;
		yi_q45 <= 'd0;
	end
	else begin
		case(iter_q45)
			0: begin
				if(start_q45_reg) begin
					xi_q45 <= 'd0;
					yi_q45 <= yo_mk6_q;
				end
				else if(nop_q45 && !finish_q45) begin
					xi_q45 <= yo_mk6_q;
					yi_q45 <= yo_q45;
				end
				else begin
					xi_q45 <= xo_q45;
					yi_q45 <= yo_q45;
				end
			end
			ITER_K: begin
				if(finish_q45) begin
					xi_q45 <= 'd0;
					yi_q45 <= 'd0;
				end
				else begin
					xi_q45 <= yo_mk6_q;
					yi_q45 <= xo_mk8_q;
				end
			end
			default: begin
				xi_q45 <= xo_q45;
				yi_q45 <= yo_q45;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q46                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q46 	<= 'd0;	
		nop_q46 	<= 'd0;
		d1_q46 		<= 'd0;
		d2_q46 		<= 'd0;
		d3_q46 		<= 'd0;
		d4_q46 		<= 'd0;
		neg_q46 	<= 'd0;
		mk_count_q46<= 'd0;
	end
	else begin
		iter_q46 	<= iter_q45;
		nop_q46 	<= nop_q45;
		d1_q46 		<= d1_q45;
		d2_q46 		<= d2_q45;
		d3_q46 		<= d3_q45;
		d4_q46 		<= d4_q45;
		neg_q46 	<= neg_q45;
		mk_count_q46<= mk_count_q45;
	end
end

// Q46 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q46 <= 'd0;
		yi_q46 <= 'd0;
	end
	else begin
		case(iter_q46)
			0: begin
				if(start_q46_reg) begin
					xi_q46 <= 'd0;
					yi_q46 <= yo_mk6_q;
				end
				else if(nop_q46 && !finish_q46) begin
					xi_q46 <= yo_mk6_q;
					yi_q46 <= yo_q46;
				end
				else begin
					xi_q46 <= xo_q46;
					yi_q46 <= yo_q46;
				end
			end
			ITER_K: begin
				if(finish_q46) begin
					xi_q46 <= 'd0;
					yi_q46 <= 'd0;
				end
				else begin
					xi_q46 <= yo_mk6_q;
					yi_q46 <= xo_mk8_q;
				end
			end
			default: begin
				xi_q46 <= xo_q46;
				yi_q46 <= yo_q46;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q47                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q47 	<= 'd0;	
		nop_q47 	<= 'd0;
		d1_q47 		<= 'd0;
		d2_q47 		<= 'd0;
		d3_q47 		<= 'd0;
		d4_q47 		<= 'd0;
		neg_q47 	<= 'd0;
		mk_count_q47<= 'd0;
	end
	else begin
		iter_q47 	<= iter_q46;
		nop_q47 	<= nop_q46;
		d1_q47 		<= d1_q46;
		d2_q47 		<= d2_q46;
		d3_q47 		<= d3_q46;
		d4_q47 		<= d4_q46;
		neg_q47 	<= neg_q46;
		mk_count_q47<= mk_count_q46;
	end
end

// Q47 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q47 <= 'd0;
		yi_q47 <= 'd0;
	end
	else begin
		case(iter_q47)
			0: begin
				if(start_q47_reg) begin
					xi_q47 <= 'd0;
					yi_q47 <= yo_mk6_q;
				end
				else if(nop_q47 && !finish_q47) begin
					xi_q47 <= yo_mk6_q;
					yi_q47 <= yo_q47;
				end
				else begin
					xi_q47 <= xo_q47;
					yi_q47 <= yo_q47;
				end
			end
			ITER_K: begin
				if(finish_q47) begin
					xi_q47 <= 'd0;
					yi_q47 <= 'd0;
				end
				else begin
					xi_q47 <= yo_mk6_q;
					yi_q47 <= xo_mk8_q;
				end
			end
			default: begin
				xi_q47 <= xo_q47;
				yi_q47 <= yo_q47;
			end
		endcase
	end
end


/*****************************************************************/
/**                              Q48                            **/
/*****************************************************************/
// Data propagated from left to right
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_q48 	<= 'd0;	
		nop_q48 	<= 'd0;
		d1_q48 		<= 'd0;
		d2_q48 		<= 'd0;
		d3_q48 		<= 'd0;
		d4_q48 		<= 'd0;
		neg_q48 	<= 'd0;
		mk_count_q48<= 'd0;
	end
	else begin
		iter_q48 	<= iter_q47;
		nop_q48 	<= nop_q47;
		d1_q48 		<= d1_q47;
		d2_q48 		<= d2_q47;
		d3_q48 		<= d3_q47;
		d4_q48 		<= d4_q47;
		neg_q48 	<= neg_q47;
		mk_count_q48<= mk_count_q47;
	end
end

// Q48 input data xi, yi
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_q48 <= 'd0;
		yi_q48 <= 'd0;
	end
	else begin
		case(iter_q48)
			0: begin
				if(start_q48_reg) begin
					xi_q48 <= 'd0;
					yi_q48 <= yo_mk6_q;
				end
				else if(nop_q48 && !finish_q48) begin
					xi_q48 <= yo_mk6_q;
					yi_q48 <= yo_q48;
				end
				else begin
					xi_q48 <= xo_q48;
					yi_q48 <= yo_q48;
				end
			end
			ITER_K: begin
				if(finish_q48) begin
					xi_q48 <= 'd0;
					yi_q48 <= 'd0;
				end
				else begin
					xi_q48 <= yo_mk6_q;
					yi_q48 <= xo_mk8_q;
				end
			end
			default: begin
				xi_q48 <= xo_q48;
				yi_q48 <= yo_q48;
			end
		endcase
	end
end

/*****************************************************************/
/**                           MK_Q row1                         **/
/*****************************************************************/
// former (1~4)
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk1_q <= 'd0;
		yi_mk1_q <= 'd0;
	end
	else begin
		case(1)
			iter_last_q11: begin
				xi_mk1_q <= xo_q11;
				yi_mk1_q <= yo_q11;
			end
			iter_last_q12: begin
				xi_mk1_q <= xo_q12;
				yi_mk1_q <= yo_q12;
			end
			iter_last_q13: begin
				xi_mk1_q <= xo_q13;
				yi_mk1_q <= yo_q13;
			end
			iter_last_q14: begin
				xi_mk1_q <= xo_q14;
				yi_mk1_q <= yo_q14;
			end
			default: begin
				xi_mk1_q <= 'd0;
				yi_mk1_q <= 'd0;
			end
		endcase
	end
end

// later (5~8)
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk2_q <= 'd0;
		yi_mk2_q <= 'd0;
	end
	else begin
		case(1)
			iter_last_q15: begin
				xi_mk2_q <= xo_q15;
				yi_mk2_q <= yo_q15;
			end
			iter_last_q16: begin
				xi_mk2_q <= xo_q16;
				yi_mk2_q <= yo_q16;
			end
			iter_last_q17: begin
				xi_mk2_q <= xo_q17;
				yi_mk2_q <= yo_q17;
			end
			iter_last_q18: begin
				xi_mk2_q <= xo_q18;
				yi_mk2_q <= yo_q18;
			end
			default: begin
				xi_mk2_q <= 'd0;
				yi_mk2_q <= 'd0;
			end
		endcase
	end
end

/*****************************************************************/
/**                           MK_Q row2                         **/
/*****************************************************************/
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk3_q <= 'd0;
		yi_mk3_q <= 'd0;
	end
	else begin
		case(1)
			iter_last_q21: begin
				xi_mk3_q <= xo_q21;
				yi_mk3_q <= yo_q21;
			end
			iter_last_q22: begin
				xi_mk3_q <= xo_q22;
				yi_mk3_q <= yo_q22;
			end
			iter_last_q23: begin
				xi_mk3_q <= xo_q23;
				yi_mk3_q <= yo_q23;
			end
			iter_last_q24: begin
				xi_mk3_q <= xo_q24;
				yi_mk3_q <= yo_q24;
			end
			default: begin
				xi_mk3_q <= 'd0;
				yi_mk3_q <= 'd0;
			end
		endcase
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk4_q <= 'd0;
		yi_mk4_q <= 'd0;
	end
	else begin
		case(1)
			iter_last_q25: begin
				xi_mk4_q <= xo_q25;
				yi_mk4_q <= yo_q25;
			end
			iter_last_q26: begin
				xi_mk4_q <= xo_q26;
				yi_mk4_q <= yo_q26;
			end
			iter_last_q27: begin
				xi_mk4_q <= xo_q27;
				yi_mk4_q <= yo_q27;
			end
			iter_last_q28: begin
				xi_mk4_q <= xo_q28;
				yi_mk4_q <= yo_q28;
			end
			default: begin
				xi_mk4_q <= 'd0;
				yi_mk4_q <= 'd0;
			end
		endcase
	end
end

/*****************************************************************/
/**                           MK_Q row 3                        **/
/*****************************************************************/
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk5_q <= 'd0;
		yi_mk5_q <= 'd0;
	end
	else begin
		case(1)
			iter_last_q31: begin
				xi_mk5_q <= xo_q31;
				yi_mk5_q <= yo_q31;
			end
			iter_last_q32: begin
				xi_mk5_q <= xo_q32;
				yi_mk5_q <= yo_q32;
			end
			iter_last_q33: begin
				xi_mk5_q <= xo_q33;
				yi_mk5_q <= yo_q33;
			end
			iter_last_q34: begin
				xi_mk5_q <= xo_q34;
				yi_mk5_q <= yo_q34;
			end
			default: begin
				xi_mk5_q <= 'd0;
				yi_mk5_q <= 'd0;
			end
		endcase
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk6_q <= 'd0;
		yi_mk6_q <= 'd0;
	end
	else begin
		case(1)
			iter_last_q35: begin
				xi_mk6_q <= xo_q35;
				yi_mk6_q <= yo_q35;
			end
			iter_last_q36: begin
				xi_mk6_q <= xo_q36;
				yi_mk6_q <= yo_q36;
			end
			iter_last_q37: begin
				xi_mk6_q <= xo_q37;
				yi_mk6_q <= yo_q37;
			end
			iter_last_q38: begin
				xi_mk6_q <= xo_q38;
				yi_mk6_q <= yo_q38;
			end
			default: begin
				xi_mk6_q <= 'd0;
				yi_mk6_q <= 'd0;
			end
		endcase
	end
end

/*****************************************************************/
/**                           MK_Q row4                         **/
/*****************************************************************/
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk7_q <= 'd0;
		yi_mk7_q <= 'd0;
	end
	else begin
		case(1)
			iter_last_q41: begin
				xi_mk7_q <= xo_q41;
				yi_mk7_q <= yo_q41;
			end
			iter_last_q42: begin
				xi_mk7_q <= xo_q42;
				yi_mk7_q <= yo_q42;
			end
			iter_last_q43: begin
				xi_mk7_q <= xo_q43;
				yi_mk7_q <= yo_q43;
			end
			iter_last_q44: begin
				xi_mk7_q <= xo_q44;
				yi_mk7_q <= yo_q44;
			end
		endcase
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk8_q <= 'd0;
		yi_mk8_q <= 'd0;
	end
	else begin
		case(1)
			iter_last_q45: begin
				xi_mk8_q <= xo_q45;
				yi_mk8_q <= yo_q45;
			end
			iter_last_q46: begin
				xi_mk8_q <= xo_q46;
				yi_mk8_q <= yo_q46;
			end
			iter_last_q47: begin
				xi_mk8_q <= xo_q47;
				yi_mk8_q <= yo_q47;
			end
			iter_last_q48: begin
				xi_mk8_q <= xo_q48;
				yi_mk8_q <= yo_q48;
			end
			default: begin
				xi_mk8_q <= 'd0;
				yi_mk8_q <= 'd0;
			end
		endcase
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



Q Q11_inst (
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

Q Q12_inst (
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

Q Q13_inst (
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

Q Q14_inst (
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

Q Q15_inst (
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

Q Q16_inst (
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

Q Q17_inst (
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

Q Q18_inst (
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

Q Q21_inst (
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

Q Q22_inst (
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

Q Q23_inst (
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

Q Q24_inst (
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

Q Q25_inst (
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

Q Q26_inst (
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

Q Q27_inst (
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

Q Q28_inst (
	.nop  (nop_q28),
	.xi   (xi_q28),
	.yi   (yi_q28),
	.iter (iter_q28),
	.d1   (d1_q28),
	.d2   (d2_q28),
	.d3   (d3_q28),
	.d4   (d4_q28),
	.neg  (1'b0),
	.xo   (xo_q28),
	.yo   (yo_q28)
);

Q Q31_inst (
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

Q Q32_inst (
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

Q Q33_inst (
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

Q Q34_inst (
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

Q Q35_inst (
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

Q Q36_inst (
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

Q Q37_inst (
	.nop  (nop_q37),
	.xi   (xi_q37),
	.yi   (yi_q37),
	.iter (iter_q37),
	.d1   (d1_q37),
	.d2   (d2_q37),
	.d3   (d3_q37),
	.d4   (d4_q37),
	.neg  (1'b0),
	.xo   (xo_q37),
	.yo   (yo_q37)
);

Q Q38_inst (
	.nop  (nop_q38),
	.xi   (xi_q38),
	.yi   (yi_q38),
	.iter (iter_q38),
	.d1   (d1_q38),
	.d2   (d2_q38),
	.d3   (d3_q38),
	.d4   (d4_q38),
	.neg  (1'b0),
	.xo   (xo_q38),
	.yo   (yo_q38)
);

Q Q41_inst (
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

Q Q42_inst (
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

Q Q43_inst (
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

Q Q44_inst (
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

Q Q45_inst (
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

Q Q46_inst (
	.nop  (nop_q46),
	.xi   (xi_q46),
	.yi   (yi_q46),
	.iter (iter_q46),
	.d1   (d1_q46),
	.d2   (d2_q46),
	.d3   (d3_q46),
	.d4   (d4_q46),
	.neg  (1'b0),
	.xo   (xo_q46),
	.yo   (yo_q46)
);

Q Q47_inst (
	.nop  (nop_q47),
	.xi   (xi_q47),
	.yi   (yi_q47),
	.iter (iter_q47),
	.d1   (d1_q47),
	.d2   (d2_q47),
	.d3   (d3_q47),
	.d4   (d4_q47),
	.neg  (1'b0),
	.xo   (xo_q47),
	.yo   (yo_q47)
);

Q Q48_inst (
	.nop  (nop_q48),
	.xi   (xi_q48),
	.yi   (yi_q48),
	.iter (iter_q48),
	.d1   (d1_q48),
	.d2   (d2_q48),
	.d3   (d3_q48),
	.d4   (d4_q48),
	.neg  (1'b0),
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
	.xi (xi_mk4_q),
	.yi (yi_mk4_q),
	.xo (xo_mk4_q),
	.yo (yo_mk4_q)
);

MK MK5_Q_inst (
	.xi (xi_mk5_q),
	.yi (yi_mk5_q),
	.xo (xo_mk5_q),
	.yo (yo_mk5_q)
);

MK MK6_Q_inst (
	.xi (xi_mk6_q),
	.yi (yi_mk6_q),
	.xo (xo_mk6_q),
	.yo (yo_mk6_q)
);

MK MK7_Q_inst (
	.xi (xi_mk7_q),
	.yi (yi_mk7_q),
	.xo (xo_mk7_q),
	.yo (yo_mk7_q)
);

MK MK8_Q_inst (
	.xi (xi_mk8_q),
	.yi (yi_mk8_q),
	.xo (xo_mk8_q),
	.yo (yo_mk8_q)
);


endmodule
