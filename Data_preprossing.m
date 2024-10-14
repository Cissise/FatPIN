file_path=['./data_train/patient.mat'];
load(file_path)
matRad_rc

ind = ~cellfun(@isempty, cst);
organ_index=find(ind(:,1)==1)';
for i = organ_index
    cst{i,6}=[];
end
%% OAR

%'bladder'(OAR) (p,dose,v) Objectives
%'bladder' (OAR) (dRef,vMin,vMax) Constraints
index_Bla = get_index(cst,'Bladder');
if index_Bla ~= 0
    %cst{index_Bla,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,0,40));
    cst{index_Bla,6}{1}=struct(DoseObjectives.matRad_MaxDVH(20,50,50));    
end

%'Femoral Head R'(OAR)
index_FR = get_index(cst,'Femoral Head R');
if index_FR ~= 0
    %cst{index_FR,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,0,40));
    cst{index_FR,6}{1}=struct(DoseObjectives.matRad_MaxDVH(20,50,50));
end

%'Femoral Head L'(OAR)
index_FL = get_index(cst,'Femoral Head L');
if index_FL ~= 0
    %cst{index_FL,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,0,40));
    cst{index_FL,6}{1}=struct(DoseObjectives.matRad_MaxDVH(20,50,50));
end


%'Rectum'(OAR)
index_Rec = get_index(cst,'Rectum');
if index_Rec ~= 0
    %cst{index_Rec,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,0,40));
    cst{index_Rec,6}{1}=struct(DoseObjectives.matRad_MaxDVH(20,50,50));
end


%'Small inteestine'小肠(OAR)
index_Small_i = get_index(cst,'Small intestine');
if index_Small_i ~= 0
    cst{index_Small_i,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,0,40));
    cst{index_Small_i,6}{1}=struct(DoseObjectives.matRad_MaxDVH(20,50,50));
end


%Bladder out
index_Bla_out = get_index(cst,'bladder out');
index_Bla_out = get_index(cst,'Bladder out');
if index_Bla_out ~= 0
    %cst{index_Bla_out,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,0,40));
    cst{index_Bla_out,6}{1}=struct(DoseObjectives.matRad_MaxDVH(20,50,50));
    cst{index_Bla_out,5}.Priority=2;
end


%'Rectum out'
index_Rectum_out = get_index(cst,'rectum out');
index_Rectum_out = get_index(cst,'Rectum out');

if index_Rectum_out ~= 0
    %cst{index_Rectum_out,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,0,40));
    cst{index_Rectum_out,6}{1}=struct(DoseObjectives.matRad_MaxDVH(20,50,50));
    cst{index_Rectum_out,5}.Priority=2;
end


%'Small intestine out'
index_Small_i_out = get_index(cst,'Small intestine out');

if index_Small_i_out ~= 0
    %cst{index_Small_i_out,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,0,50));
    cst{index_Small_i_out,6}{1}=struct(DoseObjectives.matRad_MaxDVH(20,50,50));
    cst{index_Small_i_out,5}.Priority=2;
end


%'CTV'
index_CTV = get_index(cst,'CTV');
if index_CTV ~= 0
    %cst{index_CTV,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,90,100));
    cst{index_CTV,6}{1}=struct(DoseObjectives.matRad_MinDVH(20,50,95));
end


%'PTV'
index_PTV = get_index(cst,'PTV');
if index_PTV ~= 0
    %cst{index_PTV,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,90,100));
    cst{index_PTV,6}{1}=struct(DoseObjectives.matRad_MinDVH(20,50,95));
end


%Ring1PTV
index_Ring1PTV = get_index(cst,'Ring1PTV');
if index_Ring1PTV ~= 0
    %cst{index_Ring1PTV,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,90,100));
    cst{index_Ring1PTV,6}{1}=struct(DoseObjectives.matRad_MinDVH(20,50,95));
    cst{index_Ring1PTV,5}.Priority=3;
end

%Ring2PTV
index_Ring2PTV = get_index(cst,'Ring2PTV');
if index_Ring2PTV ~= 0
    %cst{index_Ring2PTV,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,90,100));
    cst{index_Ring2PTV,6}{1}=struct(DoseObjectives.matRad_MinDVH(20,50,95));
    cst{index_Ring2PTV,5}.Priority=3;
end

%Ring3PTV
index_Ring3PTV = get_index(cst,'Ring3PTV');
if index_Ring3PTV ~= 0
    %cst{index_Ring3PTV,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,90,100));
    cst{index_Ring3PTV,6}{1}=struct(DoseObjectives.matRad_MinDVH(20,50,95));
    cst{index_Ring3PTV,5}.Priority=3;
end

%Ring4PTV
index_Ring4PTV = get_index(cst,'Ring4PTV');
if index_Ring4PTV ~= 0
    %cst{index_Ring4PTV,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,90,100));
    cst{index_Ring4PTV,6}{1}=struct(DoseObjectives.matRad_MinDVH(20,50,95));
    cst{index_Ring4PTV,5}.Priority=3;
end

%Ring5PTV
index_Ring5PTV = get_index(cst,'Ring5PTV');
if index_Ring5PTV ~= 0
    %cst{index_Ring5PTV,6}{1}=struct(DoseConstraints.matRad_MinMaxDVH(50,90,100));
    cst{index_Ring5PTV,6}{1}=struct(DoseObjectives.matRad_MinDVH(20,50,95));
    cst{index_Ring5PTV,5}.Priority=3;
end

%% 
%Find the index of OAR
oar_index=get_index_OarTarget(cst,'OAR');
%Find the Target index
target_index=get_index_OarTarget(cst,'TARGET');
%Find the organization index where the condition is empty
ind = ~cellfun(@isempty, cst); %Check the Boolean value in the struct, and see if it returns 1 or not.
cst_empty_index=find(ind(:,6)==0)';

%% priority
%Organ priority: some structures have overlapping voxels, so you need to set the priority to ensure that a voxel belongs to only one structure during calculation.
for i=cst_empty_index
    cst{i,5}.Priority=4;
end
%% Visualization
for i=cst_empty_index
    cst{i,5}.Visible=0;
end
%% save
save(file_path,'cst','ct')