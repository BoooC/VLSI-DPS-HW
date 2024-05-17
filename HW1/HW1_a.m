% Problem 1. Last square optimization problem
clear all 
clc

A = [ 15  -13  20   -8;
      -5  -15  -4   -4;
     -17   16  -2    9;
      10  -19 -14  -15;
      -7   8   -7   15;
      14  10   -8  -17;
      -5  -3   16   -2;
      13  -5  -10  -19];

b = [13; 10; -15; 9; 3; 18; 3; 20];

% (a) Pseudo inverse
x_pseudo  = pinv(A) * b;

% (b) QR decomposition
[Q, R] = qr(A);
R1 = R(1:4, 1:4);
y = Q' * b;
y1 = y(1:4);
x_QR = inv(R1) * y1; % R * x_b = Q' * b

