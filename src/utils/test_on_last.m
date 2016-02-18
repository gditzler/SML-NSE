function [data_train, data_test, labels_train, labels_test] = test_on_last(data, labels, win_size, sample)
%   [data_train,data_test,labels_train,labels_test] = ...
%       test_on_last(data, labels, win_size);
%    
%     @data - data in n_observations by n_features matrix
%     @labels - labels in n_observations by 1 vector
%     @win_size - batch size
%     @sample - randomly sample
%     @data_train - cell array of training data
%     @data_test - cell array of test data
%     @labels_train - cell array of training labels
%     @labels_test - cell array of test labels
%     
%     
%   Partition a data set in fixed length windows for training and 
%   testing. 
%  
%   @Author: Gregory Ditzler (gregory.ditzler@gmail.com) 
%      

%     test_then_train.m
%     Copyright (C) 2016 Gregory Ditzler
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

[data_train, data_test, labels_train, labels_test] = test_then_train(data, labels, win_size, sample);

for q = 1:length(data_test)-1
  data_test{q} = data_test{end};
  labels_test{q} = labels_test{end};
end

