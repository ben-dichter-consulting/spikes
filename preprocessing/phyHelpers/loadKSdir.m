
function spikeStruct = loadKSdir(ksDir, varargin)

%% check if nwb file exists
nwbPathTemp=dir(fullfile(ksDir, '*.nwb'));
if isempty(nwbPathTemp)
    disp('no nwb file detected in specified directory. Using legacy code')
    spikeStruct = loadKSdir_legacy(ksDir, varargin);
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
    
    ss = readNWB(ksDir, 'spike_times');
    st = double(ss)/spikeStruct.sample_rate;
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
    
    % cgsFile = '';
    % if exist(fullfile(ksDir, 'cluster_groups.csv'))
    %     cgsFile = fullfile(ksDir, 'cluster_groups.csv');
    % end
    % if exist(fullfile(ksDir, 'cluster_group.tsv'))
    %    cgsFile = fullfile(ksDir, 'cluster_group.tsv');
    % end
    % if ~isempty(cgsFile)
    %     [cids, cgs] = readClusterGroupsCSV(cgsFile);
    %
    %     if params.excludeNoise
    %         noiseClusters = cids(cgs==0);
    %
    %         st = st(~ismember(clu, noiseClusters));
    %         spikeTemplates = spikeTemplates(~ismember(clu, noiseClusters));
    %         tempScalingAmps = tempScalingAmps(~ismember(clu, noiseClusters));
    %
    %         if params.loadPCs
    %             pcFeat = pcFeat(~ismember(clu, noiseClusters), :,:);
    %             %pcFeatInd = pcFeatInd(~ismember(cids, noiseClusters),:);
    %         end
    %
    %         clu = clu(~ismember(clu, noiseClusters));
    %         cgs = cgs(~ismember(cids, noiseClusters));
    %         cids = cids(~ismember(cids, noiseClusters));
    %
    %
    %     end
    %
    % else
    %     clu = spikeTemplates;
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