clc; 
clear;
format;

%%% QR factorization : A = Q * R, 
%	where Q is unitary matrix, R is upper triangular matrix

%%% parameters setting
iter_num = 12;

sign_bit = 1;
int_bit  = 7;
frac_bit = 10; % offset (shift 10 bits as int for hardware)

row = 8;
col = 4;

%%% Generate a 8x4 matrix A of 8-bit random signed integers with full column rank 4
A = [  -91,    65,   112,   -52;
      -123,    14,   -63,    23;
       118,   -19,     8,   -76;
       120,   -60,   116,    34;
       -97,    64,   -60,    76;
        -9,   101,   -64,     0;
        40,    58,   109,    38;
       -54,   -24,  -111,    75];

% A = gen_random_matrix(row, col);


%%% Floating point QR factorization with Given's rotation
Q 	= eye(row); % 8x8
R_Q = float_QR(row, col, Q, A);

% shift to int
Q_float	= R_Q(1 : row, col+1 : row+col);
R_float	= R_Q(1 : row, 1 : col);
A_float	= Q_float' * R_float;


%%% Fixed point QR factorization with the CORDIC 
Q = eye(row);
% A = gen_random_matrix(row, col);
K = 0.607421875;

% Quantization (hardware sim)
K_scaled = 2^(frac_bit) * K;
Q_scaled = 2^(frac_bit) * Q;
A_scaled = 2^(frac_bit) * A;

[Q_cordic, R_cordic] = Cordic_QR(K_scaled, Q_scaled, A_scaled, row, col, iter_num, frac_bit);

Q_fix = Q_cordic * 2^(-frac_bit);
R_fix = R_cordic * 2^(-frac_bit);
A_fix = (Q_fix') * R_fix;

F = fimath('RoundingMethod','Floor');

% convert to 12-bit output
Q_fix_12b = fi(Q_fix, 1, 12, 10, F);
R_fix_12b = fi(R_fix, 1, 12, 3, F);
A_fix_12b = fi(A_fix, 1, 12, 4, F);


%%% Display result matrix
% format long g;
display_result(A, Q_float, Q_fix_12b, R_float, R_fix_12b, A_float, A_fix_12b, frac_bit);


%%% Save data into .txt in binary
Save_data(Q_fix, R_fix);


%%% function
% generate a random matrix whose rank == min(row, col) and its element is INT-8
function A = gen_random_matrix(row, col)
	A = randi([-128 127],row,col);  
	while 1
		if rank(A) == min(row,col)
			break
		else
			A = randi([-128 127],row,col);
		end
	end
end

% GG : vectoring mode
function [X, Y, d] = GG(x, y, iter, k)
	% d(i)   = -sign(x(i) * y(i))
	% x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
	% y(i+1) = y(i) + d(i) * 2^(-i) * x(i)
	d = -sign(x * y);
	X = x - d * bitsra(y, iter);
	Y = y + d * bitsra(x, iter);
end

% GR : rotation mode
function [X, Y] = GR(x, y, d, iter, k, r)
	%%% x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
	%%% y(i+1) = y(i) + d(i) * 2^(-i) * x(i)
	X = x - d * bitsra(y, iter);
	Y = y + d * bitsra(x, iter);
end

% Floating point QR factorization using Q*[A|I] = [R|Q] 
function R_Q = float_QR(row, col, Q, A)
	% Q*[A|I] = [R|Q]
    R_Q = [A Q];
    % Perform Givens rotations
	for p_float = 1 : col
		for q_float = (row-1) : (-1) : p_float
			Q 	  = eye(row);
			theta = atan2(R_Q(q_float+1, p_float), R_Q(q_float, p_float));
			% Givens Q
			Q(q_float  , q_float  ) = cos(theta);
			Q(q_float  , q_float+1) = sin(theta);
			Q(q_float+1, q_float  ) = -sin(theta);
			Q(q_float+1, q_float+1) = cos(theta);
			% Q*[A|I] = [R|Q]
			R_Q = Q * R_Q;
		end
	end
end

% Fixed point QR factorization with the CORDIC 
function [Q_cordic, R_cordic] = Cordic_QR(K_cordic, Q_cordic, R_cordic, row, col, iter_num, frac_bit)
    % Eliminate A(q+1,p) by A(q,p)
	for p_fix = 1 : col
		for q_fix = (row-1) : (-1) : p_fix
			disp(['k = ', num2str(p_fix), ' row', num2str(q_fix), num2str(q_fix+1), ': '])
			for iter = 0 : iter_num-1
				% vectoring mode
				x_vect = R_cordic(q_fix  , p_fix); 
				y_vect = R_cordic(q_fix+1, p_fix); 
				
				[X_vect, Y_vect, d] = GG(x_vect, y_vect, iter, p_fix);

				if iter == iter_num-1
					R_cordic(q_fix  , p_fix) = floor(X_vect * K_cordic * 2^(-frac_bit));
					R_cordic(q_fix+1, p_fix) = floor(Y_vect * K_cordic * 2^(-frac_bit)); 
				else
					R_cordic(q_fix  , p_fix) = X_vect;
					R_cordic(q_fix+1, p_fix) = Y_vect;
				end
				% print info
				print_GG_info(p_fix, iter, X_vect, Y_vect)
				print_GG_MK_info(p_fix, iter, R_cordic(q_fix,p_fix), R_cordic(q_fix+1,p_fix))

				% rotation mode
				for rot_R = 1 : (col-p_fix)
					x_rot_R = R_cordic(q_fix  , p_fix+rot_R); 
					y_rot_R = R_cordic(q_fix+1, p_fix+rot_R); 
					
					[X_rot_R, Y_rot_R] = GR(x_rot_R, y_rot_R, d, iter, p_fix, rot_R);
					
					if iter == iter_num-1
						R_cordic(q_fix  , p_fix+rot_R) = floor(X_rot_R * K_cordic * 2^(-frac_bit)); 
						R_cordic(q_fix+1, p_fix+rot_R) = floor(Y_rot_R * K_cordic * 2^(-frac_bit)); 
					else
						R_cordic(q_fix  , p_fix+rot_R) = X_rot_R;
						R_cordic(q_fix+1, p_fix+rot_R) = Y_rot_R;
					end
					% print info
					print_GR_info(p_fix, rot_R, iter, X_rot_R, Y_rot_R);
					print_GR_MK_info(p_fix, rot_R, iter, R_cordic(p_fix,p_fix+rot_R), R_cordic(p_fix+1,p_fix+rot_R));
				end
				% compute Q (As the processing of R)
				for rot_Q = 1 : row
					x_rot_Q = Q_cordic(q_fix  , rot_Q); 
					y_rot_Q = Q_cordic(q_fix+1, rot_Q);
					
					[X_rot_Q, Y_rot_Q] = GR(x_rot_Q, y_rot_Q, d, iter, p_fix, rot_Q);
					if iter == iter_num-1 
						Q_cordic(q_fix  , rot_Q) = floor(X_rot_Q * K_cordic * 2^(-frac_bit));
						Q_cordic(q_fix+1, rot_Q) = floor(Y_rot_Q * K_cordic * 2^(-frac_bit));
					else                     
						Q_cordic(q_fix  , rot_Q) = X_rot_Q;
						Q_cordic(q_fix+1, rot_Q) = Y_rot_Q;
					end
				end
			end
		end
	end
end

function display_result(A, Q_float, Q_fix_12b, R_float, R_fix_12b, A_float, A_fix_12b, frac_bit)
	% display matrix results
    disp('Matrix A :');
    disp(A);

    disp('Matrix Q_float :');
    disp(Q_float);
    disp('Matrix Q_fix :');
    disp(Q_fix_12b);

    disp('Matrix R_float :');
    disp(R_float);
    disp('Matrix R_fix :');
    disp(R_fix_12b);

    disp('Matrix A_float :');
    disp(A_float);
    disp('Matrix A_fix :');
    disp(A_fix_12b);
	
	Q_float 	= double(Q_float);
	Q_fix_12b 	= double(Q_fix_12b);
	R_float 	= double(R_float);
	R_fix_12b 	= double(R_fix_12b);
	A_float 	= double(A_float);
	A_fix_12b 	= double(A_fix_12b);
	
    % Compute Frobenius Distance F(A,B) = sqrt(trace((A-B)(A-B)'))
    Q_float_abs = abs(Q_float);
    Q_fix_abs 	= abs(Q_fix_12b);

    R_float_abs = abs(R_float);
    R_fix_abs 	= abs(R_fix_12b);

    % Determine the final quantization error value delta
    delta_Q = sqrt(trace((Q_float_abs-Q_fix_abs)*(Q_float_abs-Q_fix_abs)'));
    disp('Q Fix Point Loss :');
    disp(delta_Q);

    delta_R = sqrt(trace((R_float_abs-R_fix_abs)*(R_float_abs-R_fix_abs)'));
    disp('R Fix Point Loss :');
    disp(delta_R);

    delta_A = sqrt(trace((A_float-A_fix_12b)*(A_float-A_fix_12b)'));
    disp('A Fix Point Loss :');
    disp(delta_A);
end

% print info for hardware debugging
function print_GG_info(k, iter, X, Y)
	if iter == 3 || iter == 7 || iter == 11
		disp(['GG', num2str(k), '  Iteration ', num2str(iter+1),' times: ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
	end
end

function print_GR_info(k, r, iter, X, Y)
    if iter == 3 || iter == 7 || iter == 11
        disp(['GR', num2str(k), num2str(r), ' Iteration ', num2str(iter+1),' times: ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
    end
end

function print_GG_MK_info(k, iter, X, Y)
	if iter == 11
		disp(['GG', num2str(k), '  Multiplied by K:   ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
    end
end

function print_GR_MK_info(k, r, iter, X, Y)
	if iter == 11  
		disp(['GR', num2str(k), num2str(r), ' Multiplied by K:   ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
	end
end


function Save_data(Q, R)
	F = fimath('RoundingMethod','Floor');
	
	Q_scaled = fi(Q, 1, 12, 10, F);
	R_scaled = fi(R, 1, 12, 3, F);
	
	A = Q_scaled' * R_scaled;
	A_scaled = fi(A, 1, 12, 4, F);
	
	% A_scaled = [  -90.75           65          112          -52
	% 	         -122.56       13.938      -63.063       23.063
	% 	          118.31      -18.875       8.3125      -75.875
	% 	             120       -59.75       116.56       34.563
	% 	         -96.938       64.625      -60.063       76.875
	% 	          -8.875       101.94      -64.063         0.25
	% 	          39.875       58.688       109.31       38.375
	% 	          -53.75      -23.813         -111       75.375];
	%      
	% Q_scaled = [  0.3544921875,    0.478515625,  -0.4619140625,       -0.46875,     0.37890625,     0.03515625,       -0.15625,   0.2099609375;
	% 	         -0.2568359375,       0.171875,  -0.1279296875,        0.15625,   -0.240234375,  -0.6962890625,           -0.5,   0.2861328125;
	% 	           0.646484375,   0.0009765625,  -0.2353515625,       0.328125,  -0.1337890625,   -0.439453125,     0.30859375,  -0.3369140625;
	% 	           0.337890625,     0.02734375,     0.41015625,  -0.4638671875,  -0.4150390625,       0.015625,   -0.455078125,   -0.361328125;
	% 	         -0.5244140625,   0.2607421875,  -0.2744140625,     -0.2890625,  -0.0576171875,  -0.1669921875,      0.2265625,   -0.646484375;
	% 	         		     0,  -0.8212890625,  -0.3701171875,  -0.3486328125,   0.1396484375,  -0.1787109375,  -0.1396484375,    -0.03515625;
	% 	         		     0,              0,  -0.5810546875,       0.234375,   -0.548828125,    0.505859375,  -0.2333984375,  -0.0224609375;
	% 	         		     0,              0,              0,  -0.4248046875,  -0.5419921875,     -0.1171875,     0.55078125,   0.4580078125];
	% 																  
	% R_scaled = [   -256,     80.25,  -114.125,     50.25;
	% 	         -0.125,  -142.375,       -50,    16.875;
	% 	         -0.125,         0,   215.875,   -28.375;
	% 		          0,    -0.125,         0,  -139.625;
	% 	         -0.125,    -0.125,    -0.125,    -0.125;
	% 		          0,    -0.125,         0,         0;
	% 		          0,         0,         0,    -0.125;
	% 	         -0.125,         0,    -0.125,    -0.125];

	[A_row, A_col] = size(A_scaled);
	[Q_row, Q_col] = size(Q_scaled);
	[R_row, R_col] = size(R_scaled);

	format short g;
	
	% Write A matrix to a .txt file
	fid_a = fopen('data/input_A_matrix.txt', 'w');
	for i = 1 : A_row
		for j = 1 : A_col
			a_data = A_scaled(i,j);
			fprintf(fid_a, '%s\n', a_data.bin);
		end
	end
	fclose(fid_a);

	% Write R matrix to a .txt file
	fid_r = fopen('data/output_R_matrix_golden.txt', 'w');
	for i = 1 : R_row
		for j = 1 : R_col
			r_data = R_scaled(i,j);
			fprintf(fid_r, '%s\n', r_data.bin);
		end
	end
	fclose(fid_r);

	% Write R matrix to a .txt file
	fid_q = fopen('data/output_Q_matrix_golden.txt', 'w');
	for i = 1 : Q_row
		for j = 1 : Q_col
			q_data = Q_scaled(i,j);
			fprintf(fid_q, '%s\n', q_data.bin);
		end
	end
	fclose(fid_q);
end

