function [V_hat, psi_hat, eta_hat] = vote_sml_2(Z)
% [V_hat,psi_hat,eta_hat] = estimate_ensemble_parameters(Z,b)
% 
% Estimate the sensitivities (psi) and specificities (eta) of the
% classifiers
%
% Input: 
% Z - Prediction matrix
% b - class imbalance
% Output: 
% V_hat - predictions w/SML
% psi_hat - estimated sensitivity of m classifiers
% eta_hat - estimated specificity of m classifiers.
%
% Written by Ariel Jaffe and Boaz Nadler, 2015

m = size(Z,2);
if size(Z,2) < 5
  psi_hat = .75*ones(size(Z,2), 1);
  eta_hat = .75*ones(size(Z,2), 1);
  %V_hat = Z;
  V_hat = mean(Z, 2);
  V_hat = sign(V_hat);
  V_hat(V_hat==0) = sign(randn(sum(V_hat==0), 1));
else
  Z = Z';
  b = estimate_class_imbalance_tensor(Z,.1);
  m = size(Z,1);

  %estimate mean
  mu = mean(Z,2);

  %estimate covariance matrix 
  R = cov(Z');

  % estimate the diagonal values of a single rank matrix
  R = estimate_rank_1_matrix(R);

  %get first eigenvector
  [V, ~] = eigs(R,1);
  V = V*sign(sum(sign(V)));

  %get constant C for first eigenvector min(C*V*V'-R)
  R_v = V*V';
  Y = R( logical(tril(ones(m))-eye(m)) );
  X = R_v( logical(tril(ones(m))-eye(m)) );
  [~, C] = evalc('lsqr(X,Y)');
 if C < 0
   C = -C;
 end
  V_hat = V*sqrt(C);
  V_hat(sign(V_hat)==-1) = .05; %-V_hat(sign(V_hat)==-1);

  %estimate psi and eta
  psi_hat = 0.5*(1+mu+V_hat*sqrt( (1-b)/(1+b)));
  eta_hat = 0.5*(1-mu+V_hat*sqrt( (1+b)/(1-b)));
  psi_hat(psi_hat > .999) = .999;
  eta_hat(eta_hat > .999) = .999;
  Z = Z';
  V_hat = sign(Z*V);
end

function R = estimate_rank_1_matrix(Q)
% function [R] = estimate_rank_1_matrix(R)
%
% Estimate the diagonal entries of matrix Q by assuming a rank-1 structure
%
% Input: 
% Q - matrix of m x m with off-diagonal rank one entries
%
% Ooutput:
% R - same matrix with estimated diagonal entries
%
% Written by Ariel Jaffe and Boaz Nadler, 2015

m = size(Q,1);

%number of equations
N = 3*nchoosek(m,3);

A = zeros(N,m);
B = zeros(N,1);
ctr = 0;
for i = 1:m
  for j = i+1:m
    for k = j+1:m
      ctr = ctr+1;
      A(ctr,k)=Q(i,j);
      B(ctr) = Q(j,k)*Q(i,k);
      ctr = ctr+1;
      A(ctr,i)=Q(j,k);
      B(ctr) = Q(i,j)*Q(i,k);
      ctr = ctr+1;
      A(ctr,j)=Q(i,k);
      B(ctr) = Q(i,j)*Q(j,k);
    end
  end
end

[~,X] = evalc('lsqr(A,B)');

R = Q;
R(logical(eye(size(R)))) = X;

function b_hat = estimate_class_imbalance_tensor(Z,delta)   
% b_hat = estimate_class_imbalance_tensor(Z,delta)
%
% Estimate the class imbalance using the tensor method
%  
% Input: 
% Z - m x n matrix of binary data
% delta - bounds away the class imbalance, psi and eta estimations
%        b_hat in [-1+delta,1-delta], psi,eta in [delta,1-delta]
%
% Output: 
% b_hat - estimation of the class Y imbalance Pr(Y=1)-Pr(Y=-1)
%
% Written by Ariel Jaffe and Boaz Nadler, 2015

%get number of classifiers
m = size(Z,1);

%estimate second moment
R = cov(Z');

% estimate the diagonal values of a single rank matrix
R = estimate_rank_1_matrix(R);

%get first eigenvector
[V, ~] = eigs(R,1);
V = V*sign(sum(sign(V)));

%get constant C for first eigenvector min(C*V*V'-R)
R_v = V*V';
Y = R( logical(tril(ones(m))-eye(m)) );
X = R_v( logical(tril(ones(m))-eye(m)) );
[~,C] = evalc('lsqr(X,Y)');
V = V*sqrt(C);

%Estimate m x m x m tensor
T = compute_classifier_3D_tensor(Z);

%Estimate alpha
alpha = estimate_alpha(V,T);

%get b from alpha
b_hat = -alpha / sqrt(4+alpha^2);

%bound b_hat in [-1+delta,1-delta]
b_hat = min(b_hat,1-delta);
b_hat = max(b_hat,-1+delta);

function T = compute_classifier_3D_tensor(Z)
%function T = Compute_Classifier_3D_Tensor(Z)
%
% Computes tensor of joint covariance, from the prediction matrix Z
% Input: 
% Z - m x n matrix of binary classifier outputs
%
% Output: 
% T - 3D Tensor of joint covariance E[(f_i-mu_i)(f_j-mu_j)(f_k-mu_k)]
%
% Written by Ariel Jaffe and Boaz Nadler, 2015

[m n] = size(Z); 

% estimate third moment tenzor
T = zeros(m,m,m);

mu = mean(Z,2); 

for k_a = 1:m-2
  for k_b = k_a+1:m-1
    for k_c = k_b+1:m
      T(k_a,k_b,k_c) = n/(n-1)/(n-2) * sum( (Z(k_a,:)-mu(k_a) ).*(Z(k_b,:) - mu(k_b)).*(Z(k_c,:) - mu(k_c)) );
      T(k_a,k_c,k_b) = T(k_a,k_b,k_c);
      T(k_b,k_a,k_c) = T(k_a,k_b,k_c);
      T(k_b,k_c,k_a) = T(k_a,k_b,k_c);
      T(k_c,k_a,k_b) = T(k_a,k_b,k_c);
      T(k_c,k_b,k_a) = T(k_a,k_b,k_c);            
    end
  end
end

function alpha = estimate_alpha(V,T)
%function alpha3 = Estimate_alpha(V,T)
% Estimate scalar parameter alpha
%
% Input: 
% V - First eigenvector of covariance matrix V
% T - Tensor of joint covariance
%
% Output:
% alpha - 
% min sum_{ijk} (Tijk - alpha3 * v_ijk)^2
% d/d alpha gives sum (vijk Tijk) / sum(vijk^2)
%
% Written by Ariel Jaffe and Boaz Nadler, 2015
m = length(V); 
s1 = 0; s2 = 0; 
for i=1:(m-2)
  for j=(i+1):(m-1)
    for k=(j+1):m
      s1 = s1 + T(i,j,k)*V(i)*V(j)*V(k);
      s2 = s2 + (V(i)*V(j)*V(k))^2; 
    end
  end
end

alpha = s1 / s2; 
