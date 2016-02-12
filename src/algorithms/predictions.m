function H = predictions(ensemble, data)
  for j = 1:length(ensemble)
    H(:, j) = classifier_test(ensemble{j}, data);
  end
end