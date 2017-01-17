function [err, kap, timers] = follow_the_leader(net, data_train, labels_train, data_test, labels_test, missing)
%    [net,f_measure,g_mean,precision,recall,err] = follow_the_leader(net, ...
%        data_train, labels_train, ...
%        data_test, labels_test, ...
%        smote_params)
% 
%     @net - initialized structure. you must initialize
%       net.mclass - number of classes
%       net.base_classifier - you should set this to be model.type 
%         which is submitted to CLASSIFIER_TRAIN.m
%       net.n_classifiers - number of classifiers to keep in the pool
%     @data_train - cell array of training data. each entry should 
%       have a n_oberservation by n_feature matrix
%     @labels_train - cell array of class labels
%     @data_test - cell array of training data. each entry should 
%       have a n_oberservation by n_feature matrix
%     @labels_test - cell array of class labels
%   
%   Implementation of model selection scheme that uses only the 
%   best perfoming classifier. 
% 
%   @Author: Gregory Ditzler (gregory.ditzler@gmail.com) 
%      
%   See also
%   CLASSIFIER_TRAIN.m CLASSIFIER_TEST.m

%     follow_the_leader.m
%     Copyright (C) 2013 Gregory Ditzler
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

if nargin == 5
  missing = 0;
end

calc_error = @(x, y) sum(x ~= y)/numel(y);

n_timestamps = length(data_train);  % total number of time stamps
net.classifiers = cell(net.n_classifiers,1);   % classifiers
net.type = 'follow-the-leader';

f_measure = zeros(n_timestamps, net.mclass);
g_mean = zeros(n_timestamps, 1);
recall = zeros(n_timestamps, net.mclass);
precision = zeros(n_timestamps, net.mclass);
err = zeros(n_timestamps, 1);
timers = zeros(n_timestamps, 1);

if net.n_classifiers == -1 
  net.n_classifiers = n_timestamps;
end

for ell = 1:n_timestamps
  tic;
  
  % get the training data for the 't'th round 
  data_train_t = data_train{ell};
  labels_train_t = labels_train{ell};
  data_test_t = data_test{ell};
  labels_test_t = labels_test{ell};
  index = mod(ell-1, net.n_classifiers) + 1;
  
  
  if missing == 0
    net.classifiers{index} = classifier_train(net.base_classifier, ...
      data_train_t, labels_train_t);
  else
    if ~isempty(data_train_t)
      tt = 0;
      for q = 1:length(net.classifiers);
        if ~isempty(net.classifiers{q})
          tt = tt+1;
        end
      end
      net.classifiers{tt+1} = classifier_train(net.base_classifier, ...
        data_train_t, labels_train_t);

     % if ell < net.n_classifiers
     %   T = ell;
     % else
     %   T =  net.n_classifiers;
     %end
      T = tt+1;
      y = decision_ensemble(net, data_train_t, labels_train_t, T);
      e = zeros(T,1);
      for t = 1:T
        [~,~,~,~, e(t)] = stats(labels_train_t, y(:,t), net.mclass);
      end
      [~, i] = min(e);
        end
  end
  
  %net.classifiers{index} = classifier_train(...
  %  net.base_classifier, ...
  %  data_train_t, ...
  %  labels_train_t);
%   if ell < net.n_classifiers
%     T = ell;
%   else
%     T =  net.n_classifiers;
%   end
%   y = decision_ensemble(net, data_train_t, labels_train_t, T);
%   e = zeros(T,1);
%   for t = 1:T
%     [~,~,~,~, e(t)] = stats(labels_train_t, y(:,t), net.mclass);
%   end
%   [~, i] = min(e);
  h = classifier_test(net.classifiers{i}, data_test_t);
  %[f_measure(ell,:),g_mean(ell),recall(ell,:),precision(ell,:),...
  %  err(ell)] = stats(labels_test_t, h, net.mclass);
  
  err(ell) = calc_error(h, labels_test_t);
  kap(ell) = kappa(confusionmat(labels_test_t, h));
  timers(ell) = toc;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% AUXILARY FUNCTIONS
function y = decision_ensemble(net, data, labels, n_experts)
y = zeros(numel(labels), n_experts);
for k = 1:n_experts
  y(:, k) = classifier_test(net.classifiers{k}, data);
end
