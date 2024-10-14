% dose_5=[42.79,47.55,47.55,47.55,47.55,56.87,48.41,55.16,53.26,47.07,45.07,39.98,52.3,19.4];
% dose_30=[34.64,39.66,37.36,37.74,39.27,43.78,39.99,43.76,42.26,36.98,35.06,31.72,42.33,15.7];

%Initial measurement
dose_init=[50,50,50,50,50,50,50,50,50,50,50,50,50,50,50];

data=csvread('./result.csv');

%Get the dose
dose_5=data(5,:);
dose_77=data(77,:);

action=ones(15,1);

dvh_all_init = plot_dvh_tuning(action,dose_init);
dvh_all_5 = plot_dvh_tuning(action,dose_5);
dvh_all_77 = plot_dvh_tuning(action,dose_77);

load('./patient.mat');
matRad_showDVH(dvh_all_5,cst,pln,2);
hold on
matRad_showDVH(dvh_all_77,cst,pln,1)
hold on
matRad_showDVH(dvh,cst,pln,1)
hold on 
matRad_showDVH(dvh_best,cst,pln,2)


%Output dvh
ind = ~cellfun(@isempty, cst);

cst_Inx=find(ind(:,6)==1)';
dvh_5=[];
dvh_30=[];
dvh_init=[];
for j= cst_Inx
    dvh_5(j,:)=[dvh_all_5(j).doseGrid,dvh_all_5(j).volumePoints];
    dvh_77(j,:)=[dvh_all_30(j).doseGrid,dvh_all_77(j).volumePoints];
    dvh_init(j,:)=[dvh_all_init(j).doseGrid,dvh_all_init(j).volumePoints];
end
dvh_5=dvh_5(cst_Inx,:);
dvh_77=dvh_77(cst_Inx,:);
dvh_init=dvh_init(cst_Inx,:);

dvh_all_best=[];
for j= cst_Inx
    dvh_all_best(j,:)=[dvh_best(j).doseGrid,dvh_best(j).volumePoints];
end
dvh_all_best=dvh_all_best(cst_Inx,:);


%Calculate moving area
dvh=[];
area_step_5=[];
area_step_30=[];
area_step_init=[];
for i = 1:14
    dvh(i,:)=dvh_5(i,:);
    A = reshape(dvh(i,:),100,2);
    area_step_5(i)=trapz(A(:,1),A(:,2));
    dvh(i,:)=dvh_30(i,:);
    A = reshape(dvh(i,:),100,2);
    area_step_77(i)=trapz(A(:,1),A(:,2));
    dvh(i,:)=dvh_init(i,:);
    A = reshape(dvh(i,:),100,2);
    area_step_init(i)=trapz(A(:,1),A(:,2));
end



dvh=[];
area_step_best=[];
for i = 1:14
    dvh(i,:)=dvh_all_best(i,:);
    A = reshape(dvh(i,:),100,2);
    area_best(i)=trapz(A(:,1),A(:,2));
end
contrast_5_30=area_step_5-area_step_30;
contrast_init_5=area_step_init-area_step_5;
contrast_init_best=area_step_init-area_best;