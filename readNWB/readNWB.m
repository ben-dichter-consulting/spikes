function data = readNWB(NWBdir, desOut)

if ~exist('nwb') %only does the next part of the code if nwb does not exist in the workspace
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
    nwb = nwbRead(nwbPath);
end

%% pull correct data from the
switch desOut
    case 'spike_times'
        data=nwb.units.spike_times.data.load;
        
    case 'spike_templates'                                                  %%TEMPORARILY REPLACED WITH spike_clusters
%         data=nwb.units.waveform_mean.data.load;
        vectordata=nwb.units.vectordata.values;
        data=nwb.units.id.data.load;
        
    case 'spike_clusters' %spike_clusters cluster_groups cluster_group are same right now
        vectordata=nwb.units.vectordata.values;
        data=nwb.units.id.data.load;
        
    case 'amplitudes' %does this exist in nwb
        data=[]; 
        
    case 'pc_features' % figure this out later % nSpikes x nFeatures x nLocalChannels
        data='pc_features';
        
    case 'pc_feature_ind' % figure this out later  % nTemplates x nLocalChannels
        data='pc_feature_ind';
        
    case 'cluster_groups' %spike_clusters cluster_groups cluster_group are same right now
        vectordata=nwb.units.vectordata.values;
        data=nwb.units.id.data.load;
        
    case 'cluster_group' %spike_clusters cluster_groups cluster_group are same right now
        vectordata=nwb.units.vectordata.values;
        data=nwb.units.id.data.load;
        
    case 'channel_positions'
        metadata=values(nwb.general_extracellular_ephys_electrodes.vectordata);
        pos(1,:)=metadata{8}.data.load;
        pos(2,:)=metadata{9}.data.load;
        data=pos;
        
    case 'templates'
        data=nwb.units.waveform_mean.data.load;
        
    case 'whitening_mat_inv' %what is this even??
        data=[]; 
        
    case 'channel_map' %just using x-y positions of channels
        metadata=values(nwb.general_extracellular_ephys_electrodes.vectordata);
        pos(1,:)=metadata{8}.data.load;
        pos(2,:)=metadata{9}.data.load;
        data=pos;
        
    otherwise
        disp('don''t know what to pull from nwb file')
end

%% this is for reference as an output of old functions

% 
% spikeStruct.st = st;
% spikeStruct.spikeTemplates = spikeTemplates;
% spikeStruct.clu = clu;
% spikeStruct.tempScalingAmps = tempScalingAmps;
% spikeStruct.cgs = cgs;
% spikeStruct.cids = cids;
% spikeStruct.xcoords = xcoords;
% spikeStruct.ycoords = ycoords;
% spikeStruct.temps = temps;
% spikeStruct.winv = winv;
% spikeStruct.pcFeat = pcFeat;
% spikeStruct.pcFeatInd = pcFeatInd;
% 
%     sp(q).spikeAmps = spikeAmps;
%     sp(q).spikeDepths = spikeDepths;
%     sp(q).templateYpos = templateYpos;
%     sp(q).tempAmps = tempAmps;
%     sp(q).tempsUnW = tempsUnW;
%     sp(q).tempDur = tempDur;
%     sp(q).tempPeakWF = tempPeakWF;
    