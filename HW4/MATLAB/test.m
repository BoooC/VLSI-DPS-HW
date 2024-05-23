

x0=815;
y0=0;

iter1=0;
iter2=1;
iter3=2;
iter4=3;

d1=1;
d2=1;
d3=1;
d4=-1;

[X0, Y0] = GR(x0, y0, d1, iter1);
[X1, Y1] = GR(X0, Y0, d2, iter2);
[X2, Y2] = GR(X1, Y1, d3, iter3);
[X3, Y3] = GR(X2, Y2, d4, iter4);

function [X, Y] = GR(x, y, d, iter)
	X = x - d * bitsra(y, iter);
	Y = y + d * bitsra(x, iter);
end
