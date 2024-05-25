clc; 
clear;
format;

%%% QR factorization : A = Q * R, 
%	where Q is unitary matrix, R is upper triangular matrix

%%% parameters setting
iter_num = 12;

row_R 	= 8;
col_R 	= 4;

col_Q	= row_R;
row_Q	= row_R;

Input_len = 8;

%%% Generate a 8x4 matrix A of 8-bit random signed integers with full column rank 4
A = [  -123   -68   -96   -79
         85  -122   -52   105
        102   112   -95    72
         87   114    38   126
         34    68   -71   127
         75   -89    96  -115
        -94   116   122   -69
         82   122  -110    76];

A_high 	=  2^(Input_len-1) - 1;
A_low	= -2^(Input_len-1); 
A = gen_random_matrix(row_R, col_R, A_high, A_low);


%%% Floating point QR factorization with Given's rotation
Q 	= eye(row_Q);
R_Q = float_QR(row_R, col_R, row_Q, Q, A);

% shift to int
Q_float	= R_Q(1 : row_Q, col_R+1 : col_Q+col_R);
R_float	= R_Q(1 : row_R, 1 : col_R);
A_float	= Q_float' * R_float;


%%% Fixed point QR factorization with the CORDIC 
Q = eye(row_Q);
% A = gen_random_matrix(row_R, col_R);
K = 0.607421875;

% Quantization (hardware sim)
F = fimath('RoundingMethod','Floor');

K_sign	= 1;
K_int 	= 0;
K_frac	= 9;
K_len 	= K_sign + K_int + K_frac;

R_sign	= 1;
R_int 	= 9;
R_frac	= 2;
R_len 	= R_sign + R_int + R_frac;

Q_sign	= 1;
Q_int 	= 1;
Q_frac	= 10;
Q_len 	= Q_sign + Q_int + Q_frac;

A_sign	= 1;
A_int 	= 10;
A_frac	= 3;
A_len 	= A_sign + A_int + A_frac;

K_scaled = fi(K, K_sign, K_len, K_frac, F);
Q_scaled = fi(Q, Q_sign, Q_len, Q_frac, F);
R_scaled = fi(A, R_sign, R_len, R_frac, F);

[Q_cordic, R_cordic] = Cordic_QR(K_scaled, Q_scaled, R_scaled, row_R, col_R, col_Q, iter_num, R_sign, R_len, R_frac, Q_sign, Q_len, Q_frac);
A_cordic = Q_cordic' * R_cordic;
R_cordic = triu(R_cordic);

Q_fix = fi(Q_cordic * 2^(Q_frac), Q_sign, Q_len, 0, F);
R_fix = fi(R_cordic * 2^(R_frac), R_sign, R_len, 0, F);
A_fix = fi(A_cordic, A_sign, A_len, A_frac, F);


%%% Display result matrix
display_result(A, Q_float, Q_fix, R_float, R_fix, A_float, A_fix, Q_frac, R_frac);


%%% Save data into .txt in binary
A_origin = fi(A, 1, 12, 0, F);
Save_data(A_origin, Q_fix, R_fix);


%%% function
% generate a random matrix whose rank == min(row, col) and its element is INT-8
function A = gen_random_matrix(row_R, col_R, high, low)
	A = randi([low high], row_R, col_R);  
	while 1
		if rank(A) == min(row_R, col_R)
			break
		else
			A = randi([low high], row_R, col_R);
		end
	end
end

% Floating point QR factorization using Q*[A|I] = [R|Q] 
function R_Q = float_QR(row_R, col_R, row_Q, Q, A)
	% Q*[A|I] = [R|Q]
    R_Q = [A Q];
    % Perform Givens rotations
	for p_float = 1 : col_R
		for q_float = (row_R-1) : (-1) : p_float
			Q 	  = eye(row_Q);
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


% GG : vectoring mode
function [X, Y, d] = GG(x, y, len, frac, iter)
	% d(i)   = -sign(x(i) * y(i))
	% x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
	% y(i+1) = y(i) + d(i) * 2^(-i) * x(i)
	d = -sign(x * y);
	X = x - d * bitsra(y, iter);
	Y = y + d * bitsra(x, iter);
	
	F = fimath('RoundingMethod','Floor');
	X = fi(X, 1, len, frac, F);
	Y = fi(Y, 1, len, frac, F);
end

% GR : rotation mode
function [X, Y] = GR(x, y, d, len, frac, iter)
	%%% x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
	%%% y(i+1) = y(i) + d(i) * 2^(-i) * x(i)
	X = x - d * bitsra(y, iter);
	Y = y + d * bitsra(x, iter);
	
	F = fimath('RoundingMethod','Floor');
	X = fi(X, 1, len, frac, F);
	Y = fi(Y, 1, len, frac, F);
end

% Fixed point QR factorization with the CORDIC 
function [Q_cordic, R_cordic] = Cordic_QR(K_cordic, Q_scaled, R_scaled, row_R, col_R, col_Q, iter_num, R_sign, R_len, R_frac, Q_sign, Q_len, Q_frac)
	F = fimath('RoundingMethod','Floor');
	Q_cordic = Q_scaled;
	R_cordic = R_scaled;
	
    % Eliminate A(q+1,p) by A(q,p)
	for p_fix = 1 : col_R
		for q_fix = (row_R-1) : (-1) : p_fix
			% Column q and column q+1 are rotated 180 degrees
			if R_cordic(q_fix,p_fix) < 0 
				for reverse_R = p_fix : col_R
					R_cordic(q_fix  ,reverse_R) = -R_cordic(q_fix  ,reverse_R);
					R_cordic(q_fix+1,reverse_R) = -R_cordic(q_fix+1,reverse_R);
				end
				for reverse_Q = p_fix : col_Q
					Q_cordic(q_fix  ,reverse_Q) = -Q_cordic(q_fix  ,reverse_Q);
					Q_cordic(q_fix+1,reverse_Q) = -Q_cordic(q_fix+1,reverse_Q);
				end
			end
			x_pre_Q = zeros(col_Q, 1);
			y_pre_Q = zeros(col_Q, 1);
			x_pre_R = zeros(col_R, 1);
			y_pre_R = zeros(col_R, 1);
			x_pre_GG = 0;
			y_pre_GG = 0;
			disp(['k = ', num2str(p_fix), ' row', num2str(q_fix), num2str(q_fix+1), ': '])
			for iter = 0 : iter_num-1
				% vectoring mode
				x_vect = R_cordic(q_fix  , p_fix); 
				y_vect = R_cordic(q_fix+1, p_fix); 
				[X_vect, Y_vect, d] = GG(x_vect, y_vect, R_len, R_frac, iter);

				if iter == iter_num-1
					R_cordic(q_fix  , p_fix) = fi((X_vect * K_cordic), R_sign, R_len, R_frac, F);
					R_cordic(q_fix+1, p_fix) = fi((Y_vect * K_cordic), R_sign, R_len, R_frac, F);
				else
					R_cordic(q_fix  , p_fix) = X_vect;
					R_cordic(q_fix+1, p_fix) = Y_vect;
				end
				
				if iter == 0 || iter == 4 || iter == 8
					fprintf('\nd = ');
				end
				fprintf('%g ', d);
				if iter == 3 || iter == 7 || iter == 11
					fprintf('\n');
				end
				
				if iter == 0 || iter == 4 || iter == 8
					x_pre_GG = fi(x_vect, R_sign, R_len, R_frac, F);
					y_pre_GG = fi(y_vect, R_sign, R_len, R_frac, F);
				end
				% print info
				print_GG_info(p_fix, iter, x_pre_GG, y_pre_GG, X_vect, Y_vect, R_frac)
				print_GG_MK_info(p_fix, iter, R_cordic(q_fix, p_fix), R_cordic(q_fix+1, p_fix), R_frac)

				% rotation mode
				for rot_R = 1 : (col_R-p_fix)
					x_rot_R = R_cordic(q_fix  , p_fix+rot_R); 
					y_rot_R = R_cordic(q_fix+1, p_fix+rot_R); 
					[X_rot_R, Y_rot_R] = GR(x_rot_R, y_rot_R, d, R_len, R_frac, iter);
					
					if iter == iter_num-1
						R_cordic(q_fix  , p_fix+rot_R) = fi((X_rot_R * K_cordic), R_sign, R_len, R_frac, F);
						R_cordic(q_fix+1, p_fix+rot_R) = fi((Y_rot_R * K_cordic), R_sign, R_len, R_frac, F);
					else
						R_cordic(q_fix  , p_fix+rot_R) = X_rot_R;
						R_cordic(q_fix+1, p_fix+rot_R) = Y_rot_R;
					end
					
					if iter == 0 || iter == 4 || iter == 8
						x_pre_R(rot_R) = fi(x_rot_R, R_sign, R_len, R_frac, F);
						y_pre_R(rot_R) = fi(y_rot_R, R_sign, R_len, R_frac, F);
					end
					% print info
					print_GR_info(p_fix, rot_R, iter, x_pre_R(rot_R), y_pre_R(rot_R), X_rot_R, Y_rot_R, R_frac);
					print_GR_MK_info(p_fix, rot_R, iter, R_cordic(p_fix, p_fix+rot_R), R_cordic(p_fix+1, p_fix+rot_R), R_frac);
				end
				
				% compute Q (As the processing of R)
				for rot_Q = 1 : col_Q
					x_rot_Q = Q_cordic(q_fix  , rot_Q); 
					y_rot_Q = Q_cordic(q_fix+1, rot_Q);
					[X_rot_Q, Y_rot_Q] = GR(x_rot_Q, y_rot_Q, d, Q_len, Q_frac, iter);
					
					if iter == iter_num-1 
						Q_cordic(q_fix  , rot_Q) = fi((X_rot_Q * K_cordic), Q_sign, Q_len, Q_frac, F);
						Q_cordic(q_fix+1, rot_Q) = fi((Y_rot_Q * K_cordic), Q_sign, Q_len, Q_frac, F);
					else                     
						Q_cordic(q_fix  , rot_Q) = X_rot_Q;
						Q_cordic(q_fix+1, rot_Q) = Y_rot_Q;
					end
					
					if iter == 0 || iter == 4 || iter == 8
						x_pre_Q(rot_Q) = fi(x_rot_Q, Q_sign, Q_len, Q_frac, F);
						y_pre_Q(rot_Q) = fi(y_rot_Q, Q_sign, Q_len, Q_frac, F);
					end
					% print info
					print_Q_info(p_fix, rot_Q, iter, x_pre_Q(rot_Q), y_pre_Q(rot_Q), X_rot_Q, Y_rot_Q, Q_frac);
					print_Q_MK_info(p_fix, rot_Q, iter, Q_cordic(q_fix , rot_Q), Q_cordic(q_fix+1, rot_Q), Q_frac);
				end
			end
		end
	end
end

function display_result(A, Q_float, Q_fix, R_float, R_fix, A_float, A_fix, Q_frac, R_frac);
	% display matrix results
    disp('Matrix A :');
    disp(A);
	disp('----------------------------------------------------------------------');
	disp('---------------------------- Original scale --------------------------');
	disp('----------------------------------------------------------------------');
	
	disp('Matrix Q_float :');
    disp(Q_float);
    disp('Matrix Q_fix :');
    disp(Q_fix * 2^(-Q_frac));

    disp('Matrix R_float :');
    disp(R_float);
    disp('Matrix R_fix :');
    disp(R_fix * 2^(-R_frac));
	
	disp('----------------------------------------------------------------------');
	disp('------------------------------ INT scale -----------------------------');
	disp('----------------------------------------------------------------------');
    disp('Matrix Q_float :');
    disp(Q_float * 2^(Q_frac));
    disp('Matrix Q_fix :');
    disp(Q_fix);

    disp('Matrix R_float :');
    disp(R_float * 2^(R_frac));
    disp('Matrix R_fix :');
    disp(R_fix);
	
	disp('----------------------------------------------------------------------');
	disp('------------------------------- A = QR -------------------------------');
	disp('----------------------------------------------------------------------');
    disp('Matrix A_float :');
    disp(A_float);
    disp('Matrix A_fix :');
    disp(A_fix);
	
	Q_float 	= double(Q_float);
	Q_fix 		= double(Q_fix * 2^(-Q_frac));
	R_float 	= double(R_float);
	R_fix 		= double(R_fix * 2^(-R_frac));
	A_float 	= double(A_float);
	A_fix 		= double(A_fix);
	
	disp('----------------------------------------------------------------------');
	disp('-------------------- Hardware implementation loss --------------------');
	disp('----------------------------------------------------------------------');
    % Determine the final quantization error value delta
    delta_Q = sqrt(trace((Q_float-Q_fix)*(Q_float-Q_fix)'));
    disp('Q Fix Point Loss :');
    disp(delta_Q);

    delta_R = sqrt(trace((R_float-R_fix)*(R_float-R_fix)'));
    disp('R Fix Point Loss :');
    disp(delta_R);

    delta_A = sqrt(trace((A_float-A_fix)*(A_float-A_fix)'));
    disp('A Fix Point Loss :');
    disp(delta_A);
end

% print info for hardware debugging
function print_GG_info(k, iter, x, y, X, Y, R_frac)
	X = X * 2^(R_frac);
	Y = Y * 2^(R_frac);
	x = x * 2^(R_frac);
	y = y * 2^(R_frac);
	if iter == 3 || iter == 7 || iter == 11
		disp(['GG', num2str(k), '  Iteration ', num2str(iter+1),' times: ',  'input: ', 'X = ', sprintf('%5d', x), '; Y = ', sprintf('%5d', y), ' output: ', 'X = ', sprintf('%5d', X), '; Y = ', sprintf('%5d', Y)])
    end
end

function print_GR_info(k, r, iter, x, y, X, Y, R_frac)
	X = X * 2^(R_frac);
	Y = Y * 2^(R_frac);
	x = x * 2^(R_frac);
	y = y * 2^(R_frac);
    if iter == 3 || iter == 7 || iter == 11
        disp(['GR', num2str(k), num2str(r), ' Iteration ', num2str(iter+1),' times: ',  'input: ', 'X = ', sprintf('%5d', x), '; Y = ', sprintf('%5d', y), ' output: ', 'X = ', sprintf('%5d', X), '; Y = ', sprintf('%5d', Y)])
    end
end

function print_Q_info(k, r, iter, x, y, X, Y, Q_frac)
	X = X * 2^(Q_frac);
	Y = Y * 2^(Q_frac);
	x = x * 2^(Q_frac);
	y = y * 2^(Q_frac);
    if iter == 3 || iter == 7 || iter == 11
        disp(['Q', num2str(k), num2str(r), '  Iteration ', num2str(iter+1), ' times: ', 'input: ', 'X = ', sprintf('%5d', x), '; Y = ', sprintf('%5d', y), ' output: ', 'X = ', sprintf('%5d', X), '; Y = ', sprintf('%5d', Y)])
    end
end

function print_GG_MK_info(k, iter, X, Y, R_frac)
	X = X * 2^(R_frac);
	Y = Y * 2^(R_frac);
	if iter == 11
		disp(['MK:   ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
    end
end

function print_GR_MK_info(k, r, iter, X, Y, R_frac)
	X = X * 2^(R_frac);
	Y = Y * 2^(R_frac);
	if iter == 11
		disp(['MK:   ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
	end
end

function print_Q_MK_info(k, r, iter, X, Y, Q_frac)
	X = X * 2^(Q_frac);
	Y = Y * 2^(Q_frac);
	if iter == 11
		disp(['MK:   ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
	end
end



function Save_data(A_origin, Q, R)
	F = fimath('RoundingMethod','Floor');
	
	A_origin = fi(A_origin, 1, 8, 0, F);
	Q_scaled = fi(Q, 1, 12, 0, F);
	R_scaled = fi(R, 1, 12, 0, F);

	[A_row, A_col] = size(A_origin);
	[Q_row, Q_col] = size(Q_scaled);
	[R_row, R_col] = size(R_scaled);

	format short g;
	
	% Write original A matrix to a .txt file
	fid_a_ori = fopen('data/input_A_matrix.txt', 'w');
	for i = 1 : A_row
		for j = 1 : A_col
			a_o_data = A_origin(i,j);
			fprintf(fid_a_ori, '%s\n', a_o_data.bin);
		end
	end
	fclose(fid_a_ori);
	
	% Write R matrix to a .txt file
	fid_r = fopen('data/output_R_matrix_golden.txt', 'w');
	for i = 1 : R_row
		for j = 1 : R_col
			r_data = R_scaled(i,j);
			fprintf(fid_r, '%s\n', r_data.bin);
		end
	end
	fclose(fid_r);

	% Write Q matrix to a .txt file
	fid_q = fopen('data/output_Q_matrix_golden.txt', 'w');
	for i = 1 : Q_row
		for j = 1 : Q_col
			q_data = Q_scaled(i,j);
			fprintf(fid_q, '%s\n', q_data.bin);
		end
	end
	fclose(fid_q);
end

