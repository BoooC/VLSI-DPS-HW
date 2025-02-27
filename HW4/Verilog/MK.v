module MK #(
	parameter R_LEN  = 12,
	parameter R_FRAC = 2,
	parameter K_LEN  = 10,
	parameter K_FRAC = 9
)(
	input        signed [R_LEN-1:0]        xi,
	input        signed [R_LEN-1:0]        yi,
	output       signed [R_LEN-1:0]        xo,
	output       signed [R_LEN-1:0]        yo
);

// K : 1 signed bit, 0 integal bit, 9 fraction bits
localparam signed K = 10'b0_100110111; // K = 0.607421875

wire signed [R_LEN+K_LEN-1:0] xo_0 = xi * K;
wire signed [R_LEN+K_LEN-1:0] yo_0 = yi * K;

// truncate to R_LEN bits
assign xo = xo_0[R_LEN+K_FRAC-1:K_FRAC];
assign yo = yo_0[R_LEN+K_FRAC-1:K_FRAC];

endmodule