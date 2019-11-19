function S = loadParamsNWB(NWBdir)
if ~ismember('nwb',evalin('base','who')) %only does the next part of the code if nwb does not exist in the workspace
    %% get the NWB filename from existing vars
    nwbPathTemp=dir(fullfile(NWBdir, '*.nwb'));
    filechoice=1;
    
    if size(nwbPathTemp,1)>1 % check if more than one NWB file exists
        disp('More than one NWB file detected. Select which one you would like to use:')
        for filenum=1:size(nwbPathTemp,1) 
            nwbPathTemp(filenum).filenum=filenum;
        end
        arrayfun(@(x) disp([num2str(x.filenum) ': ' x.name]), nwbPathTemp)
        filechoice=input('Select the number of the file: ');
    end
    
    nwbPath=fullfile(nwbPathTemp(filechoice).folder,nwbPathTemp(filechoice).name);
    
    %% check if core is generated, and if no, generate core
    [CoreDirTemp]=fileparts(which('nwbRead.m'));
    CoreDir=fullfile(CoreDirTemp, '+types','+core');
    
    if isempty(dir(CoreDir))
        generateCore(fullfile(CoreDirTemp,'schema','core','nwb.namespace.yaml'));
    end
    %% Load NWB to matlab workspace
    nwb = nwbRead(nwbPath,'0');    
    assignin('base','nwb',nwb)
else
    nwb = evalin('base', 'nwb');
end 


metadata=values(nwb.general_extracellular_ephys_electrodes.vectordata);

S.dat_path=''; %not sure if this fiels is used so assigning it as empty
S.n_channels_dat=size(metadata{1, 2}.data,1);
S.dtype='double'; %not sure whether data type really matters here so assigning it as double
S.offset=0;
S.sample_rate = 30000; %figureoutsamplerate; %can't find in nwb file, manually adding for now
    if strcmp(metadata{1}.data.load(1),'The raw voltage signals from the electrodes were not high-pass filtered')
        S.hp_filtered = false;
    else
        S.hp_filtered = true;
    end
% S.gain=1;
end