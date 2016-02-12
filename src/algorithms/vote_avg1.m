function Y = vote_avg1(X)

X = sign(X);
p0 = sum(X(:) == 1)./sum(X(:) ~= 0);
X(X == 0) = 2.*(rand(sum(X(:) == 0),1) > (1 - p0)) - 1;

Y = sign(mean(X, 2));
