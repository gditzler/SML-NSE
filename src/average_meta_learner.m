function [Y1, Y2] = average_meta_learner(X)

X = sign(X);
p0 = sum(X(:) == 1)./sum(X(:) ~= 0);
X(X == 0) = 2.*(rand(sum(X(:) == 0),1) > (1 - p0)) - 1;
Y1 = sign(mean(X, 2));

S = size(X, 1);
Y2 = sign(mean(X, 2) + median(X(:))./(S.^2));