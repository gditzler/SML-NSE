function R = rank_rows(X)
R = zeros(size(X));
for i = 1:size(X, 1)
  [~, idx] = sort(X(i, :));
  for j = 1:length(idx)
    R(i, idx(j)) = j;
  end
end