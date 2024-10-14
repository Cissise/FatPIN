function [f_data,domin_range,V18_OAR,D95_Target] = reset_fda_multipatient(file,dose) %return dvh_all,r_,dose,v1.8

matRad_rc
load(file);
ind = ~cellfun(@isempty, cst);

%%
%Get the index of target and oar
TARGET_Inx=[];
OAR_Inx=[];

for i = 1:size(cst,1) %Traverse all indexes, only CTV is needed
    if isequal(cst{i,2},'CTV') | isequal(cst{i,2},'PTV')
        TARGET_Inx=[TARGET_Inx;i];
    end
end

for i = 1:size(cst,1) %Traverse all indexes
    if ~isequal(cst{i,2},'CTV') && ~isequal(cst{i,2},'PTV') && ~isequal(cst{i,2},'Ring1PTV') && ~isequal(cst{i,2},'Ring2PTV') && ~isequal(cst{i,2},'Ring3PTV') && ~isequal(cst{i,2},'Ring4PTV') && ~isequal(cst{i,2},'Ring5PTV') && ~isempty(cst{i,6}) 
        OAR_Inx=[OAR_Inx;i];
    end
end

%The tissue index whose condition is not empty (organ with constraint condition)
cst_Inx=find(ind(:,6)==1)';


k=1;
for i = cst_Inx %[1,n]
    %cons
    cst{i,6}{1,1}.parameters(1)={dose(k)};
    k=k+1;
end

%%

[resultGUI,optimizer] = matRad_fluenceOptimization(dij,cst,pln);


%Calculate dvh and qi
[dvh,qi] = matRad_indicatorWrapper(cst,pln,resultGUI,1.8,95);



%% Output Rewards
%Calculate the dvh area after modifying dose
dvh_all=[];
area_all=[];
area_oar=[];
area_target=[];
functional_data=[];
domin_range = dvh(1).doseGrid;

for i= cst_Inx
    dvh_all(i,:)=[dvh(i).doseGrid,dvh(i).volumePoints];
    A = reshape(dvh_all(i,:),100,2);
    area_all(i)=trapz(A(:,1),A(:,2));
end

for i= cst_Inx
    functional_data(i,:)=[dvh(i).volumePoints];
end

f_data = functional_data(cst_Inx,:);
%state = dvh_all(cst_Inx,:);
area_oar =area_all(OAR_Inx);
area_target =area_all(TARGET_Inx);

%Calculate the d95 and v18 after modifying the dose 
V18_OAR=[];
V18_ALL=[];
D95_Target=[];
D95_ALL=[];
for i =OAR_Inx
    V18_OAR=[V18_OAR,qi(i).V_1_8Gy];
end

for i =cst_Inx
    V18_ALL=[V18_ALL,qi(i).V_1_8Gy];
end

for i =TARGET_Inx
    D95_Target=[D95_Target,qi(i).D_95];
end

for i =cst_Inx
    D95_ALL=[D95_ALL,qi(i).D_95];
end




