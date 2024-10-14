Path='./data_patient/';             % path of data_patient
save_path='./data_train/patient.mat';
File=dir(fullfile(Path,'*.mat'));   
FileNames={File.name}';             

for i =1:length(FileNames)
   
    disp(['loading file_',num2str(i)])
    
    matRad_rc

    % load patient data, i.e. ct, voi, cst
    file_path=['./data_train/patient1.mat'];
    
    %load HEAD_AND_NECK
    load(file_path)
    
    % meta information for treatment plan
    pln.radiationMode   = 'photons';     % either photons / protons / carbon
    pln.machine         = 'Generic';
    
    pln.numOfFractions  = 28;            %Number of irradiation
    
    % beam geometry settings
    pln.propStf.bixelWidth      = 5;                  % [mm] / also corresponds to lateral spot spacing for particles
    pln.propStf.gantryAngles    = [0 72 144 216 288]; %[200 240 280 320 0 40 80 120 160]; % [?]
    pln.propStf.couchAngles     = [0 0 0 0 0];        %[0 0 0 0 0 0 0 0 0]; % [?]
    pln.propStf.numOfBeams      = numel(pln.propStf.gantryAngles);
    pln.propStf.isoCenter       = ones(pln.propStf.numOfBeams,1) * matRad_getIsoCenter(cst,ct,0);
    
    % dose calculation settings
    pln.propDoseCalc.doseGrid.resolution.x = 5;       % [mm]
    pln.propDoseCalc.doseGrid.resolution.y = 5;       % [mm]
    pln.propDoseCalc.doseGrid.resolution.z = 5;       % [mm]
    
    % optimization settings
    pln.propOpt.optimizer       = 'IPOPT';
    pln.propOpt.bioOptimization = 'none'; % none: physical optimization;             const_RBExD; constant RBE of 1.1;
                                          % LEMIV_effect: effect-based optimization; LEMIV_RBExD: optimization of RBE-weighted dose
    pln.propOpt.runDAO          = 1;  % 1/true: run DAO, 0/false: don't / will be ignored for particles
    pln.propOpt.runSequencing   = 1;  % 1/true: run sequencing, 0/false: don't / will be ignored for particles and also triggered by runDAO below
    
    %generate steering file
    stf = matRad_generateStf(ct,cst,pln);
    
    %dose calculation
    if strcmp(pln.radiationMode,'photons')
        dij = matRad_calcPhotonDose(ct,stf,pln,cst);
        %dij = matRad_calcPhotonDoseVmc(ct,stf,pln,cst);
    elseif strcmp(pln.radiationMode,'protons') || strcmp(pln.radiationMode,'carbon')
        dij = matRad_calcParticleDose(ct,stf,pln,cst);
    end

    %inverse planning for imrt
    resultGUI = matRad_fluenceOptimization(dij,cst,pln);

    %indicator calculation and show DVH and QI
    [dvh,qi] = matRad_indicatorWrapper(cst,pln,resultGUI,1.8,95);

    %save variable
    fileDir=file_path;
    save(fileDir,'cst','ct','dij','pln','stf');
    save(fileDir,'cst','ct','dij','dvh','pln','qi','resultGUI','stf');
    disp(['finishload file_',num2str(i)])

    %clear variable
    %clear
    
end
