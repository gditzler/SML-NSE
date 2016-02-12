function [errors, kappas, timers] = cvx_learner(data_tr, data_te, labels_tr, labels_te, clfr, max_learners, alpha, beta)
%
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
  
  
  
  tt = mod(t-1, max_learners)+1; % location of current learner
  ensemble{tt} = classifier_train(clfr, Xt(i(1:nv), :), yt(i(1:nv)));
  preds_te = predictions(ensemble, data_te{t});
  preds_te(preds_te == 2) = -1;
  
  preds_val = predictions(ensemble, Xt(i(nv+1:end), :));
  yval = yt(i(nv+1:end));
  
  if t == 1 
    err_ewma(1) = sum(preds_val~=yval)/numel(yval);
    yhat = preds_te;
  else
    for j = 1:tt-1
      err_ewma(j) = beta*sum(preds_val(:,j)~=yval)/numel(yval)+(1-beta)*err_ewma(j)+delta;
    end
    err_ewma(tt) = sum(preds_val(:,tt)~=yval)/numel(yval)+delta;
    
    V = get_eig(preds_te);
    V = V.^p+delta;
    w_sml = log((1 - V)./V);
    w_sml = w_sml/sum(w_sml);
    w_err = log((1 - err_ewma)./err_ewma);
    w_err = w_err/sum(w_err);
    w = alpha*w_err' + (1-alpha)*w_sml;

    yhat = sign(preds_te*w);
  end

  yhat(yhat == -1) = 2;
  errors(t) = calc_error(yhat, labels_te{t});
  kappas(t) = kappa(confusionmat(labels_te{t}, yhat));
  timers(t) = toc;
end


