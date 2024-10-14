function dvh = plot_dvh_tuning(action,dose)
matRad_rc
load('./data_train/patient.mat');
ind = ~cellfun(@isempty, cst);

cst_Inx=find(ind(:,6)==1)';

%Get the index where the conditional organization is empty
cst_Inx_none=find(ind(:,6)==0)';
for j = cst_Inx_none
    cst{j,5}.Priority=4;
    % Visualization
    cst{j,5}.Visible=0;
end

[resultGUI,optimizer] = matRad_fluenceOptimization(dij,cst,pln);

[dvh,qi] = matRad_indicatorWrapper(cst,pln,resultGUI);
doseCube = resultGUI.physicalDose;
dvh = matRad_calcDVH(cst,doseCube,'cum');
end

