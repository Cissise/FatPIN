function [f_data,domin_range,dose_,V18_OAR_,D95_Target_] = step_fda_multiple(file,action,dose) %return dvh_all,r_,dose,v1.8

matRad_rc
load(file);
ind = ~cellfun(@isempty, cst);


%Get the index of target and oar
TARGET_Inx=[];
OAR_Inx=[];



for i = 1:size(cst,1) %Traverse all indexes, only CTV and PTV are needed
    if isequal(cst{i,2},'CTV') | isequal(cst{i,2},'PTV')
        TARGET_Inx=[TARGET_Inx;i];
    end
end

for i = 1:size(cst,1) 
    if ~isequal(cst{i,2},'CTV') && ~isequal(cst{i,2},'PTV') && ~isequal(cst{i,2},'Ring1PTV') && ~isequal(cst{i,2},'Ring2PTV') && ~isequal(cst{i,2},'Ring3PTV') && ~isequal(cst{i,2},'Ring4PTV') && ~isequal(cst{i,2},'Ring5PTV') && ~isempty(cst{i,6}) 
        OAR_Inx=[OAR_Inx;i];
    end
end


cst_Inx=find(ind(:,6)==1)';



k=1;
for i = cst_Inx %[1,n]
    %cons
    cst{i,6}{1,1}.parameters(1)={dose(k)*action(k)};
    k=k+1;
end

%Get the current dose
dose=[];
for k=cst_Inx
    dose(k)=cell2mat(cst{k, 6}{1, 1}.parameters(1));
end

dose_=dose(cst_Inx);
%%

[resultGUI,optimizer] = matRad_fluenceOptimization(dij,cst,pln);


%Calculate dvh and qi
[dvh,qi] = matRad_indicatorWrapper(cst,pln,resultGUI,1.8,95);



%% Output Rewards
%Calculate the dvh area after modifying dose
dvh_all_=[];
area_all_=[];
area_oar_=[];
area_target_=[];
functional_data=[];
domin_range = dvh(1).doseGrid;
for i= cst_Inx
    dvh_all_(i,:)=[dvh(i).doseGrid,dvh(i).volumePoints];
    A = reshape(dvh_all_(i,:),100,2);
    area_all_(i)=trapz(A(:,1),A(:,2));
end

for i= cst_Inx
    functional_data(i,:)=[dvh(i).volumePoints];
end

f_data = functional_data(cst_Inx,:);
state_ = dvh_all_(cst_Inx,:);
area_oar_=area_all_(OAR_Inx);
area_target_=area_all_(TARGET_Inx);

%Calculate the d95 and v18 after modifying the dose 
V18_OAR_=[];
V18_ALL_=[];
D95_Target_=[];
D95_ALL_=[];
for i =OAR_Inx
    V18_OAR_=[V18_OAR_,qi(i).V_1_8Gy];
end

for i =cst_Inx
    V18_ALL_=[V18_ALL_,qi(i).V_1_8Gy];
end

for i =TARGET_Inx
    D95_Target_=[D95_Target_,qi(i).D_95];
end

for i =cst_Inx
    D95_ALL_=[D95_ALL_,qi(i).D_95];
end





