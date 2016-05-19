function R = rank_rows(X)
R = zeros(size(X));
for i = 1:size(X, 1)
  R(i, :) = fracrank(X(i, :))';
end