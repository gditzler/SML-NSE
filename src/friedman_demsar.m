function [hZtest, pZtest, pFtest] = friedman_demsar(X, tail, alpha)
[N,k] = size(X);
R = mean(rank_rows(X));

chi2 = (12*N)/(k*(k+1))*(sum(R.^2)-k*(k+1)^2/4);
Ff = (N-1)*chi2/(N*(k-1)-chi2);
pFtest = 1 - fcdf(Ff,k-1,(k-1)*(N-1)); % pvalue for the f-test

%%%% perform correction to address the issue
%%%% of multiple comparisions
% q=2.45;
z = zeros(k,k);
for j = 1:k
  for i = 1:k
    z(j,i) = (R(j)-R(i))/(sqrt(k*(k+1)/(6*N)));
  end
end

if pFtest < alpha
  disp('Reject the Null Hypothesis (based on Friedman)')
else
  disp('Accept the Null Hypothesis (based on Friedman)')
end

switch tail%%%% this only applies to the z-test
  case 'right'     % right one-tailed test
    % "mean is greater than M" (right-tailed test)
    p = normcdf(-z);
  case 'left'      % left one-tailed test
    % "mean is less than M" (left-tailed test)
    p = normcdf(z);
  case 'two'  % two-tailed test
    % "mean is not M" (two-tailed test)
    p = 2*normcdf(-abs(z));
end


alpha  = alpha/(k-1);   % Bonferroni-Dunn procedure
hZtest = (p <= alpha);  % accept or reject null hypothesis
pZtest = p;             % pvalue for z-test