function [errors, kappas, timers] = incremental_learner(data_tr, data_te, labels_tr, labels_te, clfr, max_learners, model_type, missing)
%
if nargin == 7 
  missing = 0;
end
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
  
  if missing == 0
    tt = mod(t-1, max_learners)+1; % location of current learner
    ensemble{tt} = classifier_train(clfr, data_tr{t}, labels_tr{t});
  else
    if ~isempty(data_tr{t})
      tt = length(ensemble);
      ensemble{tt+1} = classifier_train(clfr, data_tr{t}, labels_tr{t});
    end
  end
  preds_te = predictions(ensemble, data_te{t});
  preds_te(preds_te == 2) = -1;
  
  if t > 1  
    switch model_type
      case 'sml'
        yhat = vote_sml(preds_te);
      case 'mle'
        yhat = vote_mle(preds_te);
      case 'map'
        yhat = vote_map(preds_te);
      case 'avg1'
        yhat = vote_avg1(preds_te);
      case 'avg2'
        yhat = vote_avg2(preds_te);
      otherwise
        error('Unknown model type.')
    end
    
    yhat(yhat == -1) = 2;
    errors(t) = calc_error(yhat, labels_te{t});
    kappas(t) = kappa(confusionmat(labels_te{t}, yhat));
    timers(t) = toc;
  end
end


