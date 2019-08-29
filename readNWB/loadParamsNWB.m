function S = loadParamsNWB(NWBdir);
if ~ismember('nwb',evalin('base','who')) %only does the next part of the code if nwb does not exist in the workspace
    %% get the NWB filename from existing vars
    nwbPathTemp=dir(fullfile(NWBdir, '*.nwb'));
    nwbPath=fullfile(nwbPathTemp.folder,nwbPathTemp.name);
    
    %% check if core is generated, and if no, generate core
    [CoreDirTemp]=fileparts(which('nwbRead.m'));
    CoreDir=fullfile(CoreDirTemp, '+types','+core');
    
    if isempty(dir(CoreDir))
        generateCore(fullfile(CoreDirTemp,'schema','core','nwb.namespace.yaml'));
    end
    %% Load NWB to matlab workspace
    nwb = nwbRead(nwbPath,'0');
else
    nwb = evalin('base', 'nwb');
end 


metadata=values(nwb.general_extracellular_ephys_electrodes.vectordata);

S.dat_path=''; %not sure if this fiels is used so assigning it as empty
S.n_channels_dat=size(metadata{1, 2}.data,1);
S.dtype='double'; %not sure whether data type really matters here so assigning it as double
S.offset=0;
S.sample_rate = 30000; %can't find in nwb file, manually adding for now
    if strcmp(metadata{1}.data.load(1),'The raw voltage signals from the electrodes were not high-pass filtered')
        S.hp_filtered = false;
    else
        S.hp_filtered = true;
    end
% S.gain=1;
end