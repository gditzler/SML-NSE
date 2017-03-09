%---dataset = path/name of dataset
%--numini number of instances of initial labeled data
%---max_pool_length = num of instances for perform the clustering in pool
%data
%example: [vet_bin_acc, acc_final, ~] = SCARGC_SVM('MC-2C-2D.txt', 50, 300, 2)
%To see the results over time: plot100Steps(vet_bin_acc, '-r')
function [vet_bin_acc, acc_final, elapsedTime] = SCARGC_SVM(dataset, numini, max_pool_length, nK) 
    
    %save time
    tic;
    data = load(dataset);
   
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
    


    cluster_labels = [];
    pool_data = [];
    vet_bin_acc = [];

    updt=0;
    
    model = libsvmtrain(initial_labeled_LABELS, initial_labeled_DATA, '-t 2 -g 1 -r 10 -b 1 -q'); %RBF model
    for i = 1:length(unlabeled_LABELS)
       test_instance = unlabeled_DATA(i,:);
       actual_label = unlabeled_LABELS(i);

       
       
       %classify each stream's instance with SVM classifier
       [predicted_label, ~, ~] = libsvmpredict(0, test_instance, model, '-b 1 -q');
       pool_data = [pool_data; test_instance, predicted_label];
       
       
       if (size(pool_data,1) == max_pool_length)
           
           %FOR NOAA DATASET, COMMENT NEXT LINE
           [~, centroids_cur] = kmeans(pool_data(:,1:end-1), nK, 'start', centroids_ant(end-nK+1:end,1:end-1));        
           %FOR NOAA DATASET, REMOVE THE COMMENT OF THE NEXT LINE
           %[~, centroids_cur] = kmeans(pool_data(:,1:end-1), nK);        

           intermed = [];
           cent_labels = [];
           for p = 1:size(centroids_cur,1)
               [clab,~, nearest] = knn_classify(centroids_ant(:,1:end-1), ...
                   centroids_ant(:,end), centroids_cur(p,:));
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
               
               model = libsvmtrain(labeled_LABELS, labeled_DATA, '-t 2 -g 1 -r 10 -b 1 -q'); %RBF model
               
               %number of updates
               %updt = updt+1
 
           end
      

% % %            %plot current model by clustering
% % %            opt = ['b^', 'rv', 'ks', 'm*', 'g+'];
% % %            
% % %            for k = 1:nClass
% % %               %index of plot option
% % %               ind = [1,3,5,7,9];
% % %               
% % %               idx = find(labeled_LABELS == classes(k));
% % %               idxCA = find(cent_ant_bkp(:,end) == classes(k));
% % %               idxCC = find(centroids_cur(:,end) == classes(k));
% % %               subplot(1,2,1)
% % %               plot(labeled_DATA(idx,1), labeled_DATA(idx,2), opt(ind(k):ind(k)+1)); hold on;
% % %               plot(cent_ant_bkp(idxCA,1), cent_ant_bkp(idxCA,2), [opt(ind(k)), 'o'], 'MarkerSize', 10, 'LineWidth', 3); hold on;
% % %               plot(centroids_cur(idxCC,1), centroids_cur(idxCC,2), opt(ind(k):ind(k)+1), 'MarkerSize', 10, 'LineWidth', 3); hold on;
% % %               
% % %               title(['Current Model ', num2str(i/max_pool_length)]);
% % % %               axis([-1.5 1.5 -1.5 1.5]) %Hyperplane
% % % %               axis([-5 30 -10 30]) %T2D
% % % %               axis([-5 30 -10 10]) %T2H
% % % %               axis([-6 6 -6 6]) %R4E
% % % %               axis([-5 15 -5 15]) %MG 2C 2D
% % % %               axis([-2 3 -1 1]) %GEARS 2C 2D
% % %               xlabel('Feature 1');
% % %               ylabel('Feature 2');
% % %               hold on;
% % % 
% % %               idxGT = find(groundTruth == classes(k));
% % %               subplot(1,2,2);
% % %               plot(pool_data(idxGT,1), pool_data(idxGT,2), opt(ind(k):ind(k)+1));
% % %               title(['Ground Truth Model ', num2str(i/max_pool_length)]);
% % % %               axis([-1.5 1.5 -1.5 1.5]) %Hyperplane
% % % %               axis([-5 30 -10 30]) %T2D
% % % %               axis([-5 30 -10 10]) %T2H
% % % %               axis([-6 6 -6 6]) %R4E
% % % %               axis([-5 15 -5 15]) %MG 2C 2D
% % % %               axis([-2 3 -1 1]) %GEARS 2C 2D
% % %               xlabel('Feature 1');
% % %               ylabel('Feature 2');
% % %               hold on; 
% % %            end
%            if i/max_pool_length > 329
%                keyboard
%            end
% % % 
% % %            drawnow
% % %            refreshdata
% % %            clf
% % %            
           groundTruth = [];
           pool_data = [];
           
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
end

    
