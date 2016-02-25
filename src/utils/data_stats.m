%% nse
clc
clear
close all


dats = {'poker', 'noaa', 'elec2', 'spam', 'sea', 'air'};

disp(' & Samples & Features & $\omega_1$\% & $\omega_2$\% \\')
for dd = 1:length(dats)
  dat = dats{dd};
  
  %disp(['Running ', dat])
  
  if strcmp(dat,'noaa')
    load neweather_rain;
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^
    win_size = 120;    % size of train / test batch (3 months - 1 season)
    mclass = 2;
    
  elseif strcmp(dat,'air')
    alldata = load('data/air2.arff');
    mclass = 2;
    allclass = alldata(:, 8);
    allclass = allclass + 1;
    alldata(:, 8) = [];
    win_size = 1200;   
  
  elseif strcmp(dat,'poker')
    alldata = load('data/poker.arff');
    alldata(alldata(:, end) == 9, :) = [];
    alldata(alldata(:, end) == 8, :) = [];
    alldata(alldata(:, end) == 7, :) = [];
    alldata(alldata(:, end) == 6, :) = [];
    alldata(alldata(:, end) == 5, :) = [];
    alldata(alldata(:, end) == 4, :) = [];
    alldata(alldata(:, end) == 3, :) = [];
    allclass = alldata(:, end);
    allclass = allclass + 1;
    allclass(allclass == 3) = 2;
    alldata(:, end) = [];
    win_size = 2000; 
    mclass = 2;
    % figure; hold on
    % plot(find(allclass==1), cumsum(allclass(allclass==1)))
    % plot(find(allclass==2), cumsum(allclass(allclass==2)==2))

    
  elseif strcmp(dat,'rbf')
    alldata = load('data/rbf150k.arff');
    mclass = 2;
    allclass = alldata(:, end);
    allclass = allclass + 1;
    alldata(:, end) = [];
    win_size = 1200; 
    
  elseif strcmp(dat,'elec2')
    load elec2;
    alldata(3,:) = []; % remove the "cheating" features
    alldata(4,:) = []; 
    win_size = 125;    % size of train / test batch
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^
    mclass = 2;
    
  elseif strcmp(dat,'dataLU')
    load dataLU
    alldata = dataLU.X';
    allclass = dataLU.y' + 1;
    win_size = 100;
    mclass = max(allclass);
    
  elseif strcmp(dat,'chess')
    load chessIZ
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^

    alldata(allclass==3, :) = [];
    allclass(allclass==3) = [];

    mclass = max(allclass);
    win_size = 35;
    
  elseif strcmp(dat,'spam')
    load spam2
    alldata = alldata';   % old format of data needs transpose
    allclass = allclass'; % ^^^^^
    mclass = max(allclass);
    win_size = 100;
    
  elseif strcmp(dat, 'sea')
    win_size = 250;
    len = 200;
    noise = .1;
    alldata = 10 * rand(win_size * len,3);
    s1 = sum(alldata(1:floor(win_size * len / 4),1:2),2);
    s1(s1 > 8) = 1;
    s1(s1 ~= 1) = 2;
    s2 = sum(alldata(1+floor(win_size * len / 4):2*floor(win_size * len / 4),1:2),2);
    s2(s2 > 9) = 1;
    s2(s2 ~= 1) = 2;
    s3 = sum(alldata(1+2*floor(win_size * len / 4):3*floor(win_size * len / 4),1:2),2);
    s3(s3 > 7.5) = 1;
    s3(s3 ~= 1) = 2;
    s4 = sum(alldata(1+3*floor(win_size * len / 4):end,1:2),2);
    s4(s4 > 9.5) = 1;
    s4(s4 ~= 1) = 2;
    allclass = [s1;s2;s3;s4];
    mclass = 2;
    win_size = win_size-1;
    
  else
    error('Unknown data.')
  end
  
  disp([dat, ' & ', num2str(size(alldata,1)), ' & ', num2str(size(alldata,2)), ...
    ' & ', num2str(round(1000*sum(allclass==1)/numel(allclass))/10), ' & ', ...
    num2str(round(1000*sum(allclass==2)/numel(allclass))/10), '\\'])
end
%% se
clc; 
clear; 
close all;


datasets = {
    'adult_train.csv'
    'bank.csv'
    'blood.csv'
    'breast-cancer-wisc-diag.csv'
    'breast-cancer-wisc-prog.csv'
    'breast-cancer-wisc.csv'
    'breast-cancer.csv'
    'chess-krvkp.csv'
    'congressional-voting.csv'
    'conn-bench-sonar-mines-rocks.csv'
    'connect-4.csv'
    'credit-approval.csv'
    'cylinder-bands.csv'
    'heart-hungarian.csv'
    'hill-valley_train.csv'
    'horse-colic_train.csv'
    'ilpd-indian-liver.csv'
    'ionosphere.csv'
    'magic.csv'
    'mammographic.csv'
    'miniboone.csv'
    'mushroom.csv'
    'musk-2.csv'
    'oocytes_merluccius_nucleus_4d.csv'
    'oocytes_trisopterus_nucleus_2f.csv'
    'ozone.csv'
    'pima.csv'
    'ringnorm.csv'
    'spambase.csv'
    'statlog-australian-credit.csv'
    'statlog-german-credit.csv'
    'statlog-heart.csv'
    'tic-tac-toe.csv'
    'titanic.csv'
    'twonorm.csv'
    'vertebral-column-2clases.csv'
  };


for dd = 1:length(datasets)
  dat = datasets{dd};
    
  if strcmp(datasets{dd}, 'ionosphere')
    load ionosphere
    [~,~,y] = unique(Y);
    allclass = y;
    alldata(:, 2) = [];
    
  elseif strcmp(datasets{dd}, 'ovariancancer')
    load ovariancancer
    [~,~,y] = unique(grp);
    allclass = y;
    alldata = obs;
  elseif strcmp(datasets{dd}, 'arrhythmia')
    load arrhythmia
    dels = find(Y==16);
    Y(dels) = [];
    X(dels, :) = [];
    X(:, [11,2,14]) = [];
    z = sum(isnan(X),2);
    X(z==1, :) = [];
    Y(z==1) = [];
    Y(Y~=1) = -1;
    Y(Y==-1) = 2;
    data = [Y X];
    alldata = X;
    allclass = Y;
    clear dels Description VarNames X Y z
  elseif length(findstr('csv', datasets{dd})) > 0
    data = load(['../../../ClassificationDatasets/csv/', datasets{dd}]);
    X = data(:, 1:end-1);
    Y = data(:, end);
    Y(Y == 0) = 2;
    X = X(:, std(X)~=0);
    alldata = X;
    allclass = Y;
  else
    load(['../../../OFSE/data/', datasets{dd}, '.mat'])
    X = data(:, 2:end);
    Y = data(:, 1);
    X = X(:, std(X)~=0);
    Y(Y==-1) = 2;
    alldata = X;
    allclass = Y;
  end
  
  c = sort([round(1000*sum(allclass==1)/numel(allclass))/10 round(1000*sum(allclass==2)/numel(allclass))/10]);
  %[labels,data] = standardize_data(data);
  [nos, nof] = size(alldata);
    disp([strrep(dat,'.csv',''), ' & ', num2str(nos), ' & ', num2str(nof), ...
    ' & ', num2str(c(2)), ' & ', ...
    num2str(c(1)), '\\'])

end