function [predicted_label, best_distance, nearest] = knn_classify(training_data, labels, test_instance)

    
    best_distance = inf;
    [tam, ~] = size(training_data);
    for i = 1:tam
        compare_data = training_data(i, :);
        distance = sqrt(sum((test_instance - compare_data).^ 2)); %euclidean distance
        if(distance < best_distance)
            best_distance = distance;
            predicted_label = labels(i);
            nearest = compare_data;
        end
    end
end