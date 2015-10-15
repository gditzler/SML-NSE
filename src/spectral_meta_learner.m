function [HL, V1, MLE, MAP, VO] = spectral_meta_learner(X)
  %
  % Spectral Meta-Learner
  %
  % Input:
  %   X: a S x N data matrix of S instances by N predictors
  %      entries in X are assumed to be +1 or -1
  %      (will be converted if real). 
  %      No missing values are allowed. Zeros will be converted to
  %      +1 and -1 randomly
  %
  % Output:
  %   HL: SML estimate
  %   V1: leading eigenvector, its entries are proportional to the balanced accuracy
  %   MLE: iterative maximum likelihood estimate (starting from HL)
  %   MAP: iterative maximum a posteriori estimate (starting from HL)
  %   VO: majority voting
  %
  % The algorithm assumes that the majority of non-random 
  % predictors is better than random.
  % 
  % (c) 2013 Kluger Lab 

  X = sign(X);
  p0 = sum(X(:) == 1)./sum(X(:) ~= 0);
  X(X == 0) = 2.*(rand(sum(X(:) == 0),1) > (1 - p0)) - 1;

  [S, N] = size(X); 

  CMAT = cov(X);         % computes the covariance
  VMAT = varcov(CMAT,S); % variance of covariance

  %voting
  VO = VOTING(X);

  %log weighted
  [R_wgs, D] = covadj_weighted(CMAT, VMAT);
  rho_wgs = nanmean(R_wgs);
  if rho_wgs<0, 
    R_wgs = -R_wgs; 
  end

  %spectral-metalearner
  HL = sign(X * R_wgs);

  %iterative MLE
  MLE = iMLE(X, HL);
  MAP = iMAP(X, HL);

  V1 = R_wgs;
end

function [VMAT] = varcov(CMAT, S)
  % for each element in the covariance matrix
  %  returns the variance of the mean estimator
  % S: datapoints

  M = size(CMAT, 1);  % algorithms
  VMAT = zeros(M);
  for i = 1:(M - 1)
    VMAT(i, i) = 2.*(CMAT(i, i).^2);
    for j = (i + 1):M
      VMAT(i, j) = (CMAT(i, i).*CMAT(j, j) + CMAT(i, j).^2)./S;
      VMAT(j, i) = VMAT(i, j);
    end
  end
end


function [R, D, CMAT2] = covadj_weighted(CMAT, VMAT)
  % thresholded covariance adjustment 
  % returns eigenvectors V, eigenvalues D and the adjusted matrix CMAT2
  % weights at VMAT

  M = size(CMAT,1);
  M2 = M.*M; 

  CVEC = log(abs(CMAT(:)));

  isel = abs(CMAT(:)) > 0;  %indices of the elements to be used

  y = zeros(M2, 1);
  x = zeros(M2, M);
  f = zeros(M2, 1);
  for i = 1:(M - 1)
    for j = (i + 1):M
      k = i + (j-1).*M;
      if isel(k) == 1
        y(k) = CVEC(k);
        x(k, i) = 1;
        x(k, j) = 1;
        f(k) = (CMAT(i, j).^2)./VMAT(i, j);
      end
    end
  end

  y = y(f > 0);
  x = x(f > 0,:);
  f = f(f > 0);

  %plot(y)
  b = ones(M, 1) * (-Inf);
  i = sum(x) > 0;
  b(i) = lscov(x(:,i), y, f);

  CMAT2 = CMAT;

  for i = 1:M
    CMAT2(i, i) = exp(2 * b(i));
  end

  [R, D] = eigs(CMAT2, 1);

end


function VO = VOTING(Y)
  S = size(Y, 1);
  VO = sign(mean(Y, 2) + median(Y(:))./(S.^2));
end



function [YMLE, Nsteps] = iMLE(Y, Y0)
  YBCK = 0.*Y0;
  YMLE = Y0;
  Nsteps = 0;

  [S, M] = size(Y);
  tol = 1 - 1./(S.^2);

  psi = zeros(M, 1);
  eta = zeros(M, 1);


  while sum(YBCK ~= YMLE) > 0 
    Nsteps = Nsteps+1;
    YBCK = YMLE;
    for i = 1:M
      psi(i) = sum(YMLE > 0 & Y(:,i) > 0)./sum(YMLE > 0);
      eta(i) = sum(YMLE < 0 & Y(:,i) < 0)./sum(YMLE < 0);
    end

    psi = ((tol.* (2 * psi - 1)) + 1)./2;
    eta = ((tol.* (2 * eta - 1)) + 1)./2;  

    psi(isnan(psi)) = 0.5;
    eta(isnan(eta)) = 0.5; 

    b = mean(YMLE).*tol;
    YMLE = 0;
    for i = 1:M
      YMLE = YMLE + ( log((1 - Y(:,i))./2 + Y(:,i).*psi(i)) ...
        - log((1 + Y(:,i))./2 - Y(:,i).*eta(i)));                   
    end
    YMLE = sign(YMLE);
  end
end




function [YMLE, Nsteps] = iMAP(Y, Y0)
  YBCK = 0.*Y0;
  YMLE = Y0;
  Nsteps = 0;

  [S, M] = size(Y);
  tol = 1 - 1./(S.^2);

  psi = zeros(M, 1);
  eta = zeros(M, 1);


  while sum(YBCK~=YMLE)>0 
    Nsteps = Nsteps+1;
    YBCK = YMLE;
    for i=1:M
      psi(i) = sum(YMLE>0 & Y(:,i)>0)./sum(YMLE>0);
      eta(i) = sum(YMLE<0 & Y(:,i)<0)./sum(YMLE<0);
    end

    psi = ((tol.* (2 * psi - 1)) + 1)./2;
    eta = ((tol.* (2 * eta - 1)) + 1)./2;  

    psi(isnan(psi)) = 0.5;
    eta(isnan(eta)) = 0.5; 

    b = mean(YMLE).*tol;
    YMLE = ones(size(YMLE)).*log((1+b)./(1-b));
    for i=1:M
      YMLE = YMLE + ( log( (1-Y(:,i))./2 + Y(:,i).*psi(i) ) - ...
        log( (1+Y(:,i))./2 - Y(:,i).*eta(i) ) );                   
    end
    YMLE = sign(YMLE);
  end
end



