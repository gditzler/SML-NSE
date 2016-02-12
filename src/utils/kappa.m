function kap = kappa(cm)

z = sum(sum(cm));
po = sum(diag(cm))/z;

p1 = sum(cm(1,:))/z;
p2 = sum(cm(:,1))/z;

p11 = p1*p2;
p22 = (1 - p1)*(1 - p2);
pe = p11 + p22;

kap = (po - pe)/(1 - pe);


