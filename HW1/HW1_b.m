% Problem 2. Eigen decomposition
clear all
clc

M = [ -2   16   -6  -16    3   15   -6  -19;
	  16  -17   10   -2    7    8    3    5;
	  -6   10   15   -1  -15  -18    9   -8;
	 -16   -2   -1    9    0    0    0   18;
	   3    7  -15    0   14   19  -12   11;
	  15    8  -18    0   19   10   -8  -17;
      -6    3    9    0  -12   -8   15   20;
	 -19    5   -8   18   11  -17   20   20];

% Use iterative
convergence_threshold = 1e-4;
[D_iter, V_iter, sweeps] = eig_iterative(M, convergence_threshold);

% Use eig()
[V, D] = eig(M);    

disp('Eigenvalue matrix D Using Iterative:');
disp(D_iter);
disp('Eigenvalue matrix V Using Iterative:');
disp(V_iter);

disp('The numbers of sweeps:');
disp(sweeps);

disp('Eigenvalue matrix D Using eig():');
disp(D);
disp('Eigenvalue matrix V Using eig():');
disp(V);

function [D_iter, V_iter, sweeps] = eig_iterative(M, Convergence_Threshold)
    M_tiled = M;
    convergence = false;
    sweeps = 0;
    
    % Find D
    while ~convergence
        [Q, R] = Given_QR(M_tiled);
        M_new = R * Q;
        convergence = (det(Q*M_new*Q') - (det(diag(diag(Q*M_new*Q'))))) / (det(M_tiled)) < Convergence_Threshold;
        %convergence = (det((Q*M_new*Q') - diag(diag(Q*M_new*Q')))) / (det(M_tiled)) < Convergence_Threshold;
        M_tiled = M_new;
        sweeps = sweeps + 1;
    end
    
    % Find V
    D_iter = M_tiled;
    n = size(D_iter, 1);
    V_iter = zeros(n); 
    % Compute eigenvectors for each approximate eigenvalue from D_iter
    for i = 1:n
        lambda = D_iter(i, i); 
        v = rand(n, 1); 
        for k = 1:10 % 10 iterations for refinement
            v = (M - lambda * eye(n)) \ v; % inverse iteration
            v = v / norm(v); % Normalize
        end
        V_iter(:, i) = v;
    end
end

function [Q, R] = Given_QR(M)
    [n, m] = size(M);
    Q = eye(m);
    R = M;
    for i = 1 : n-1
        for j = i+1 : m
            x = R(:, i);
            q_t = Givens(x, i, j);
            Q = Q * q_t';
            R = q_t * R;
        end
    end
end

function R = Givens(x, i, j)
    r = sqrt(x(i)^2 + x(j)^2);
    cost = x(i) / r;
    sint = x(j) / r;
    
    R = eye(length(x));
    R(i, i) = cost;
    R(i, j) = sint;
    R(j, i) = -sint;
    R(j, j) = cost;
end

