%---dataset = path/name of dataset
%--numini number of instances of initial labeled data
%---max_pool_length = num of instances for perform the clustering in pool
%data
%example: [vet_bin_acc, acc_final, ~] = SCARGC_1NN('MC-2C-2D.txt', 50, 300, 2)
%To see the results over time: plot100Steps(vet_bin_acc, '-r')
function [vet_bin_acc, acc_final, elapsedTime, errors, kappas, timerz] = SCARGC_1NN(data, numini, max_pool_length, nK)
    
    %save time
    tic;
    %data = load(dataset);
   
    initial_labeled_DATA = data(1:numini,1:end-1);
    initial_labeled_LABELS = data(1:numini,end);
    
    %in the beginning, labeled data are equal initially labeled data
    labeled_DATA = initial_labeled_DATA;
    labeled_LABELS = initial_labeled_LABELS;
  
    
    %unlabeled data used for the test phase
    unlabeled_DATA = data(numini+1:end, 1:end-1);
    unlabeled_LABELS = data(numini+1:end,end);
    
    classes = unique(labeled_LABELS);
    nClass = length(classes);
    
    centroids_ant = [];
    tmp_cent = [];
    calc_error = @(x, y) sum(x ~= y)/numel(y);

    kappas = [];
    errors = [];
    timerz = [];
    %first centroids
    if nK == nClass %for unimodal case, the initial centroid of each class is the mean of each feature
        for cl = 1 : nClass
            tmp_cent = [];
            for atts = 1: size(initial_labeled_DATA,2)
                tmp_cent = [tmp_cent, median(initial_labeled_DATA(initial_labeled_LABELS==classes(cl), atts))];
            end
            centroids_ant = [centroids_ant; tmp_cent];
        end
        centroids_ant = [centroids_ant, classes];
    else %for multimodal case, the initial centroids are estimated by kmeans
        [~, centroids_ant] = kmeans(initial_labeled_DATA, nK);
        %associate labels for first centroids
        centroids_ant_lab = [];
        for core = 1:size(centroids_ant,1)
           [pred_lab,~] = knn_classify(initial_labeled_DATA, initial_labeled_LABELS, centroids_ant(core,:)); 
           centroids_ant_lab = [centroids_ant_lab; pred_lab];
        end
        centroids_ant = [centroids_ant, centroids_ant_lab];
    end
    %timerz(end+1) = toc;
    cluster_labels = [];
    pool_data = [];
    vet_bin_acc = [];
    pool_data2 = [];
    updt=0;
    
    tic;
    for i = 1:length(unlabeled_LABELS)
       test_instance = unlabeled_DATA(i,:);
       actual_label = unlabeled_LABELS(i);
       
       %classify each stream's instance with 1NN classifier
       [predicted_label, ~, ~] = knn_classify(labeled_DATA, labeled_LABELS, test_instance);
  
       pool_data = [pool_data; test_instance, predicted_label];
       pool_data2 = [pool_data2; actual_label];
       
       if (size(pool_data,1) == max_pool_length)
          
           kappas(end+1) = kappa(confusionmat(pool_data2, pool_data(:, end)));
           errors(end+1) = calc_error(pool_data(:, end), pool_data2); 
           %FOR NOAA DATASET, COMMENT NEXT LINE
           [~, centroids_cur] = kmeans(pool_data(:,1:end-1), nK, 'start', centroids_ant(end-nK+1:end,1:end-1));        
           %FOR NOAA DATASET, REMOVE THE COMMENT OF THE NEXT LINE
           %[~, centroids_cur] = kmeans(pool_data(:,1:end-1), nK);        
           intermed = [];
           cent_labels = [];
           for p = 1:size(centroids_cur,1)
               [clab,~, nearest] = knn_classify(centroids_ant(:,1:end-1), centroids_ant(:,end), centroids_cur(p,:));
               intermed = [intermed; median([nearest; centroids_cur(p,:)]), clab];
               cent_labels = [cent_labels; clab];
           end
           centroids_cur = [centroids_cur, cent_labels];
           
           
           %checks if any label is not associated with some cluster
           labelsIntermed = unique(intermed(:,end));
           if isequal(labelsIntermed, classes) == 0
               atribuicoes = tabulate(intermed(:,end));
               [~,posMax] = max(atribuicoes(:,2));
               [~,posMin] = min(atribuicoes(:,2));
               labelFault = atribuicoes(posMin,1);
               intermed(posMin,end) = labelFault;               
           end

           
           centroids_ant = intermed;
           new_pool = [];
           for p = 1:size(pool_data,1)
              new_pool = [new_pool; knn_classify([centroids_cur(:,1:end-1);centroids_ant(:,1:end-1)],...
                  [centroids_cur(:,end); centroids_ant(:,end)], pool_data(p,1:end-1))];
           end
           concordant_labels = find(pool_data(:,end) == new_pool);
           if length(concordant_labels)/max_pool_length < 1 || length(labeled_LABELS) < size(pool_data,1)
               pool_data(:,end) = new_pool(:,end);
               centroids_ant = [centroids_cur; intermed];

               labeled_DATA = pool_data(:,1:end-1);
               labeled_LABELS = pool_data(:,end); 
           end
                
           groundTruth = [];
           pool_data = [];
           pool_data2 = [];
           timerz(end+1) = toc;
           tic;
           
       end
       
       
       %update vet_bin_acc for calculate the accuracy measure
       if predicted_label == actual_label;
            vet_bin_acc = [vet_bin_acc, 1];
       else
            vet_bin_acc = [vet_bin_acc, 0];
       end
        
    end

    acc_final = (sum(vet_bin_acc)/length(unlabeled_DATA))*100;
    elapsedTime = toc;
    timerz = timerz';
    errors = errors';
    kappas = kappas';
end

    
