function [X, Y, d] = GG(x, y, iter, k)
	% d(i)   = -sign(x(i) * y(i))
	% x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
	% y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

	% decide the rotation direction: +1 means counterclockwise, -1 means clockwise
	d = -sign(x * y);

	X = x - d * bitsra(y, iter);
	Y = y + d * bitsra(x, iter);

	if iter == 3 || iter == 7 || iter == 11
		disp(['GG', num2str(k), '  Iteration ', num2str(iter+1),' times: ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
	end
end
