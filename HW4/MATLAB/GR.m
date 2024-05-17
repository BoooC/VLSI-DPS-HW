function [X, Y] = GR(x, y, d, iter, k, r)
	%%% x(i+1) = x(i) - d(i) * 2^(-i) * y(i)
	%%% y(i+1) = y(i) + d(i) * 2^(-i) * x(i)

	X = x - d * bitsra(y, iter);
	Y = y + d * bitsra(x, iter);

	if iter == 3 || iter == 7 || iter == 11
		disp(['GR', num2str(k), num2str(r), ' Iteration ', num2str(iter+1),' times: ', 'X = ', num2str(X),'; Y = ', num2str(Y)])
	end
end
