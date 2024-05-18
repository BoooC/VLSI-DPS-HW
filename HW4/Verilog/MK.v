module MK #(
	parameter R_LEN   	= 12,
	parameter R_FRAC 	= 3,
	parameter K_LEN 	= 10,
	parameter K_FRAC 	= 9
)(
	input	signed [R_LEN-1:0]	xi,
	input	signed [R_LEN-1:0]	yi,
	output	signed [R_LEN-1:0]	xo,
	output	signed [R_LEN-1:0]	yo
);

localparam signed K = 10'b0_100110111; // K = 0.607421875

wire signed [R_LEN+K_LEN-1:0]  xo_temp;
wire signed [R_LEN+K_LEN-1:0]  yo_temp;

assign xo_temp = xi * K;
assign yo_temp = yi * K;

// truncate to R_LEN bits
assign xo = xo_temp[R_LEN+K_FRAC-1 : K_FRAC];
assign yo = yo_temp[R_LEN+K_FRAC-1 : K_FRAC];

endmodule
