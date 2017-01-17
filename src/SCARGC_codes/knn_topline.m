%---dataset = path/name of dataset
%--MAX_TAM number of instances of initial labeled data
%To see the results over time: plot100Steps(vet_bin_acc, '-r')
function [vet_bin_acc, acc_final] = knn_topline(dataset, MAX_TAM)

    data = load(dataset);

   
    train_labels = data(1:MAX_TAM,end);
    test_labels = data(MAX_TAM+1:end,end);
    
    train_data = data(1:MAX_TAM, 1:end-1);
    test_data = data(MAX_TAM+1:end, 1:end-1);
    
    
    vet_bin_acc = [];

    for i = 1 : length(test_data)
        test_instance = test_data(i:i, :);
        correct = test_labels(i);

        [predicted_label, ~, ~] = knn_classify(train_data, train_labels, test_instance);
        
        train_data = [train_data(2:end,:); test_instance];
        train_labels = [train_labels(2:end); correct];
        
        if predicted_label == correct;
            vet_bin_acc = [vet_bin_acc, 1];
        else
            vet_bin_acc = [vet_bin_acc, 0];
        end

    end
    acc_final = (sum(vet_bin_acc)/length(vet_bin_acc))*100;        
