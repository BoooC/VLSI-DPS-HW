module cordic #(
    parameter  R_LEN 	= 12,
    parameter  R_FRAC	= 3,
    parameter  K_LEN 	= 9,
    parameter  K_FRAC	= 9,
    parameter  Q_LEN 	= 12,
    parameter  Q_FRAC	= 10,
    parameter  ROW_LEN	=  2,
    parameter  COL_LEN	= 2,
    parameter  ITER_NUM	=  12,
    parameter  ITER_LEN	= 4   
)
(
    input								clk,
    input								rst,
    input								en,
    output reg							finish,
	
    //rd	
    output reg 							rd,
    input		signed	[R_LEN-1:0]     rd_data,
    output reg			[ROW_LEN-1:0]  	rd_row_addr,
    output reg			[COL_LEN-1:0]   rd_col_addr,
	
    //wr_R			
    output reg                      	wr,
    output reg  signed  [R_LEN-1:0] 	wr_data,
    output reg			[ROW_LEN-1:0]  	wr_row_addr,
    output reg			[COL_LEN-1:0]   wr_col_addr,
	
    //wr_Q
    output reg							wr_Q,
    output reg  signed  [Q_LEN-1:0]		wr_data_Q,
    output reg			[ROW_LEN-1:0]  	wr_row_addr_Q,
    output reg			[COL_LEN-1:0]   wr_col_addr_Q
);


reg [3:0] state;
reg [3:0] next_state;


reg [1:0] wr_col_addr_count;
reg [1:0] wr_row_ready_count_Q;
reg [3:0] start_gr21_count;
    
reg [R_LEN-1:0] final_r44;
    
reg [Q_LEN-1:0] final_Q41;
reg [Q_LEN-1:0] final_Q42;
reg [Q_LEN-1:0] final_Q43;
reg [Q_LEN-1:0] final_Q44;
    
//R 
reg [1:0] mk_cnt_gg1;
reg [1:0] mk_cnt_gr11;
reg [1:0] mk_cnt_gr12;
reg [1:0] mk_cnt_gr13;
reg [1:0] mk_cnt_gg2;
reg [1:0] mk_cnt_gr21;
reg [1:0] mk_cnt_gr22;
reg [1:0] mk_cnt_gg3;
reg [1:0] mk_cnt_gr31;
    
//Q 
reg [1:0] mk_cnt_Q11;
reg [1:0] mk_cnt_Q12;
reg [1:0] mk_cnt_Q13;
reg [1:0] mk_cnt_Q14;
reg [1:0] mk_cnt_Q21;
reg [1:0] mk_cnt_Q22;
reg [1:0] mk_cnt_Q23;
reg [1:0] mk_cnt_Q24;
reg [1:0] mk_cnt_Q31;
reg [1:0] mk_cnt_Q32;
reg [1:0] mk_cnt_Q33;
reg [1:0] mk_cnt_Q34;

reg [R_LEN-1:0] rd_data_Q [0:3];


// control
wire rd_flag;
wire start_gg1;
wire start_gr11;
wire start_gr12;
wire start_gr13;
wire start_gg2;
wire start_gr21;
wire start_gr22;
wire start_gg3;
wire start_gr31;

wire start_Q11;
wire start_Q12;
wire start_Q13;
wire start_Q14;
wire start_Q21;
wire start_Q22;
wire start_Q23;
wire start_Q24;
wire start_Q31;
wire start_Q32;
wire start_Q33;
wire start_Q34;

wire end_iter_gg1;
wire end_iter_gr11;
wire end_iter_gr12;
wire end_iter_gr13;
wire end_iter_gg2;
wire end_iter_gr21;
wire end_iter_gr22;
wire end_iter_gg3;
wire end_iter_gr31;

wire end_iter_Q11;
wire end_iter_Q12;
wire end_iter_Q13;
wire end_iter_Q14;
wire end_iter_Q21;
wire end_iter_Q22;
wire end_iter_Q23;
wire end_iter_Q24;
wire end_iter_Q31;
wire end_iter_Q32;
wire end_iter_Q33;
wire end_iter_Q34;

wire mk_gg1;
wire mk_gr11;
wire mk_gr12;
wire mk_gr13;
wire mk_gg2;
wire mk_gr21;
wire mk_gr22;
wire mk_gg3;
wire mk_gr31;

wire mk_Q11;
wire mk_Q12;
wire mk_Q13;
wire mk_Q14;
wire mk_Q21;
wire mk_Q22;
wire mk_Q23;
wire mk_Q24;
wire mk_Q31;
wire mk_Q32;
wire mk_Q33;
wire mk_Q34;

wire last_multk_gg1;
wire last_multk_gr11;
wire last_multk_gr12;
wire last_multk_gr13;
wire last_multk_gg2;
wire last_multk_gr21;
wire last_multk_gr22;
wire last_multk_gg3;
wire last_multk_gr31;

wire last_multk_Q11;
wire last_multk_Q12;
wire last_multk_Q13;
wire last_multk_Q14;
wire last_multk_Q21;
wire last_multk_Q22;
wire last_multk_Q23;
wire last_multk_Q24;
wire last_multk_Q31;
wire last_multk_Q32;
wire last_multk_Q33;
wire last_multk_Q34;

wire end_gg1;
wire end_gr11;
wire end_gr12;
wire end_gr13;
wire end_gg2;
wire end_gr21;
wire end_gr22;
wire end_gg3;
wire end_gr31;

wire end_Q11;
wire end_Q12;
wire end_Q13;
wire end_Q14;
wire end_Q21;
wire end_Q22;
wire end_Q23;
wire end_Q24;
wire end_Q31;
wire end_Q32;
wire end_Q33;
wire end_Q34;

wire rd_unready;
wire qr_done;


//GG1
reg								nop_gg1;
reg		signed	[R_LEN-1:0]		xi_gg1;
reg		signed	[R_LEN-1:0]		yi_gg1;
reg				[ITER_LEN-1:0]	iter_gg1;
reg				[ITER_LEN-1:0]	iter_gg1_n;
wire 			[1:0] 			d1_gg1;
wire 			[1:0] 			d2_gg1;
wire 			[1:0] 			d3_gg1;
wire 			[1:0] 			d4_gg1;
wire 							neg_gg1;
wire	signed 	[R_LEN-1:0]		xo_gg1;
wire	signed 	[R_LEN-1:0]		yo_gg1;

//GR11
reg                      		nop_gr11;
reg     signed 	[R_LEN-1:0]     xi_gr11;
reg     signed 	[R_LEN-1:0]     yi_gr11;
reg				[ITER_LEN-1:0]  iter_gr11;
reg				[1:0]       	d1_gr11;
reg				[1:0]       	d2_gr11;
reg				[1:0]       	d3_gr11;
reg				[1:0]       	d4_gr11;
reg				         		neg_gr11;
wire   	signed [R_LEN-1:0] 		xo_gr11;
wire   	signed [R_LEN-1:0] 		yo_gr11;

//GR12
reg                      		nop_gr12;
reg     signed 	[R_LEN-1:0]     xi_gr12;
reg     signed 	[R_LEN-1:0]     yi_gr12;
reg				[ITER_LEN-1:0]  iter_gr12;
reg				[1:0]       	d1_gr12;
reg				[1:0]       	d2_gr12;
reg				[1:0]       	d3_gr12;
reg				[1:0]       	d4_gr12;
reg				         		neg_gr12;
wire   	signed [R_LEN-1:0] 		xo_gr12;
wire   	signed [R_LEN-1:0] 		yo_gr12;

//GR13
reg                      		nop_gr13;
reg     signed 	[R_LEN-1:0]     xi_gr13;
reg     signed 	[R_LEN-1:0]     yi_gr13;
reg				[ITER_LEN-1:0]  iter_gr13;
reg				[1:0]       	d1_gr13;
reg				[1:0]       	d2_gr13;
reg				[1:0]       	d3_gr13;
reg				[1:0]       	d4_gr13;
reg				         		neg_gr13;
wire   	signed [R_LEN-1:0] 		xo_gr13;
wire   	signed [R_LEN-1:0] 		yo_gr13;

//GG2
reg								nop_gg2;
reg		signed	[R_LEN-1:0]		xi_gg2;
reg		signed	[R_LEN-1:0]		yi_gg2;
reg				[ITER_LEN-1:0]	iter_gg2;
reg				[ITER_LEN-1:0]	iter_gg2_n;
wire 			[1:0] 			d1_gg2;
wire 			[1:0] 			d2_gg2;
wire 			[1:0] 			d3_gg2;
wire 			[1:0] 			d4_gg2;
wire 							neg_gg2;
wire	signed 	[R_LEN-1:0]		xo_gg2;
wire	signed 	[R_LEN-1:0]		yo_gg2;

//GR21
reg                      		nop_gr21;
reg     signed 	[R_LEN-1:0]     xi_gr21;
reg     signed 	[R_LEN-1:0]     yi_gr21;
reg				[ITER_LEN-1:0]  iter_gr21;
reg				[1:0]       	d1_gr21;
reg				[1:0]       	d2_gr21;
reg				[1:0]       	d3_gr21;
reg				[1:0]       	d4_gr21;
reg				         		neg_gr21;
wire   	signed [R_LEN-1:0] 		xo_gr21;
wire   	signed [R_LEN-1:0] 		yo_gr21;

//GR22
reg                      		nop_gr22;
reg     signed 	[R_LEN-1:0]     xi_gr22;
reg     signed 	[R_LEN-1:0]     yi_gr22;
reg				[ITER_LEN-1:0]  iter_gr22;
reg				[1:0]       	d1_gr22;
reg				[1:0]       	d2_gr22;
reg				[1:0]       	d3_gr22;
reg				[1:0]       	d4_gr22;
reg				         		neg_gr22;
wire   	signed [R_LEN-1:0] 		xo_gr22;
wire   	signed [R_LEN-1:0] 		yo_gr22;

//GG3
reg                      		nop_gg3;
reg     signed 	[R_LEN-1:0]     xi_gg3;
reg     signed 	[R_LEN-1:0]     yi_gg3;
reg				[ITER_LEN-1:0]  iter_gg3;
reg				[ITER_LEN-1:0]  iter_gg3_n;
wire			[1:0]       	d1_gg3;
wire			[1:0]       	d2_gg3;
wire			[1:0]       	d3_gg3;
wire			[1:0]       	d4_gg3;
wire			         		neg_gg3;
wire   	signed [R_LEN-1:0] 		xo_gg3;
wire   	signed [R_LEN-1:0] 		yo_gg3;

//GR31
reg                      		nop_gr31;
reg     signed 	[R_LEN-1:0]     xi_gr31;
reg     signed 	[R_LEN-1:0]     yi_gr31;
reg				[ITER_LEN-1:0]  iter_gr31;
reg				[1:0]       	d1_gr31;
reg				[1:0]       	d2_gr31;
reg				[1:0]       	d3_gr31;
reg				[1:0]       	d4_gr31;
reg				         		neg_gr31;
wire   	signed [R_LEN-1:0] 		xo_gr31;
wire   	signed [R_LEN-1:0] 		yo_gr31;


//Q11
reg                          	nop_Q11;
reg     signed	[R_LEN-1:0]     xi_Q11;
reg     signed	[R_LEN-1:0]     yi_Q11;
reg        		[ITER_LEN-1:0]  iter_Q11;
reg        		[1:0]        	d1_Q11;
reg        		[1:0]        	d2_Q11;
reg        		[1:0]        	d3_Q11;
reg        		[1:0]        	d4_Q11;
reg                          	neg_Q11;
wire   	signed	[R_LEN-1:0]     xo_Q11;
wire   	signed	[R_LEN-1:0]     yo_Q11;

//Q12
reg                          	nop_Q12;
reg     signed	[R_LEN-1:0]     xi_Q12;
reg     signed	[R_LEN-1:0]     yi_Q12;
reg        		[ITER_LEN-1:0]  iter_Q12;
reg        		[1:0]        	d1_Q12;
reg        		[1:0]        	d2_Q12;
reg        		[1:0]        	d3_Q12;
reg        		[1:0]        	d4_Q12;
reg                          	neg_Q12;
wire   	signed	[R_LEN-1:0]     xo_Q12;
wire   	signed	[R_LEN-1:0]     yo_Q12;

//Q13
reg                          	nop_Q13;
reg     signed	[R_LEN-1:0]     xi_Q13;
reg     signed	[R_LEN-1:0]     yi_Q13;
reg        		[ITER_LEN-1:0]  iter_Q13;
reg        		[1:0]        	d1_Q13;
reg        		[1:0]        	d2_Q13;
reg        		[1:0]        	d3_Q13;
reg        		[1:0]        	d4_Q13;
reg                          	neg_Q13;
wire   	signed	[R_LEN-1:0]     xo_Q13;
wire   	signed	[R_LEN-1:0]     yo_Q13;

//Q14
reg                          	nop_Q14;
reg     signed	[R_LEN-1:0]     xi_Q14;
reg     signed	[R_LEN-1:0]     yi_Q14;
reg        		[ITER_LEN-1:0]  iter_Q14;
reg        		[1:0]        	d1_Q14;
reg        		[1:0]        	d2_Q14;
reg        		[1:0]        	d3_Q14;
reg        		[1:0]        	d4_Q14;
reg                          	neg_Q14;
wire   	signed	[R_LEN-1:0]     xo_Q14;
wire   	signed	[R_LEN-1:0]     yo_Q14;

//Q21
reg                          	nop_Q21;
reg     signed	[R_LEN-1:0]     xi_Q21;
reg     signed	[R_LEN-1:0]     yi_Q21;
reg        		[ITER_LEN-1:0]  iter_Q21;
reg        		[1:0]        	d1_Q21;
reg        		[1:0]        	d2_Q21;
reg        		[1:0]        	d3_Q21;
reg        		[1:0]        	d4_Q21;
reg                          	neg_Q21;
wire   	signed	[R_LEN-1:0]     xo_Q21;
wire   	signed	[R_LEN-1:0]     yo_Q21;

//Q22
reg                          	nop_Q22;
reg     signed	[R_LEN-1:0]     xi_Q22;
reg     signed	[R_LEN-1:0]     yi_Q22;
reg        		[ITER_LEN-1:0]  iter_Q22;
reg        		[1:0]        	d1_Q22;
reg        		[1:0]        	d2_Q22;
reg        		[1:0]        	d3_Q22;
reg        		[1:0]        	d4_Q22;
reg                          	neg_Q22;
wire   	signed	[R_LEN-1:0]     xo_Q22;
wire   	signed	[R_LEN-1:0]     yo_Q22;

//Q23
reg                          	nop_Q23;
reg     signed	[R_LEN-1:0]     xi_Q23;
reg     signed	[R_LEN-1:0]     yi_Q23;
reg        		[ITER_LEN-1:0]  iter_Q23;
reg        		[1:0]        	d1_Q23;
reg        		[1:0]        	d2_Q23;
reg        		[1:0]        	d3_Q23;
reg        		[1:0]        	d4_Q23;
reg                          	neg_Q23;
wire  	signed	[R_LEN-1:0]     xo_Q23;
wire  	signed	[R_LEN-1:0]     yo_Q23;

//Q24
reg                          	nop_Q24;
reg     signed	[R_LEN-1:0]     xi_Q24;
reg     signed	[R_LEN-1:0]     yi_Q24;
reg        		[ITER_LEN-1:0]  iter_Q24;
reg        		[1:0]        	d1_Q24;
reg        		[1:0]        	d2_Q24;
reg        		[1:0]        	d3_Q24;
reg        		[1:0]        	d4_Q24;
reg                          	neg_Q24;
wire   	signed	[R_LEN-1:0]     xo_Q24;
wire   	signed	[R_LEN-1:0]     yo_Q24;

//Q31
reg                          	nop_Q31;
reg     signed	[R_LEN-1:0]     xi_Q31;
reg     signed	[R_LEN-1:0]     yi_Q31;
reg        		[ITER_LEN-1:0]  iter_Q31;
reg        		[1:0]        	d1_Q31;
reg        		[1:0]        	d2_Q31;
reg        		[1:0]        	d3_Q31;
reg        		[1:0]        	d4_Q31;
reg                          	neg_Q31;
wire   	signed	[R_LEN-1:0]     xo_Q31;
wire   	signed	[R_LEN-1:0]     yo_Q31;

//Q32
reg                          	nop_Q32;
reg     signed	[R_LEN-1:0]     xi_Q32;
reg     signed	[R_LEN-1:0]     yi_Q32;
reg        		[ITER_LEN-1:0]  iter_Q32;
reg        		[1:0]        	d1_Q32;
reg        		[1:0]        	d2_Q32;
reg        		[1:0]        	d3_Q32;
reg        		[1:0]        	d4_Q32;
reg                          	neg_Q32;
wire   	signed	[R_LEN-1:0]     xo_Q32;
wire   	signed	[R_LEN-1:0]     yo_Q32;

//Q33
reg                          	nop_Q33;
reg     signed	[R_LEN-1:0]     xi_Q33;
reg     signed	[R_LEN-1:0]     yi_Q33;
reg        		[ITER_LEN-1:0]  iter_Q33;
reg        		[1:0]        	d1_Q33;
reg        		[1:0]        	d2_Q33;
reg        		[1:0]        	d3_Q33;
reg        		[1:0]        	d4_Q33;
reg                          	neg_Q33;
wire   	signed	[R_LEN-1:0]     xo_Q33;
wire   	signed	[R_LEN-1:0]     yo_Q33;

//Q34
reg                          	nop_Q34;
reg     signed	[R_LEN-1:0]     xi_Q34;
reg     signed	[R_LEN-1:0]     yi_Q34;
reg        		[ITER_LEN-1:0]  iter_Q34;
reg        		[1:0]        	d1_Q34;
reg        		[1:0]        	d2_Q34;
reg        		[1:0]        	d3_Q34;
reg        		[1:0]        	d4_Q34;
reg                          	neg_Q34;
wire   	signed	[R_LEN-1:0]     xo_Q34;
wire   	signed	[R_LEN-1:0]     yo_Q34;

//MK1
reg		signed [R_LEN-1:0]		xi_mk1;
reg		signed [R_LEN-1:0]		yi_mk1;
wire	signed [R_LEN-1:0]		xo_mk1;
wire	signed [R_LEN-1:0]		yo_mk1;

//MK2
reg   	signed [R_LEN-1:0]		xi_mk2;
reg   	signed [R_LEN-1:0]		yi_mk2;
wire  	signed [R_LEN-1:0]		xo_mk2;
wire  	signed [R_LEN-1:0]		yo_mk2;

//MK3
reg   	signed [R_LEN-1:0]		xi_mk3;
reg   	signed [R_LEN-1:0]		yi_mk3;
wire  	signed [R_LEN-1:0]		xo_mk3;
wire  	signed [R_LEN-1:0]		yo_mk3;

//MK1_Q
reg    	signed [R_LEN-1:0]		xi_mk1_Q;
reg    	signed [R_LEN-1:0]		yi_mk1_Q;
wire  	signed [R_LEN-1:0]		xo_mk1_Q;
wire  	signed [R_LEN-1:0]		yo_mk1_Q;

//MK2_Q
reg   	signed [R_LEN-1:0]		xi_mk2_Q;
reg   	signed [R_LEN-1:0]		yi_mk2_Q;
wire  	signed [R_LEN-1:0]		xo_mk2_Q;
wire  	signed [R_LEN-1:0]		yo_mk2_Q;

//MK3_Q
reg 	signed [R_LEN-1:0]		xi_mk3_Q;
reg 	signed [R_LEN-1:0]		yi_mk3_Q;
wire	signed [R_LEN-1:0]		xo_mk3_Q;
wire	signed [R_LEN-1:0]		yo_mk3_Q;



localparam IDLE		= 0;
localparam ROT 		= 1; // execute 4 micro-rotations
localparam MULT_K 	= 2; // multiplied by K
localparam DONE		= 3;           



//control signals
assign rd_unready 	= rd_row_addr == 3 || (rd_row_addr == 2 && rd_col_addr == 0); 
assign rd_flag	  	= rd_row_addr == 0 && rd_col_addr == 3 && mk_cnt_gg1 >= 2;
	
assign start_gg1  	= rd_row_addr == 3 && rd_col_addr == 0;
assign start_gr11 	= rd_row_addr == 3 && rd_col_addr == 1;
assign start_gr12 	= rd_row_addr == 3 && rd_col_addr == 2;
assign start_gr13 	= rd_row_addr == 3 && rd_col_addr == 3;
assign start_gg2  	= rd_row_addr == 1 && rd_col_addr == 1;
assign start_gr21 	= rd_row_addr == 1 && rd_col_addr == 2;
assign start_gr22 	= rd_row_addr == 1 && rd_col_addr == 3;
assign start_gg3  	= start_gr21_count == 8;
assign start_gr31 	= start_gr21_count == 9;

assign start_Q11 	= rd_row_addr == 2 && rd_col_addr == 0;
assign start_Q12 	= rd_row_addr == 2 && rd_col_addr == 1;
assign start_Q13 	= rd_row_addr == 2 && rd_col_addr == 2;
assign start_Q14 	= rd_row_addr == 2 && rd_col_addr == 3;
assign start_Q21 	= rd_row_addr == 0 && rd_col_addr == 0;
assign start_Q22 	= rd_row_addr == 0 && rd_col_addr == 1;
assign start_Q23 	= rd_row_addr == 0 && rd_col_addr == 2;
assign start_Q24 	= start_gr21_count == 5;
assign start_Q31 	= start_gr21_count == 10;
assign start_Q32 	= start_gr21_count == 11;
assign start_Q33 	= start_gr21_count == 12;
assign start_Q34 	= start_gr21_count == 13;


assign end_iter_gg1 	= iter_gg1  == 8;
assign end_iter_gr11	= iter_gr11 == 8;
assign end_iter_gr12	= iter_gr12 == 8;
assign end_iter_gr13	= iter_gr13 == 8;
assign end_iter_gg2 	= iter_gg2  == 8;
assign end_iter_gr21	= iter_gr21 == 8;
assign end_iter_gr22	= iter_gr22 == 8;
assign end_iter_gg3 	= iter_gg3  == 8;
assign end_iter_gr31	= iter_gr31 == 8;
	
assign end_iter_Q11		= iter_Q11  == 8;
assign end_iter_Q12		= iter_Q12  == 8;
assign end_iter_Q13		= iter_Q13  == 8;
assign end_iter_Q14		= iter_Q14  == 8;
assign end_iter_Q21		= iter_Q21  == 8;
assign end_iter_Q22		= iter_Q22  == 8;
assign end_iter_Q23		= iter_Q23  == 8;
assign end_iter_Q24		= iter_Q24  == 8;
assign end_iter_Q31		= iter_Q31  == 8;
assign end_iter_Q32		= iter_Q32  == 8;
assign end_iter_Q33		= iter_Q33  == 8;
assign end_iter_Q34		= iter_Q34  == 8;
	
assign multk_gg1 		= iter_gg1  == 9;
assign multk_gr11		= iter_gr11 == 9;
assign multk_gr12		= iter_gr12 == 9;
assign multk_gr13		= iter_gr13 == 9;
assign multk_gg2 		= iter_gg2  == 9;
assign multk_gr21		= iter_gr21 == 9;
assign multk_gr22		= iter_gr22 == 9;
assign multk_gg3 		= iter_gg3  == 9;
assign multk_gr31		= iter_gr31 == 9;

assign multk_Q11		= iter_Q11  == 9;
assign multk_Q12		= iter_Q12  == 9;
assign multk_Q13		= iter_Q13  == 9;
assign multk_Q14		= iter_Q14  == 9;
assign multk_Q21		= iter_Q21  == 9;
assign multk_Q22		= iter_Q22  == 9;
assign multk_Q23		= iter_Q23  == 9;
assign multk_Q24		= iter_Q24  == 9;
assign multk_Q31		= iter_Q31  == 9;
assign multk_Q32		= iter_Q32  == 9;
assign multk_Q33		= iter_Q33  == 9;
assign multk_Q34		= iter_Q34  == 9;

assign last_multk_gg1  = mk_cnt_gg1  == 2 && multk_gg1;
assign last_multk_gr11 = mk_cnt_gr11 == 2 && multk_gr11;
assign last_multk_gr12 = mk_cnt_gr12 == 2 && multk_gr12;
assign last_multk_gr13 = mk_cnt_gr13 == 2 && multk_gr13;
assign last_multk_gg2  = mk_cnt_gg2  == 1 && multk_gg2;
assign last_multk_gr21 = mk_cnt_gr21 == 1 && multk_gr21;
assign last_multk_gr22 = mk_cnt_gr22 == 1 && multk_gr22;
assign last_multk_gg3  = mk_cnt_gr21 == 2 && multk_gg3;
assign last_multk_gr31 = mk_cnt_gr21 == 2 && multk_gr31;

assign last_multk_Q11  = mk_cnt_Q11  == 2 && multk_Q11;
assign last_multk_Q12  = mk_cnt_Q12  == 2 && multk_Q12;
assign last_multk_Q13  = mk_cnt_Q13  == 2 && multk_Q13;
assign last_multk_Q14  = mk_cnt_Q14  == 2 && multk_Q14;
assign last_multk_Q21  = mk_cnt_Q21  == 1 && multk_Q21;
assign last_multk_Q22  = mk_cnt_Q22  == 1 && multk_Q22;
assign last_multk_Q23  = mk_cnt_Q23  == 1 && multk_Q23;
assign last_multk_Q24  = mk_cnt_Q24  == 1 && multk_Q24;
assign last_multk_Q31  = mk_cnt_gr21  == 2 && multk_Q31; ///////////////////////////
assign last_multk_Q32  = mk_cnt_gr21  == 2 && multk_Q32;
assign last_multk_Q33  = mk_cnt_gr21  == 2 && multk_Q33;
assign last_multk_Q34  = mk_cnt_gr21  == 2 && multk_Q34; //////////////////////////

assign end_gg1  = last_multk_gg1  || (mk_cnt_gg1  == 3 && iter_gg1  == 0);
assign end_gr11 = last_multk_gr11 || (mk_cnt_gr11 == 3 && iter_gr11 == 0);
assign end_gr12 = last_multk_gr12 || (mk_cnt_gr12 == 3 && iter_gr12 == 0);
assign end_gr13 = last_multk_gr13 || (mk_cnt_gr13 == 3 && iter_gr13 == 0);
assign end_gg2  = last_multk_gg2  || (mk_cnt_gg2  == 2 && iter_gg2  == 0);
assign end_gr21 = last_multk_gr21 || (mk_cnt_gr21 == 2 && iter_gr21 == 0);
assign end_gr22 = last_multk_gr22 || (mk_cnt_gr22 == 2 && iter_gr22 == 0);
assign end_gg3  = last_multk_gg3  || (mk_cnt_gg3  == 1 && iter_gg3  == 0);
assign end_gr31 = last_multk_gr31 || (mk_cnt_gr31 == 1 && iter_gr31 == 0);

assign end_Q11  = last_multk_Q11  || (mk_cnt_Q11  == 3 && iter_Q11  == 0);
assign end_Q12  = last_multk_Q12  || (mk_cnt_Q12  == 3 && iter_Q12  == 0);
assign end_Q13  = last_multk_Q13  || (mk_cnt_Q13  == 3 && iter_Q13  == 0);
assign end_Q14  = last_multk_Q14  || (mk_cnt_Q14  == 3 && iter_Q14  == 0);
assign end_Q21  = last_multk_Q21  || (mk_cnt_Q21  == 3 && iter_Q21  == 0);
assign end_Q22  = last_multk_Q22  || (mk_cnt_Q22  == 3 && iter_Q22  == 0);
assign end_Q23  = last_multk_Q23  || (mk_cnt_Q23  == 3 && iter_Q23  == 0);
assign end_Q24  = last_multk_Q24  || (mk_cnt_Q24  == 3 && iter_Q24  == 0);
assign end_Q31  = last_multk_Q31  || (mk_cnt_Q31  == 3 && iter_Q31  == 0);
assign end_Q32  = last_multk_Q32  || (mk_cnt_Q32  == 3 && iter_Q32  == 0);
assign end_Q33  = last_multk_Q33  || (mk_cnt_Q33  == 3 && iter_Q33  == 0);
assign end_Q34  = last_multk_Q34  || (mk_cnt_Q34  == 3 && iter_Q34  == 0);

assign qr_done = mk_cnt_Q33 == 1 && iter_Q34 == 8; //////////////////////////////

always @(posedge clk or posedge rst) begin
	if (rst) begin
		start_gr21_count <= 0;
	end
	else if(start_gr21 || start_gr21_count >= 1)begin
		start_gr21_count <= start_gr21_count + 1;
	end
	else
	   start_gr21_count <= start_gr21_count;
end
                                                                                                          
//FSM
always @(posedge clk or posedge rst) begin
	if (rst) begin
		state <= IDLE;
	end
	else begin
		state <= next_state;
	end
end

always @(*) begin
	case(state)
		IDLE: begin
			if(en) begin
				next_state = ROT;
			end
			else begin
				next_state = IDLE;
			end
		end
		ROT: begin
			if(qr_done) begin
				next_state = DONE;
			end
			else if(nop_gg1) begin
				next_state = ROT;
			end
			else if(end_iter_gg1) begin
				next_state = MULT_K;
			end
			else begin
				next_state = ROT;
			end
		end
		MULT_K: begin
			if(qr_done) begin
				next_state = DONE;
			end
			else begin
				next_state = ROT;
			end
		end
		DONE: begin
			next_state = IDLE;
		end
		default: begin
			next_state = IDLE;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		rd_row_addr <= 3;
		rd_col_addr <= 0;
	end
	else if(rd_flag)begin
	    rd_row_addr <=rd_row_addr;
		rd_col_addr <=rd_col_addr;
	end
	else if (rd && rd_col_addr==3)begin
	    rd_row_addr <= rd_row_addr-1;
		rd_col_addr <= 0;
	end
	else if(rd)begin
	    rd_row_addr <= rd_row_addr;
		rd_col_addr <= rd_col_addr+1;
	end	
	else begin
		rd_row_addr <=rd_row_addr;
		rd_col_addr <=rd_col_addr;
	end
end

//Q_input
always @(posedge clk or posedge rst) begin
	if (rst) begin
	     rd_data_Q[0] <= 0;
	     rd_data_Q[1] <= 0;
	     rd_data_Q[2] <= 0;
	     rd_data_Q[3] <= 0;
    end
    else if(rd_row_addr==0&&rd_col_addr==3)begin
         rd_data_Q[0] <= 12'b0100_0000_0000;
	     rd_data_Q[1] <= 0;
	     rd_data_Q[2] <= 0;
	     rd_data_Q[3] <= 0;
	end     
	else if(rd_row_addr==1&&rd_col_addr==3)begin
         rd_data_Q[0] <= 0;
	     rd_data_Q[1] <= 12'b0100_0000_0000;
	     rd_data_Q[2] <= 0;
	     rd_data_Q[3] <= 0;
	end
	else if(rd_row_addr==2&&rd_col_addr==3)begin
         rd_data_Q[0] <= 0;
	     rd_data_Q[1] <= 0;
	     rd_data_Q[2] <= 12'b0100_0000_0000;
	     rd_data_Q[3] <= 0;
	end
	else if(rd_row_addr==3&&rd_col_addr==3)begin
         rd_data_Q[0] <= 0;
	     rd_data_Q[1] <= 0;
	     rd_data_Q[2] <= 0;
	     rd_data_Q[3] <= 12'b0100_0000_0000;
	end
	else begin
         rd_data_Q[0]<=rd_data_Q[0];
	     rd_data_Q[1]<=rd_data_Q[1];
	     rd_data_Q[2]<=rd_data_Q[2];
	     rd_data_Q[3]<=rd_data_Q[3];
	end     
end

//read
always @(posedge clk or posedge rst) begin
	if (rst) 
	   rd <= 0;
	else if(en)
	   rd <= 1;
	else
	   rd <= 0;   
end

//write
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_row_addr <= 0;
		wr_col_addr <= 0;
		wr_col_addr_count <= 0;
	end
	else if(wr&&wr_col_addr == 3) begin
		wr_row_addr <= wr_row_addr + 1;
		wr_col_addr <= wr_col_addr_count+1;
		wr_col_addr_count <= wr_col_addr_count +1;
		end
	else if(wr) begin
		wr_row_addr <= wr_row_addr;
		wr_col_addr <= wr_col_addr + 1;
		wr_col_addr_count <= wr_col_addr_count;
	end
	else begin
		wr_row_addr <= wr_row_addr;
		wr_col_addr <= wr_col_addr;
		wr_col_addr_count <= wr_col_addr_count; 
	end
end

//Q_write
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_row_addr_Q <= 0;
		wr_col_addr_Q <= 0;
		wr_row_ready_count_Q <= 0;
	end
	else if(wr_Q&&wr_col_addr_Q == 3) begin
		wr_row_addr_Q <= wr_row_addr_Q + 1;
		wr_col_addr_Q <= 0;
		wr_row_ready_count_Q <= wr_row_ready_count_Q;
		end
	else if(wr_Q&&wr_col_addr_Q == 2) begin
		wr_row_addr_Q <= wr_row_addr_Q;
		wr_col_addr_Q <= wr_col_addr_Q + 1;
		wr_row_ready_count_Q <= wr_row_ready_count_Q+1;
		end	
	else if(wr_Q) begin
		wr_row_addr_Q <= wr_row_addr_Q;
		wr_col_addr_Q <= wr_col_addr_Q + 1;
		wr_row_ready_count_Q <= wr_row_ready_count_Q ;
	end
	else begin
		wr_row_addr_Q <= wr_row_addr_Q;
		wr_col_addr_Q <= wr_col_addr_Q;
		wr_row_ready_count_Q <= wr_row_ready_count_Q;
	end
end


//wr
always @(posedge clk or posedge rst) begin
	if (rst) begin
		wr_data <= 0;
		wr <= 0;
	end
	else if((last_multk_gg1||last_multk_gr11||last_multk_gr12||last_multk_gr13)&&wr_row_addr==0) begin //r11~r14
		wr <= 1; 
        wr_data <= xo_mk1;
	end
	else if((last_multk_gg2||last_multk_gr21||last_multk_gr22)&&wr_row_addr==1) begin //r22~r24
		wr <= 1; 
        wr_data <= xo_mk2;
	end
	else if((last_multk_gg3||last_multk_gr31)&&wr_row_addr==2) begin //r33~r34
		wr <= 1; 
        wr_data <= xo_mk3;
	end
	else if(wr_row_addr==2&&wr_col_addr==3) begin //r44
		wr <= 1; 
        wr_data <= final_r44;
	end						
	else begin
		wr_data <= 0;
		wr <= 0;
	end
end

//wr_Q
always @(posedge clk or posedge rst) begin
	if (rst) begin
	    wr_Q <= 0;
		wr_data_Q <= 0;
	end
	else if(wr_row_ready_count_Q==0&&(last_multk_Q11||last_multk_Q12||last_multk_Q13||last_multk_Q14)) begin
	    wr_Q <= 1;
        wr_data_Q <= xo_mk1_Q;
	end
	else if(wr_row_ready_count_Q==1) begin
	    wr_Q <= 1;   
        wr_data_Q <= xo_mk2_Q;
	end
	else if(wr_row_ready_count_Q==2) begin
	    wr_Q <= 1;
        wr_data_Q <= xo_mk3_Q;
	end
	else if(wr_row_ready_count_Q==3) begin
        case(wr_col_addr_Q)
            0:begin
                wr_Q <= 1;
                wr_data_Q <= final_Q42;
               end
            1:begin
                wr_Q <= 1;
                wr_data_Q <= final_Q43;
               end
            2:begin
                wr_Q <= 1;
                wr_data_Q <= final_Q44;
               end
            3:begin
                wr_Q <= 1;
                wr_data_Q <= final_Q41;
               end         
        endcase    
	end						
	else begin
	    wr_Q <= 0;
		wr_data_Q <= 0;
	end
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        final_Q41 <= 0;
        final_Q42 <= 0;
        final_Q43 <= 0;
        final_Q44 <= 0;    
    end 
    else begin
        case({last_multk_Q31,last_multk_Q32,last_multk_Q33,last_multk_Q34})
			4'b1000 : begin
						final_Q41 <= yo_mk3_Q;
						final_Q42 <= final_Q42;
						final_Q43 <= final_Q43;
						final_Q44 <= final_Q44;    
			end
			4'b0100 : begin
						final_Q41 <= final_Q41;
						final_Q42 <= yo_mk3_Q;
						final_Q43 <= final_Q43;
						final_Q44 <= final_Q44;    
            end           
			4'b0010 : begin              
                      final_Q41 <= final_Q41;
                      final_Q42 <= final_Q42;
                      final_Q43 <= yo_mk3_Q;
                      final_Q44 <= final_Q44;    
            end           
			4'b0001 : begin               
						final_Q41 <= final_Q41;
						final_Q42 <= final_Q42;
						final_Q43 <= final_Q43;
						final_Q44 <= yo_mk3_Q;    
			end           
			default : begin             
						final_Q41 <= final_Q41;
						final_Q42 <= final_Q42;
						final_Q43 <= final_Q43;
						final_Q44 <= final_Q44;    
			end                                                      
        endcase
    end    
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        final_r44 <= 0;
    end 
    else begin
        final_r44 <= yo_mk3;
    end    
end

//finish
always @(posedge clk or posedge rst) begin
    if (rst) begin
        finish <= 0;
	end
	else if(wr_row_addr_Q==3 && wr_col_addr_Q==3) begin
        finish <= 1;
	end
end

//GG1
always @(posedge clk or posedge rst) begin
    if (rst) begin
		iter_gg1 <= 0;
	end
	else begin
		iter_gg1 <= iter_gg1_n;
	end   	    
end

always @(*) begin
    case(state)
		ROT: begin
			if(nop_gg1) begin
				iter_gg1_n = 0;
			end
			else if(end_iter_gg1) begin
				iter_gg1_n = iter_gg1 + 1;
			end
			else begin
				iter_gg1_n = iter_gg1 + 4;
			end
		end
		default: begin
			iter_gg1_n = 0;
		end
	endcase
end

always @(*) begin
	case(state)
		ROT: begin
			if(rd_unready || end_gg1) begin
				nop_gg1 = 1;
			end
			else begin
				nop_gg1 = 0;
			end
		end
		default: begin
			nop_gg1 = 1;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg1 <= 0;
		yi_gg1 <= 0;
	end
	else if(state==ROT || state==MULT_K) begin
	   case(iter_gg1)
			0: begin
				if(start_gg1) begin
					xi_gg1 = 0;
					yi_gg1 = rd_data;
				end
				else if(nop_gg1 && !end_gg1) begin
					xi_gg1 = rd_data;
					yi_gg1 = yo_gg1;
				end
				else begin
					xi_gg1 = xo_gg1;
					yi_gg1 = yo_gg1;
				end
			end
			9: begin
				if(end_gg1) begin
					xi_gg1 = xo_gg1;
					yi_gg1 = yo_gg1;
				end
				else begin
					xi_gg1 = rd_data;
					yi_gg1 = xo_mk1;
				end
			end
			default: begin
				xi_gg1 = xo_gg1;
				yi_gg1 = yo_gg1;
			end
		endcase
	end
	else begin
		xi_gg1 = 0;
		yi_gg1 = 0;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gg1 <= 0;
	end
    else if(state == MULT_K)
	   mk_cnt_gg1 <= mk_cnt_gg1 + 1;
	else begin
		mk_cnt_gg1 <= mk_cnt_gg1;
	end
end

//GR11
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr11 <= 0;	
	end
	else begin
		iter_gr11 <= iter_gg1;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_gr11 <= 0;
	end
	else begin
		nop_gr11 <= nop_gg1;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_gr11 <= 0;
		d2_gr11 <= 0;
		d3_gr11 <= 0;
		d4_gr11 <= 0;
	end
	else begin
		d1_gr11 <= d1_gg1;
		d2_gr11 <= d2_gg1;
		d3_gr11 <= d3_gg1;
		d4_gr11 <= d4_gg1;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_gr11 <= 0;
	end
	else begin
		neg_gr11 <= neg_gg1;
	end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
		xi_gr11 <= 0;
		yi_gr11 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case(iter_gr11)
				0: begin
					if(start_gr11) begin
						xi_gr11 = 0;
						yi_gr11 = rd_data;
					end
					else if(nop_gr11 && !end_gr11) begin
						xi_gr11 = rd_data;
						yi_gr11 = yo_gr11;
					end
					else begin
						xi_gr11 = xo_gr11;
						yi_gr11 = yo_gr11;
					end
				end
				9: begin
					if(end_gr11) begin
						xi_gr11 = xo_mk1; 
						yi_gr11 = yo_mk1;
					end
					else begin
						xi_gr11 = rd_data;
						yi_gr11 = xo_mk1;
					end
				end
				default: begin
					xi_gr11 = xo_gr11;
					yi_gr11 = yo_gr11;
				end
			endcase
		end
		default: begin
			xi_gr11 = 0;
			yi_gr11 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gr11 <= 0;
	end
	else begin
		mk_cnt_gr11 <= mk_cnt_gg1;
	end
end

//GR12
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr12 <= 0;	
	end
	else begin
		iter_gr12 <= iter_gr11;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_gr12 <= 0;
	end
	else begin
		nop_gr12 <= nop_gr11;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_gr12 <= 0;
		d2_gr12 <= 0;
		d3_gr12 <= 0;
		d4_gr12 <= 0;
	end
	else begin
		d1_gr12 <= d1_gr11;
		d2_gr12 <= d2_gr11;
		d3_gr12 <= d3_gr11;
		d4_gr12 <= d4_gr11;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_gr12 <= 0;
	end
	else begin
		neg_gr12 <= neg_gr11;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr12 <= 0;
		yi_gr12 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_gr12)
				0: begin
					if(start_gr12) begin
						xi_gr12 = 0;
						yi_gr12 = rd_data;
					end
					else if(nop_gr12 && !end_gr12) begin
						xi_gr12 = rd_data;
						yi_gr12 = yo_gr12;
					end
					else begin
						xi_gr12 = xo_gr12;
						yi_gr12 = yo_gr12;
					end
				end
				9: begin
					if(end_gr12) begin
						xi_gr12 = xo_mk1; 
						yi_gr12 = yo_mk1;
					end
					else begin
						xi_gr12 = rd_data;
						yi_gr12 = xo_mk1;
					end
				end
				default: begin
					xi_gr12 = xo_gr12;
					yi_gr12 = yo_gr12;
				end
			endcase
		end
		default: begin
			xi_gr12 = 0;
			yi_gr12 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gr12 <= 0;
	end
	else begin
		mk_cnt_gr12 <= mk_cnt_gr11;
	end
end

//GR13
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr13 <= 0;	
	end
	else begin
		iter_gr13 <= iter_gr12;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_gr13 <= 0;
	end
	else begin
		nop_gr13 <= nop_gr12;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_gr13 <= 0;
		d2_gr13 <= 0;
		d3_gr13 <= 0;
		d4_gr13 <= 0;
	end
	else begin
		d1_gr13 <= d1_gr12;
		d2_gr13 <= d2_gr12;
		d3_gr13 <= d3_gr12;
		d4_gr13 <= d4_gr12;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_gr13 <= 0;
	end
	else begin
		neg_gr13 <= neg_gr12;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr13 <= 0;
		yi_gr13 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_gr13)
				0: begin
					if(start_gr13) begin
						xi_gr13 = 0;
						yi_gr13 = rd_data;
					end
					else if(nop_gr13 && !end_gr13) begin
						xi_gr13 = rd_data;
						yi_gr13 = yo_gr13;
					end
					else begin
						xi_gr13 = xo_gr13;
						yi_gr13 = yo_gr13;
					end
				end
				9: begin
					if(end_gr13) begin
						xi_gr13 = xo_mk1; 
						yi_gr13 = yo_mk1;
					end
					else begin
						xi_gr13 = rd_data;
						yi_gr13 = xo_mk1;
					end
				end
				default: begin
					xi_gr13 = xo_gr13;
					yi_gr13 = yo_gr13;
				end
			endcase
		end
		default: begin
			xi_gr13 = 0;
			yi_gr13 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gr13 <= 0;
	end
	else begin
		mk_cnt_gr13 <= mk_cnt_gr12;
	end
end

//GG2
always @(posedge clk or posedge rst) begin
    if (rst) begin
		iter_gg2 <= 0;
	end
	else begin
	    iter_gg2 <= iter_gg2_n;
    end
end    	
always @(*) begin	
	case(state)
		ROT,MULT_K: begin
			if(nop_gg2 || iter_gg2==9) begin
				iter_gg2_n = 0;
			end
			else if(end_iter_gg2) begin
				iter_gg2_n = iter_gg2 + 1;
			end
			else begin
				iter_gg2_n = iter_gg2 + 4;
			end
		end
		default: begin
			iter_gg2_n = 0;
		end
	endcase
end

always @(*) begin
	case(state)
		ROT,MULT_K: begin
			if(mk_cnt_gr11 <= 1 || end_gg2 || mk_gg2) begin
				nop_gg2 = 1;
			end
			else begin
				nop_gg2 = 0;
			end
		end
		default: begin
			nop_gg2 = 1;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg2 <= 0;
		yi_gg2 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_gg2)
				0: begin
					if(start_gg2) begin
						xi_gg2 = 0;
						yi_gg2 = yo_mk1;
					end
					else if(nop_gg2 && !end_gg2) begin
						xi_gg2 = yo_mk1;
						yi_gg2 = yo_gg2;
					end
					else begin
						xi_gg2 = xo_gg2;
						yi_gg2 = yo_gg2;
					end
				end
				9: begin
					if(end_gg2) begin
						xi_gg2 = xo_gr11;
						yi_gg2 = yo_gr11;
					end
					else begin
						xi_gg2 = yo_mk1;
						yi_gg2 = xo_mk2;
					end
				end
				default: begin
					xi_gg2 = xo_gg2;
					yi_gg2 = yo_gg2;
				end
			endcase
		end
		default: begin
			xi_gg2 = 0;
			yi_gg2 = 0;
		end
	endcase
end
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gg2 <= 0;
	end
	else if(multk_gg2)
	   mk_cnt_gg2 <= mk_cnt_gg2 +1;
	else begin
	   mk_cnt_gg2 <= mk_cnt_gg2;
	end
end

//GR21
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr21 <= 0;	
	end
	else begin
		iter_gr21 <= iter_gg2;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_gr21 <= 0;
	end
	else begin
		nop_gr21 <= nop_gg2;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_gr21 <= 0;
		d2_gr21 <= 0;
		d3_gr21 <= 0;
		d4_gr21 <= 0;
	end
	else begin
		d1_gr21 <= d1_gg2;
		d2_gr21 <= d2_gg2;
		d3_gr21 <= d3_gg2;
		d4_gr21 <= d4_gg2;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_gr21 <= 0;
	end
	else begin
		neg_gr21 <= neg_gg2;
	end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
		xi_gr21 <= 0;
		yi_gr21 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case(iter_gr21)
				0: begin
					if(start_gr21) begin
						xi_gr21 = 0;
						yi_gr21 = yo_mk1;
					end
					else if(nop_gr21 && !end_gr21) begin
						xi_gr21 = yo_mk1;
						yi_gr21 = yo_gr21;
					end
					else begin
						xi_gr21 = xo_gr21;
						yi_gr21 = yo_gr21;
					end
				end
				9: begin
					if(end_gr21) begin
						xi_gr21 = xo_mk2; 
						yi_gr21 = xo_gr12;
					end
					else begin
						xi_gr21 = yo_mk1;
						yi_gr21 = xo_mk2;
					end
				end
				default: begin
					xi_gr21 = xo_gr21;
					yi_gr21 = yo_gr21;
				end
			endcase
		end
		default: begin
			xi_gr21 = 0;
			yi_gr21 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gr21 <= 0;
	end
	else begin
		mk_cnt_gr21 <= mk_cnt_gg2;
	end
end

//GR22
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr22 <= 0;	
	end
	else begin
		iter_gr22 <= iter_gr21;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_gr22 <= 0;
	end
	else begin
		nop_gr22 <= nop_gr21;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_gr22 <= 0;
		d2_gr22 <= 0;
		d3_gr22 <= 0;
		d4_gr22 <= 0;
	end
	else begin
		d1_gr22 <= d1_gr21;
		d2_gr22 <= d2_gr21;
		d3_gr22 <= d3_gr21;
		d4_gr22 <= d4_gr21;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_gr22 <= 0;
	end
	else begin
		neg_gr22 <= neg_gr21;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gr22 <= 0;
		yi_gr22 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_gr22)
				0: begin
					if(start_gr22) begin
						xi_gr22 = 0;
						yi_gr22 = yo_mk1;
					end
					else if(nop_gr22 && !end_gr22) begin
						xi_gr22 = yo_mk1;
						yi_gr22 = yo_gr22;
					end
					else begin
						xi_gr22 = xo_gr22;
						yi_gr22 = yo_gr22;
					end
				end
				9: begin
					if(end_gr22) begin
						xi_gr22 = xo_mk2; 
						yi_gr22 = xo_gr13;
					end
					else begin
						xi_gr22 = yo_mk1;
						yi_gr22 = xo_mk2;
					end
				end
				default: begin
					xi_gr22 = xo_gr22;
					yi_gr22 = yo_gr22;
				end
			endcase
		end
		default: begin
			xi_gr22 = 0;
			yi_gr22 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gr22 <= 0;
	end
	else begin
		mk_cnt_gr22 <= mk_cnt_gr21;
	end
end

//GG3
always @(posedge clk or posedge rst) begin
    if (rst) begin
		iter_gg3 <= 0;
	end
	else begin
	    iter_gg3 <= iter_gg3_n;
	end
end

always @(*) begin	
	case(state)
		ROT,MULT_K: begin
			if(nop_gg3) begin
				iter_gg3_n = 0;
			end
			else if(end_iter_gg3) begin
				iter_gg3_n = iter_gg3 + 1;
			end
			else begin
				iter_gg3_n = iter_gg3 + 4;
			end
		end
		default: begin
			iter_gg3_n = 0;
		end
	endcase
end

always @(*) begin
	case(state)
		ROT,MULT_K: begin
			if(mk_cnt_gr21 <= 1 || end_gg3 || mk_gg3) begin
				nop_gg3 = 1;
			end
			else begin
				nop_gg3 = 0;
			end
		end
		default: begin
			nop_gg3 = 1;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_gg3 <= 0;
		yi_gg3 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_gg3)
				0: begin
					if(start_gg3) begin
						xi_gg3 = 0;
						yi_gg3 = yo_mk2;
					end
					else if(nop_gg3 && !end_gg3) begin
						xi_gg3 = yo_mk2;
						yi_gg3 = yo_gg3;
					end
					else begin
						xi_gg3 = xo_gg3;
						yi_gg3 = yo_gg3;
					end
				end
				9: begin
					if(end_gg3) begin
						xi_gg3 = xo_gr21;
						yi_gg3 = yo_gr21;
					end
					else begin
						xi_gg3 = yo_mk2;
						yi_gg3 = xo_mk3;
					end
				end
				default: begin
					xi_gg3 = xo_gg3;
					yi_gg3 = yo_gg3;
				end
			endcase
		end
		default: begin
			xi_gg3 = 0;
			yi_gg3 = 0;
		end
	endcase
end
always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gg3 <= 0;
	end
	else if(multk_gg3)
	   mk_cnt_gg3 <= mk_cnt_gg3 +1;
	else begin
	   mk_cnt_gg3 <= mk_cnt_gg3;
	end
end

//GR31
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_gr31 <= 0;	
	end
	else begin
		iter_gr31 <= iter_gg3;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_gr31 <= 0;
	end
	else begin
		nop_gr31 <= nop_gg3;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_gr31 <= 0;
		d2_gr31 <= 0;
		d3_gr31 <= 0;
		d4_gr31 <= 0;
	end
	else begin
		d1_gr31 <= d1_gg3;
		d2_gr31 <= d2_gg3;
		d3_gr31 <= d3_gg3;
		d4_gr31 <= d4_gg3;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_gr31 <= 0;
	end
	else begin
		neg_gr31 <= neg_gg3;
	end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
		xi_gr31 <= 0;
		yi_gr31 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case(iter_gr31)
				0: begin
					if(start_gr31) begin
						xi_gr31 = 0;
						yi_gr31 = yo_mk2;
					end
					else if(nop_gr31 && !end_gr31) begin
						xi_gr31 = yo_mk2;
						yi_gr31 = yo_gr31;
					end
					else begin
						xi_gr31 = xo_gr31;
						yi_gr31 = yo_gr31;
					end
				end
				9: begin
					if(end_gr31) begin
						xi_gr31 = xo_mk3; 
						yi_gr31 = xo_gr22;
					end
					else begin
						xi_gr31 = yo_mk2;
						yi_gr31 = xo_mk3;
					end
				end
				default: begin
					xi_gr31 = xo_gr31;
					yi_gr31 = yo_gr31;
				end
			endcase
		end
		default: begin
			xi_gr31 = 0;
			yi_gr31 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_gr31 <= 0;
	end
	else begin
		mk_cnt_gr31 <= mk_cnt_gg3;
	end
end

//MK1
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk1 <= 0;
		yi_mk1 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case({end_iter_gg1, end_iter_gr11, end_iter_gr12, end_iter_gr13})
				4'b1000: begin
					xi_mk1 = xo_gg1;
					yi_mk1 = yo_gg1;
				end
				4'b0100: begin
					xi_mk1 = xo_gr11;
					yi_mk1 = yo_gr11;
				end
				4'b0010: begin
					xi_mk1 = xo_gr12;
					yi_mk1 = yo_gr12;
				end
				4'b0001: begin
					xi_mk1 = xo_gr13;
					yi_mk1 = yo_gr13;
				end
				default: begin
					xi_mk1 = 0;
					yi_mk1 = 0;
				end
			endcase
		end
		default: begin
			xi_mk1 = 0;
			yi_mk1 = 0;
		end
	endcase
end

//MK2
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk2 <= 0;
		yi_mk2 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case({end_iter_gg2, end_iter_gr21, end_iter_gr22})
				3'b100: begin
					xi_mk2 = xo_gg2;
					yi_mk2 = yo_gg2;
				end
				3'b010: begin
					xi_mk2 = xo_gr21;
					yi_mk2 = yo_gr21;
				end
				3'b001: begin
					xi_mk2 = xo_gr22;
					yi_mk2 = yo_gr22;
				end
				default: begin
					xi_mk2 = 0;
					yi_mk2 = 0;
				end
			endcase
		end
		default: begin
			xi_mk2 = 0;
			yi_mk2 = 0;
		end
	endcase
end

//MK3
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk3 <= 0;
		yi_mk3 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case({end_iter_gg3, end_iter_gr31})
				2'b10: begin
					xi_mk3 = xo_gg3;
					yi_mk3 = yo_gg3;
				end
				2'b01: begin
					xi_mk3 = xo_gr31;
					yi_mk3 = yo_gr31;
				end
				default: begin
					xi_mk3 = 0;
					yi_mk3 = 0;
				end
			endcase
		end
		default: begin
			xi_mk3 = 0;
			yi_mk3 = 0;
		end
	endcase
end	

//Q11
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q11 <= 0;	
	end
	else begin
		iter_Q11 <= iter_gr13;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q11 <= 0;
	end
	else begin
		nop_Q11 <= nop_gr13;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q11 <= 0;
		d2_Q11 <= 0;
		d3_Q11 <= 0;
		d4_Q11 <= 0;
	end
	else begin
		d1_Q11 <= d1_gr13;
		d2_Q11 <= d2_gr13;
		d3_Q11 <= d3_gr13;
		d4_Q11 <= d4_gr13;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q11 <= 0;
	end
	else begin
		neg_Q11 <= neg_gr13;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_Q11 <= 0;
		yi_Q11 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_Q11)
				0: begin
					if(start_Q11) begin
						xi_Q11 = 0;
						yi_Q11 = rd_data_Q[0];
					end
					else if(nop_Q11 && !end_Q11) begin
						xi_Q11 = rd_data_Q[0];
						yi_Q11 = yo_Q11;
					end
					else begin
						xi_Q11 = xo_Q11;
						yi_Q11 = yo_Q11;
					end
				end
				9: begin
					if(end_Q11) begin
						xi_Q11 = xo_mk1_Q; 
						yi_Q11 = yo_mk1_Q;
					end
					else begin
						xi_Q11 = rd_data_Q[0];
						yi_Q11 = xo_mk1_Q;
					end
				end
				default: begin
					xi_Q11 = xo_Q11;
					yi_Q11 = yo_Q11;
				end
			endcase
		end
		default: begin
			xi_Q11 = 0;
			yi_Q11 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q11 <= 0;
	end
	else begin
		mk_cnt_Q11 <= mk_cnt_gr13;
	end
end

//Q12
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q12 <= 0;	
	end
	else begin
		iter_Q12 <= iter_Q11;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q12 <= 0;
	end
	else begin
		nop_Q12 <= nop_Q11;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q12 <= 0;
		d2_Q12 <= 0;
		d3_Q12 <= 0;
		d4_Q12 <= 0;
	end
	else begin
		d1_Q12 <= d1_Q11;
		d2_Q12 <= d2_Q11;
		d3_Q12 <= d3_Q11;
		d4_Q12 <= d4_Q11;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q12 <= 0;
	end
	else begin
		neg_Q12 <= neg_Q11;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_Q12 <= 0;
		yi_Q12 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_Q12)
				0: begin
					if(start_Q12) begin
						xi_Q12 = 0;
						yi_Q12 = rd_data_Q[1];
					end
					else if(nop_Q12 && !end_Q12) begin
						xi_Q12 = rd_data_Q[1];
						yi_Q12 = yo_Q12;
					end
					else begin
						xi_Q12 = xo_Q12;
						yi_Q12 = yo_Q12;
					end
				end
				9: begin
					if(end_Q12) begin
						xi_Q12 = xo_mk1_Q; 
						yi_Q12 = yo_mk1_Q;
					end
					else begin
						xi_Q12 = rd_data_Q[1];
						yi_Q12 = xo_mk1_Q;
					end
				end
				default: begin
					xi_Q12 = xo_Q12;
					yi_Q12 = yo_Q12;
				end
			endcase
		end
		default: begin
			xi_Q12 = 0;
			yi_Q12 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q12 <= 0;
	end
	else begin
		mk_cnt_Q12 <= mk_cnt_Q11;
	end
end

//Q13
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q13 <= 0;	
	end
	else begin
		iter_Q13 <= iter_Q12;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q13 <= 0;
	end
	else begin
		nop_Q13 <= nop_Q12;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q13 <= 0;
		d2_Q13 <= 0;
		d3_Q13 <= 0;
		d4_Q13 <= 0;
	end
	else begin
		d1_Q13 <= d1_Q12;
		d2_Q13 <= d2_Q12;
		d3_Q13 <= d3_Q12;
		d4_Q13 <= d4_Q12;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q13 <= 0;
	end
	else begin
		neg_Q13 <= neg_Q12;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_Q13 <= 0;
		yi_Q13 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_Q13)
				0: begin
					if(start_Q13) begin
						xi_Q13 = 0;
						yi_Q13 = rd_data_Q[2];
					end
					else if(nop_Q13 && !end_Q13) begin
						xi_Q13 = rd_data_Q[2];
						yi_Q13 = yo_Q13;
					end
					else begin
						xi_Q13 = xo_Q13;
						yi_Q13 = yo_Q13;
					end
				end
				9: begin
					if(end_Q13) begin
						xi_Q13 = xo_mk1_Q; 
						yi_Q13 = yo_mk1_Q;
					end
					else begin
						xi_Q13 = rd_data_Q[2];
						yi_Q13 = xo_mk1_Q;
					end
				end
				default: begin
					xi_Q13 = xo_Q13;
					yi_Q13 = yo_Q13;
				end
			endcase
		end
		default: begin
			xi_Q13 = 0;
			yi_Q13 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q13 <= 0;
	end
	else begin
		mk_cnt_Q13 <= mk_cnt_Q12;
	end
end

//Q14
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q14 <= 0;	
	end
	else begin
		iter_Q14 <= iter_Q13;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q14 <= 0;
	end
	else begin
		nop_Q14 <= nop_Q13;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q14 <= 0;
		d2_Q14 <= 0;
		d3_Q14 <= 0;
		d4_Q14 <= 0;
	end
	else begin
		d1_Q14 <= d1_Q13;
		d2_Q14 <= d2_Q13;
		d3_Q14 <= d3_Q13;
		d4_Q14 <= d4_Q13;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q14 <= 0;
	end
	else begin
		neg_Q14 <= neg_Q13;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_Q14 <= 0;
		yi_Q14 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_Q14)
				0: begin
					if(start_Q14) begin
						xi_Q14 = 0;
						yi_Q14 = rd_data_Q[3];
					end
					else if(nop_Q14 && !end_Q14) begin
						xi_Q14 = rd_data_Q[3];
						yi_Q14 = yo_Q14;
					end
					else begin
						xi_Q14 = xo_Q14;
						yi_Q14 = yo_Q14;
					end
				end
				9: begin
					if(end_Q14) begin
						xi_Q14 = xo_mk1_Q; 
						yi_Q14 = yo_mk1_Q;
					end
					else begin
						xi_Q14 = rd_data_Q[3];
						yi_Q14 = xo_mk1_Q;
					end
				end
				default: begin
					xi_Q14 = xo_Q14;
					yi_Q14 = yo_Q14;
				end
			endcase
		end
		default: begin
			xi_Q14 = 0;
			yi_Q14 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q14 <= 0;
	end
	else begin
		mk_cnt_Q14 <= mk_cnt_Q13;
	end
end

//Q21
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q21 <= 0;	
	end
	else begin
		iter_Q21 <= iter_gr22;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q21 <= 0;
	end
	else begin
		nop_Q21 <= nop_gr22;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q21 <= 0;
		d2_Q21 <= 0;
		d3_Q21 <= 0;
		d4_Q21 <= 0;
	end
	else begin
		d1_Q21 <= d1_gr22;
		d2_Q21 <= d2_gr22;
		d3_Q21 <= d3_gr22;
		d4_Q21 <= d4_gr22;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q21 <= 0;
	end
	else begin
		neg_Q21 <= neg_gr22;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_Q21 <= 0;
		yi_Q21 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_Q21)
				0: begin
					if(start_Q21) begin
						xi_Q21 = 0;
						yi_Q21 = yo_mk1_Q;
					end
					else if(nop_Q21 && !end_Q21) begin
						xi_Q21 = yo_mk1_Q;
						yi_Q21 = yo_Q21;
					end
					else begin
						xi_Q21 = xo_Q21;
						yi_Q21 = yo_Q21;
					end
				end
				9: begin
					if(end_Q21) begin
						xi_Q21 = xo_mk2_Q; 
						yi_Q21 = xo_Q11;
					end
					else begin
						xi_Q21 = yo_mk1_Q;
						yi_Q21 = xo_mk2_Q;
					end
				end
				default: begin
					xi_Q21 = xo_Q21;
					yi_Q21 = yo_Q21;
				end
			endcase
		end
		default: begin
			xi_Q21 = 0;
			yi_Q21 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q21 <= 0;
	end
	else begin
		mk_cnt_Q21 <= mk_cnt_gr22;
	end
end

//Q22
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q22 <= 0;	
	end
	else begin
		iter_Q22 <= iter_Q21;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q22 <= 0;
	end
	else begin
		nop_Q22 <= nop_Q21;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q22 <= 0;
		d2_Q22 <= 0;
		d3_Q22 <= 0;
		d4_Q22 <= 0;
	end
	else begin
		d1_Q22 <= d1_Q21;
		d2_Q22 <= d2_Q21;
		d3_Q22 <= d3_Q21;
		d4_Q22 <= d4_Q21;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q22 <= 0;
	end
	else begin
		neg_Q22 <= neg_Q21;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_Q22 <= 0;
		yi_Q22 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_Q22)
				0: begin
					if(start_Q22) begin
						xi_Q22 = 0;
						yi_Q22 = yo_mk1_Q;
					end
					else if(nop_Q22 && !end_Q22) begin
						xi_Q22 = yo_mk1_Q;
						yi_Q22 = yo_Q22;
					end
					else begin
						xi_Q22 = xo_Q22;
						yi_Q22 = yo_Q22;
					end
				end
				9: begin
					if(end_Q22) begin
						xi_Q22 = xo_mk2_Q; 
						yi_Q22 = xo_Q12;
					end
					else begin
						xi_Q22 = yo_mk1_Q;
						yi_Q22 = xo_mk2_Q;
					end
				end
				default: begin
					xi_Q22 = xo_Q22;
					yi_Q22 = yo_Q22;
				end
			endcase
		end
		default: begin
			xi_Q22 = 0;
			yi_Q22 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q22 <= 0;
	end
	else begin
		mk_cnt_Q22 <= mk_cnt_Q21;
	end
end

//Q23
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q23 <= 0;	
	end
	else begin
		iter_Q23 <= iter_Q22;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q23 <= 0;
	end
	else begin
		nop_Q23 <= nop_Q22;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q23 <= 0;
		d2_Q23 <= 0;
		d3_Q23 <= 0;
		d4_Q23 <= 0;
	end
	else begin
		d1_Q23 <= d1_Q22;
		d2_Q23 <= d2_Q22;
		d3_Q23 <= d3_Q22;
		d4_Q23 <= d4_Q22;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q23 <= 0;
	end
	else begin
		neg_Q23 <= neg_Q22;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_Q23 <= 0;
		yi_Q23 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_Q23)
				0: begin
					if(start_Q23) begin
						xi_Q23 = 0;
						yi_Q23 = yo_mk1_Q;
					end
					else if(nop_Q23 && !end_Q23) begin
						xi_Q23 = yo_mk1_Q;
						yi_Q23 = yo_Q23;
					end
					else begin
						xi_Q23 = xo_Q23;
						yi_Q23 = yo_Q23;
					end
				end
				9: begin
					if(end_Q23) begin
						xi_Q23 = xo_mk2_Q; 
						yi_Q23 = xo_Q13;
					end
					else begin
						xi_Q23 = yo_mk1_Q;
						yi_Q23 = xo_mk2_Q;
					end
				end
				default: begin
					xi_Q23 = xo_Q23;
					yi_Q23 = yo_Q23;
				end
			endcase
		end
		default: begin
			xi_Q23 = 0;
			yi_Q23 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q23 <= 0;
	end
	else begin
		mk_cnt_Q23 <= mk_cnt_Q22;
	end
end

//Q24
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q24 <= 0;	
	end
	else begin
		iter_Q24 <= iter_Q23;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q24 <= 0;
	end
	else begin
		nop_Q24 <= nop_Q23;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q24 <= 0;
		d2_Q24 <= 0;
		d3_Q24 <= 0;
		d4_Q24 <= 0;
	end
	else begin
		d1_Q24 <= d1_Q23;
		d2_Q24 <= d2_Q23;
		d3_Q24 <= d3_Q23;
		d4_Q24 <= d4_Q23;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q24 <= 0;
	end
	else begin
		neg_Q24 <= neg_Q23;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_Q24 <= 0;
		yi_Q24 <= 0;
	end
	else 
	case(state)
		ROT, MULT_K: begin
			case(iter_Q24)
				0: begin
					if(start_Q24) begin
						xi_Q24 = 0;
						yi_Q24 = yo_mk1_Q;
					end
					else if(nop_Q24 && !end_Q24) begin
						xi_Q24 = yo_mk1_Q;
						yi_Q24 = yo_Q24;
					end
					else begin
						xi_Q24 = xo_Q24;
						yi_Q24 = yo_Q24;
					end
				end
				9: begin
					if(end_Q24) begin
						xi_Q24 = xo_mk2_Q; 
						yi_Q24 = xo_Q14;
					end
					else begin
						xi_Q24 = yo_mk1_Q;
						yi_Q24 = xo_mk2_Q;
					end
				end
				default: begin
					xi_Q24 = xo_Q24;
					yi_Q24 = yo_Q24;
				end
			endcase
		end
		default: begin
			xi_Q24 = 0;
			yi_Q24 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q24 <= 0;
	end
	else begin
		mk_cnt_Q24 <= mk_cnt_Q23;
	end
end

//Q31
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q31 <= 0;	
	end
	else begin
		iter_Q31 <= iter_gr31;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q31 <= 0;
	end
	else begin
		nop_Q31 <= nop_gr31;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q31 <= 0;
		d2_Q31 <= 0;
		d3_Q31 <= 0;
		d4_Q31 <= 0;
	end
	else begin
		d1_Q31 <= d1_gr31;
		d2_Q31 <= d2_gr31;
		d3_Q31 <= d3_gr31;
		d4_Q31 <= d4_gr31;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q31 <= 0;
	end
	else begin
		neg_Q31 <= neg_gr31;
	end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
		xi_Q31 <= 0;
		yi_Q31 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case(iter_Q31)
				0: begin
					if(start_Q31) begin
						xi_Q31 = 0;
						yi_Q31 = yo_mk2_Q;
					end
					else if(nop_Q31 && !end_Q31) begin
						xi_Q31 = yo_mk2_Q;
						yi_Q31 = yo_Q31;
					end
					else begin
						xi_Q31 = xo_Q31;
						yi_Q31 = yo_Q31;
					end
				end
				9: begin
					if(end_Q31) begin
						xi_Q31 = xo_mk3_Q; 
						yi_Q31 = xo_Q21;
					end
					else begin
						xi_Q31 = yo_mk2_Q;
						yi_Q31 = xo_mk3_Q;
					end
				end
				default: begin
					xi_Q31 = xo_Q31;
					yi_Q31 = yo_Q31;
				end
			endcase
		end
		default: begin
			xi_Q31 = 0;
			yi_Q31 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q31 <= 0;
	end
	else begin
		mk_cnt_Q31 <= mk_cnt_gr31;
	end
end

//Q32
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q32 <= 0;	
	end
	else begin
		iter_Q32 <= iter_Q31;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q32 <= 0;
	end
	else begin
		nop_Q32 <= nop_Q31;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q32 <= 0;
		d2_Q32 <= 0;
		d3_Q32 <= 0;
		d4_Q32 <= 0;
	end
	else begin
		d1_Q32 <= d1_Q31;
		d2_Q32 <= d2_Q31;
		d3_Q32 <= d3_Q31;
		d4_Q32 <= d4_Q31;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q32 <= 0;
	end
	else begin
		neg_Q32 <= neg_Q31;
	end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
		xi_Q32 <= 0;
		yi_Q32 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case(iter_Q32)
				0: begin
					if(start_Q32) begin
						xi_Q32 = 0;
						yi_Q32 = yo_mk2_Q;
					end
					else if(nop_Q32 && !end_Q32) begin
						xi_Q32 = yo_mk2_Q;
						yi_Q32 = yo_Q32;
					end
					else begin
						xi_Q32 = xo_Q32;
						yi_Q32 = yo_Q32;
					end
				end
				9: begin
					if(end_Q32) begin
						xi_Q32 = xo_mk3_Q; 
						yi_Q32 = xo_Q22;
					end
					else begin
						xi_Q32 = yo_mk2_Q;
						yi_Q32 = xo_mk3_Q;
					end
				end
				default: begin
					xi_Q32 = xo_Q32;
					yi_Q32 = yo_Q32;
				end
			endcase
		end
		default: begin
			xi_Q32 = 0;
			yi_Q32 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q32 <= 0;
	end
	else begin
		mk_cnt_Q32 <= mk_cnt_Q31;
	end
end

//Q33
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q33 <= 0;	
	end
	else begin
		iter_Q33 <= iter_Q32;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q33 <= 0;
	end
	else begin
		nop_Q33 <= nop_Q32;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q33 <= 0;
		d2_Q33 <= 0;
		d3_Q33 <= 0;
		d4_Q33 <= 0;
	end
	else begin
		d1_Q33 <= d1_Q32;
		d2_Q33 <= d2_Q32;
		d3_Q33 <= d3_Q32;
		d4_Q33 <= d4_Q32;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q33 <= 0;
	end
	else begin
		neg_Q33 <= neg_Q32;
	end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
		xi_Q33 <= 0;
		yi_Q33 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case(iter_Q33)
				0: begin
					if(start_Q33) begin
						xi_Q33 = 0;
						yi_Q33 = yo_mk2_Q;
					end
					else if(nop_Q33 && !end_Q33) begin
						xi_Q33 = yo_mk2_Q;
						yi_Q33 = yo_Q33;
					end
					else begin
						xi_Q33 = xo_Q33;
						yi_Q33 = yo_Q33;
					end
				end
				9: begin
					if(end_Q33) begin
						xi_Q33 = xo_mk3_Q; 
						yi_Q33 = xo_Q23;
					end
					else begin
						xi_Q33 = yo_mk2_Q;
						yi_Q33 = xo_mk3_Q;
					end
				end
				default: begin
					xi_Q33 = xo_Q33;
					yi_Q33 = yo_Q33;
				end
			endcase
		end
		default: begin
			xi_Q33 = 0;
			yi_Q33 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q33 <= 0;
	end
	else begin
		mk_cnt_Q33 <= mk_cnt_Q32;
	end
end

//Q34
always @(posedge clk or posedge rst) begin
	if (rst) begin
		iter_Q34 <= 0;	
	end
	else begin
		iter_Q34<= iter_Q33;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		nop_Q34 <= 0;
	end
	else begin
		nop_Q34 <= nop_Q33;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		d1_Q34 <= 0;
		d2_Q34 <= 0;
		d3_Q34 <= 0;
		d4_Q34 <= 0;
	end
	else begin
		d1_Q34 <= d1_Q33;
		d2_Q34 <= d2_Q33;
		d3_Q34 <= d3_Q33;
		d4_Q34 <= d4_Q33;
	end
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		neg_Q34 <= 0;
	end
	else begin
		neg_Q34 <= neg_Q33;
	end
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
		xi_Q34 <= 0;
		yi_Q34 <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case(iter_Q34)
				0: begin
					if(start_Q34) begin
						xi_Q34 = 0;
						yi_Q34 = yo_mk2_Q;
					end
					else if(nop_Q34 && !end_Q34) begin
						xi_Q34 = yo_mk2_Q;
						yi_Q34 = yo_Q34;
					end
					else begin
						xi_Q34 = xo_Q34;
						yi_Q34 = yo_Q34;
					end
				end
				9: begin
					if(end_Q34) begin
						xi_Q34 = xo_mk3_Q; 
						yi_Q34 = xo_Q24;
					end
					else begin
						xi_Q34 = yo_mk2_Q;
						yi_Q34 = xo_mk3_Q;
					end
				end
				default: begin
					xi_Q34 = xo_Q34;
					yi_Q34 = yo_Q34;
				end
			endcase
		end
		default: begin
			xi_Q34 = 0;
			yi_Q34 = 0;
		end
	endcase
end

always @(posedge clk or posedge rst) begin
	if (rst) begin
		mk_cnt_Q34 <= 0;
	end
	else begin
		mk_cnt_Q34 <= mk_cnt_Q33;
	end
end

//MK1_Q
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk1_Q <= 0;
		yi_mk1_Q <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case({end_iter_Q11, end_iter_Q12, end_iter_Q13, end_iter_Q14})
				4'b1000: begin
					xi_mk1_Q = xo_Q11;
					yi_mk1_Q = yo_Q11;
				end
				4'b0100: begin
					xi_mk1_Q = xo_Q12;
					yi_mk1_Q = yo_Q12;
				end
				4'b0010: begin
					xi_mk1_Q = xo_Q13;
					yi_mk1_Q = yo_Q13;
				end
				4'b0001: begin
					xi_mk1_Q = xo_Q14;
					yi_mk1_Q = yo_Q14;
				end
				default: begin
					xi_mk1_Q = 0;
					yi_mk1_Q = 0;
				end
			endcase
		end
		default: begin
			xi_mk1_Q = 0;
			yi_mk1_Q = 0;
		end
	endcase
end

//MK2_Q
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk2_Q <= 0;
		yi_mk2_Q <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case({end_iter_Q21, end_iter_Q22, end_iter_Q23, end_iter_Q24})
				4'b1000: begin
					xi_mk2_Q = xo_Q21;
					yi_mk2_Q = yo_Q21;
				end
				4'b0100: begin
					xi_mk2_Q = xo_Q22;
					yi_mk2_Q = yo_Q22;
				end
				4'b0010: begin
					xi_mk2_Q = xo_Q23;
					yi_mk2_Q = yo_Q23;
				end
				4'b0001: begin
					xi_mk2_Q = xo_Q24;
					yi_mk2_Q = yo_Q24;
				end
				default: begin
					xi_mk2_Q = 0;
					yi_mk2_Q = 0;
				end
			endcase
		end
		default: begin
			xi_mk2_Q = 0;
			yi_mk2_Q = 0;
		end
	endcase
end

//MK3_Q
always @(posedge clk or posedge rst) begin
	if (rst) begin
		xi_mk3_Q <= 0;
		yi_mk3_Q <= 0;
	end
	else
	case(state)
		ROT, MULT_K: begin
			case({end_iter_Q31, end_iter_Q32, end_iter_Q33, end_iter_Q34})
				4'b1000: begin
					xi_mk3_Q = xo_Q31;
					yi_mk3_Q = yo_Q31;
				end
				4'b0100: begin
					xi_mk3_Q = xo_Q32;
					yi_mk3_Q = yo_Q32;
				end
				4'b0010: begin
					xi_mk3_Q = xo_Q33;
					yi_mk3_Q = yo_Q33;
				end
				4'b0001: begin
					xi_mk3_Q = xo_Q34;
					yi_mk3_Q = yo_Q34;
				end
				default: begin
					xi_mk3_Q = 0;
					yi_mk3_Q = 0;
				end
			endcase
		end
		default: begin
			xi_mk3_Q = 0;
			yi_mk3_Q = 0;
		end
	endcase
end
////////////////////////////////////////module instantiation /////////////////////////////////////////////

GG GG1 (
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

GR GR11 (
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

GR GR12 (
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

GR GR13 (
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

GG GG2 (
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

GR GR21 (
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

GR GR22 (
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

GG GG3 (
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

GR GR31 (
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

MK MK1 (
	.xi (xi_mk1),
	.yi (yi_mk1),
	.xo (xo_mk1),
	.yo (yo_mk1)
);

MK MK2 (
	.xi (xi_mk2),
	.yi (yi_mk2),
	.xo (xo_mk2),
	.yo (yo_mk2)
);

MK MK3 (
	.xi (xi_mk3),
	.yi (yi_mk3),
	.xo (xo_mk3),
	.yo (yo_mk3)
);

Q Q11 (
	.nop  (nop_Q11),
	.xi   (xi_Q11),
	.yi   (yi_Q11),
	.iter (iter_Q11),
	.d1   (d1_Q11),
	.d2   (d2_Q11),
	.d3   (d3_Q11),
	.d4   (d4_Q11),
	.neg  (neg_Q11),
	.xo   (xo_Q11),
	.yo   (yo_Q11)
);

Q Q12 (
	.nop  (nop_Q12),
	.xi   (xi_Q12),
	.yi   (yi_Q12),
	.iter (iter_Q12),
	.d1   (d1_Q12),
	.d2   (d2_Q12),
	.d3   (d3_Q12),
	.d4   (d4_Q12),
	.neg  (neg_Q12),
	.xo   (xo_Q12),
	.yo   (yo_Q12)
);

Q Q13 (
	.nop  (nop_Q13),
	.xi   (xi_Q13),
	.yi   (yi_Q13),
	.iter (iter_Q13),
	.d1   (d1_Q13),
	.d2   (d2_Q13),
	.d3   (d3_Q13),
	.d4   (d4_Q13),
	.neg  (neg_Q13),
	.xo   (xo_Q13),
	.yo   (yo_Q13)
);

Q Q14 (
	.nop  (nop_Q14),
	.xi   (xi_Q14),
	.yi   (yi_Q14),
	.iter (iter_Q14),
	.d1   (d1_Q14),
	.d2   (d2_Q14),
	.d3   (d3_Q14),
	.d4   (d4_Q14),
	.neg  (neg_Q14),
	.xo   (xo_Q14),
	.yo   (yo_Q14)
);

Q Q21(
	.nop  (nop_Q21),
	.xi   (xi_Q21),
	.yi   (yi_Q21),
	.iter (iter_Q21),
	.d1   (d1_Q21),
	.d2   (d2_Q21),
	.d3   (d3_Q21),
	.d4   (d4_Q21),
	.neg  (neg_Q21),
	.xo   (xo_Q21),
	.yo   (yo_Q21)
);

Q Q22(
	.nop  (nop_Q22),
	.xi   (xi_Q22),
	.yi   (yi_Q22),
	.iter (iter_Q22),
	.d1   (d1_Q22),
	.d2   (d2_Q22),
	.d3   (d3_Q22),
	.d4   (d4_Q22),
	.neg  (neg_Q22),
	.xo   (xo_Q22),
	.yo   (yo_Q22)
);

Q Q23(
	.nop  (nop_Q23),
	.xi   (xi_Q23),
	.yi   (yi_Q23),
	.iter (iter_Q23),
	.d1   (d1_Q23),
	.d2   (d2_Q23),
	.d3   (d3_Q23),
	.d4   (d4_Q23),
	.neg  (neg_Q23),
	.xo   (xo_Q23),
	.yo   (yo_Q23)
);

Q Q24(
	.nop  (nop_Q24),
	.xi   (xi_Q24),
	.yi   (yi_Q24),
	.iter (iter_Q24),
	.d1   (d1_Q24),
	.d2   (d2_Q24),
	.d3   (d3_Q24),
	.d4   (d4_Q24),
	.neg  (neg_Q24),
	.xo   (xo_Q24),
	.yo   (yo_Q24)
);

Q Q31(
	.nop  (nop_Q31),
	.xi   (xi_Q31),
	.yi   (yi_Q31),
	.iter (iter_Q31),
	.d1   (d1_Q31),
	.d2   (d2_Q31),
	.d3   (d3_Q31),
	.d4   (d4_Q31),
	.neg  (neg_Q31),
	.xo   (xo_Q31),
	.yo   (yo_Q31)
);

Q Q32(
	.nop  (nop_Q32),
	.xi   (xi_Q32),
	.yi   (yi_Q32),
	.iter (iter_Q32),
	.d1   (d1_Q32),
	.d2   (d2_Q32),
	.d3   (d3_Q32),
	.d4   (d4_Q32),
	.neg  (neg_Q32),
	.xo   (xo_Q32),
	.yo   (yo_Q32)
);

Q Q33(
	.nop  (nop_Q33),
	.xi   (xi_Q33),
	.yi   (yi_Q33),
	.iter (iter_Q33),
	.d1   (d1_Q33),
	.d2   (d2_Q33),
	.d3   (d3_Q33),
	.d4   (d4_Q33),
	.neg  (neg_Q33),
	.xo   (xo_Q33),
	.yo   (yo_Q33)
);

Q Q34(
	.nop  (nop_Q34),
	.xi   (xi_Q34),
	.yi   (yi_Q34),
	.iter (iter_Q34),
	.d1   (d1_Q34),
	.d2   (d2_Q34),
	.d3   (d3_Q34),
	.d4   (d4_Q34),
	.neg  (neg_Q34),
	.xo   (xo_Q34),
	.yo   (yo_Q34)
);

MK MK1_Q (
	.xi (xi_mk1_Q),
	.yi (yi_mk1_Q),
	.xo (xo_mk1_Q),
	.yo (yo_mk1_Q)
);

MK MK2_Q (
	.xi (xi_mk2_Q),
	.yi (yi_mk2_Q),
	.xo (xo_mk2_Q),
	.yo (yo_mk2_Q)
);

MK MK3_Q (
	.xi (xi_mk3_Q),
	.yi (yi_mk3_Q),
	.xo (xo_mk3_Q),
	.yo (yo_mk3_Q)
);

endmodule

