function [errors, kappas, timers] = cvx_learner(data_tr, data_te, labels_tr, labels_te, clfr, max_learners, alpha, beta, missing)
%
if nargin == 8 
  missing = 0;
end
p = 3;
delta = 0.0001;

if (~(iscell(data_tr) && iscell(data_te) ...
    && iscell(labels_te) && iscell(labels_tr)))
  error('data and labels must be cell arrays.')
end

if isnan(max_learners)
  max_learners = length(data_tr);
end

calc_error = @(x, y) sum(x ~= y)/numel(y);

T = length(data_te);

% initalize variables
errors = zeros(T, 1);
timers = zeros(T, 1);
kappas = zeros(T, 1);
ensemble = {}; 

% main loop 
for t = 1:T-1
  tic;     
  
  Xt = data_tr{t};
  yt = labels_tr{t};
  nv = ceil(.8*length(yt));
  i = randperm(length(yt));
  
  if missing == 0
    tt = mod(t-1, max_learners)+1; % location of current learner
    ensemble{tt} = classifier_train(clfr, data_tr{t}, labels_tr{t});
    preds_val = predictions(ensemble, Xt(i(nv+1:end), :));
    yval = yt(i(nv+1:end));
  else
    if ~isempty(data_tr{t})
      tt = length(ensemble);
      ensemble{tt+1} = classifier_train(clfr, data_tr{t}, labels_tr{t});
      preds_val = predictions(ensemble, Xt(i(nv+1:end), :));
      yval = yt(i(nv+1:end));
      tt=tt+1;
    end
  end
  
  %tt = mod(t-1, max_learners)+1; % location of current learner
  %ensemble{tt} = classifier_train(clfr, Xt(i(1:nv), :), yt(i(1:nv)));
  preds_te = predictions(ensemble, data_te{t});
  preds_te(preds_te == 2) = -1;
  
  
  
  if t == 1 
    err_ewma(1) = sum(preds_val~=yval)/numel(yval);
    yhat = preds_te;
  else
    for j = 1:tt-1
      err_ewma(j) = beta*sum(preds_val(:,j)~=yval)/numel(yval)+(1-beta)*err_ewma(j)+delta;
    end
    err_ewma(tt) = sum(preds_val(:,tt)~=yval)/numel(yval)+delta;
    err_ewma(err_ewma > 0.5) = 0.5;
    
    %[~, psi, eta] = vote_mle(preds_te);
    [~, psi, eta] = vote_sml_2(preds_te);
    V = 1 - (psi + eta)/2;
    V(V > 0.5) = 0.5;
    w_sml = log((1 - V)./V);
    w_sml = w_sml/sum(w_sml);
    w_err = log((1 - err_ewma)./err_ewma);
    w_err = w_err/sum(w_err);
    w = alpha*w_err' + (1-alpha)*w_sml;

    yhat = sign(preds_te*w);
  end

  yhat(yhat == -1) = 2;
  if ~isreal(yhat)
    dd=1;
  end
  errors(t) = calc_error(yhat, labels_te{t});
  try
  kappas(t) = kappa(confusionmat(labels_te{t}, yhat));
  catch
    dd=1;
  end
  timers(t) = toc;
end



