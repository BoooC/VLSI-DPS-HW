clear all
close all
clc

%% Define filter
h_coe = [   0.852698679009;     0.377402855613;     -0.110624404418;    -0.023849465020;    0.037828455507];
g_coe = [   -0.788485616406;    0.418092273222;     0.040689417609;     -0.064538882629];
q_coe = [   0.788485616406;     0.418092273222;     -0.040689417609;    -0.064538882629];
p_coe = [   -0.852698679009;    0.377402855613;     0.110624404418;     -0.023849465020;    -0.037828455507];

% Symmetric Extension
h = Symmetric_Extension(h_coe);
g = Symmetric_Extension(g_coe);
q = Symmetric_Extension(q_coe);
p = Symmetric_Extension(p_coe);

% Read img
ori_img = double(imread('HW2 test image.bmp'));

%% DWT Level 1
[L_1, H_1]   = DWT_ROW(ori_img, h, g);
[LL_1, LH_1] = DWT_COL(L_1, h, g);
[HL_1, HH_1] = DWT_COL(H_1, h, g);
% DWT Level 2
[L_2, H_2]   = DWT_ROW(LL_1, h, g);
[LL_2, LH_2] = DWT_COL(L_2, h, g);
[HL_2, HH_2] = DWT_COL(H_2, h, g);
% DWT Level 3
[L_3, H_3]   = DWT_ROW(LL_2, h, g);
[LL_3, LH_3] = DWT_COL(L_3, h, g);
[HL_3, HH_3] = DWT_COL(H_3, h, g);

% Combine
DWT_result = [[[LL_3 HL_3; LH_3 HH_3] HL_2;
                LH_2 HH_2] HL_1; 
                LH_1 HH_1];

%% Reconstruction
% IDWT Level-3
Rec_L_3     = IDWT_COL(LL_3, LH_3, q, p);
Rec_H_3     = IDWT_COL(HL_3, HH_3, q, p);
Rec_LL_2    = IDWT_ROW(Rec_L_3, Rec_H_3, q, p);
% IDWT Level-2
Rec_L_2     = IDWT_COL(Rec_LL_2, LH_2, q, p);
Rec_H_2     = IDWT_COL(HL_2, HH_2, q, p);
Rec_LL_1    = IDWT_ROW(Rec_L_2, Rec_H_2, q, p);
% IDWT Level-1
Rec_L_1     = IDWT_COL(Rec_LL_1, LH_1, q, p);
Rec_H_1     = IDWT_COL(HL_1, HH_1, q, p);
Rec_img_a   = IDWT_ROW(Rec_L_1, Rec_H_1, q, p);

% IDWT Level-1 (setting HL1 LH1 HH1 to zero)
Rec_L_1_    = IDWT_COL(Rec_LL_1, zeros(size(LH_1)), q, p);
Rec_H_1_    = IDWT_COL(zeros(size(HL_1)), zeros(size(HH_1)), q, p);
Rec_img_b   = IDWT_ROW(Rec_L_1_, Rec_H_1_, q, p);

% Calaulate PSNR
PSNR_a = PSNR(ori_img, Rec_img_a, 8);
PSNR_b = PSNR(ori_img, Rec_img_b, 8);

disp(['PSNR a: ',num2str(PSNR_a) ,' dB']);
disp(['PSNR b: ',num2str(PSNR_b) ,' dB']);

%% Plot
% Original image
figure('Name','Original Image');
imshow(mat2gray(ori_img));
title('Original Image');

% 3-level DWT
figure('Name','3-Level DWT');
Plot_DWT = mat2gray(DWT_result);
% add lines
num_levels = 3;
for level = 1:num_levels
    region_size = 512 / (2^(level-1));
    Plot_DWT(1:region_size, round(region_size/2)) = 1; % Vertical line
    Plot_DWT(round(region_size/2), 1:region_size) = 1; % Horizontal line
end
imshow(Plot_DWT);
title('3-Level DWT');

% Synthesis A image
figure('Name','Synthesis Image A');
imshow(mat2gray(Rec_img_a));
title('Synthesis Image A');

% Synthesis B image(se HL1 LH1 HH1 to zero)
figure('Name','Synthesis Image B');
imshow(mat2gray(Rec_img_b));
title('Synthesis Image B');

%% Function
% Symmetric Extension
function extended_data = Symmetric_Extension(data)
    Recersed_data = flipud(data);
    trimmed_data = data(2:end);
    extended_data = [Recersed_data; trimmed_data];
end

% Filter
function y = Filter(x, w)
	if iscolumn(x), x = x'; end
	if iscolumn(w), w = w'; end
	N = size(x, 2);
	M = size(w, 2); 
	L = fix( M/ 2); 
	temp = conv(w, [x(L+1:-1:2), x, x(N-1:-1:N-L)]); 
	y = temp(M : M+N-1); 
end

% ROW-wise DWT
function [L, H] = DWT_ROW(img, L_Filter, H_Filter)
	[row, col] = size(img);
	L = zeros(row, col);
	H = zeros(row, col);
	for i = 1: row
		L(i,:) = Filter(img(i,:), L_Filter);
		H(i,:) = Filter(img(i,:), H_Filter);
	end
	% Down Sample
	L = L(:, 1:2:end); % Keep Odd
	H = H(:, 2:2:end); % Keep Even
end

% COL-wise DWT
function [L, H] = DWT_COL(img, L_Filter, H_Filter)
	[row, col] = size(img);
	L = zeros(row, col);
	H = zeros(row, col);
	for i = 1: col
		L(:,i) = Filter(img(:,i), L_Filter)';
		H(:,i) = Filter(img(:,i), H_Filter)';
	end
	% Down Sample
	L = L(1:2:end, :); % Keep Odd
	H = H(2:2:end, :); % Keep Even
end

% ROW-wise IDWT
function img = IDWT_ROW(L, H, L_Filter, H_Filter)
	[row, col] = size([L H]);
	% up sample
	Ext_L = zeros(row, col);
	Ext_H = zeros(row, col);
	Ext_L(:, 1:2:end) = L; % keep odd
	Ext_H(:, 2:2:end) = H; % keep even
	for i = 1: row
		Ext_L(i,:) = Filter(Ext_L(i,:), L_Filter);
		Ext_H(i,:) = Filter(Ext_H(i,:), H_Filter);
	end
	img = Ext_L + Ext_H;
end

% COL-wise IDWT
function img = IDWT_COL(L, H, L_Filter, H_Filter)
	[row, col] = size([L; H]);
	% Up Sample
	Ext_L = zeros(row, col);
	Ext_H = zeros(row, col);
	Ext_L(1:2:end, :) = L; % Keep Odd
	Ext_H(2:2:end, :) = H; % Keep Even
	for i = 1: col
		Ext_L(:,i) = Filter(Ext_L(:,i), L_Filter)';
		Ext_H(:,i) = Filter(Ext_H(:,i), H_Filter)';
	end
	img = Ext_L + Ext_H;
end

% PSNR
function DWT_result = PSNR(ori_img, Rec_img, nbit)
	MSE = mean((Rec_img(:) - ori_img(:)).^2);   
	MAXI = 2^nbit - 1;                     
	DWT_result = 10 * log10((MAXI^2) / MSE);     
end
