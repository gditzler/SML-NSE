function print_table(alg_names, data_names, scores, ranks)
disp(' '); 
disp(' '); 

str = '';
for a = 1:length(alg_names)
  str = [str, ' & \bf ', alg_names{a}];
end
disp([str, ' \\ ']); 


for d = 1:length(data_names)
  str = data_names{d};
  str = strrep(str, '_train', '');
  str = strrep(str, '_', '');
  for a = 1:length(alg_names)
    str = [str, ' & ', num2str(scores(d, a)), ' (',  num2str(ranks(d, a)), ') '];
  end
  str = [str, ' \\ '];
  disp(str);
end

mR = mean(ranks);
str = 'ranks ';
for a = 1:length(alg_names)
  str = [str, ' & ', num2str(mR(a))];
end
disp([str, ' \\ ']); 
disp(' '); 
disp(' '); 

