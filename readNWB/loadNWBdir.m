
function spikeStruct = loadNWBdir(ksDir, varargin)
%% check if nwb file exists
nwbPathTemp=dir(fullfile(ksDir, '*.nwb'));
if isempty(nwbPathTemp)
    disp('no nwb file detected in specified directory. Using legacy code')
    spikeStruct = loadKSdir(ksDir, varargin);
else
    %%
    
    if ~isempty(varargin)
        params = varargin{1};
    else
        params = [];
    end
    
    if ~isfield(params, 'excludeNoise')
        params.excludeNoise = true;
    end
    if ~isfield(params, 'loadPCs')
        params.loadPCs = false;
    end
    
    % load spike data
    
    spikeStruct = loadParamsNWB(ksDir);
    
    st = readNWB(ksDir, 'spike_times');
    %st = double(ss)/spikeStruct.sample_rate;
    spikeTemplates = readNWB(ksDir, 'spike_templates'); % note: zero-indexed
    
    % if exist(fullfile(ksDir, 'spike_clusters.npy'))                                %% CHANGE TO PROPER CHECK
    %     clu = readNWB(ksDir, 'spike_clusters');
    % else
    clu = spikeTemplates;
    % end
    
    tempScalingAmps = readNWB(ksDir, 'amplitudes');
    
    if params.loadPCs
        pcFeat = readNWB(ksDir,'pc_features'); % nSpikes x nFeatures x nLocalChannels
        pcFeatInd = readNWB(ksDir,'pc_feature_ind'); % nTemplates x nLocalChannels
    else
        pcFeat = [];
        pcFeatInd = [];
    end
    
    cids = readNWB(ksDir,'cids');
    cgs = readNWB(ksDir,'cgs');
    % end
    
    
    coords = readNWB(ksDir, 'channel_positions');
    ycoords = coords(:,2); xcoords = coords(:,1);
    temps = readNWB(ksDir, 'templates');
    
    winv = readNWB(ksDir, 'whitening_mat_inv');
    
    spikeStruct.st = st;
    spikeStruct.spikeTemplates = spikeTemplates;
    spikeStruct.clu = clu;
    spikeStruct.tempScalingAmps = tempScalingAmps;
    spikeStruct.cgs = cgs;
    spikeStruct.cids = cids;
    spikeStruct.xcoords = xcoords;
    spikeStruct.ycoords = ycoords;
    spikeStruct.temps = temps;
    spikeStruct.winv = winv;
    spikeStruct.pcFeat = pcFeat;
    spikeStruct.pcFeatInd = pcFeatInd;
end
end