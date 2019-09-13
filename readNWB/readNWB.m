function data = readNWB(NWBdir, desOut)

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
    assignin('base','nwb',nwb)
else
    nwb = evalin('base', 'nwb');
end


%% pull correct data from the
switch desOut
    case 'spike_times'
        data=nwb.units.spike_times.data.load;
        
    case 'spike_templates'   %%FAKE DATA UNTIL NWB HAS IT
%         data=ceil(pullfrommat('sp.spikeTemplates')/2-3);
        data=ceil(pullfrommat('sp.spikeTemplates'));
        
    case 'cgs'   
        tempdata=values(nwb.units.vectordata);
        data=double(load(tempdata{1, 1}.data))';

    case 'spike_clusters' %spike_clusters cluster_groups cluster_group are same right now
        vectordata=nwb.units.vectordata.values;
%         data=nwb.units.id.data.load;
        data=vectordata.data.load;
        
    case 'amplitudes' %does this exist in nwb
        data=pullfrommat('sp.tempScalingAmps');
        
    case 'pc_features' % figure this out later % nSpikes x nFeatures x nLocalChannels
        vectordata=nwb.units.vectordata.values;
        data=nwb.units.id.data.load;
%         
    case 'cids' % nTemplates x nLocalChannels
        vectordata=nwb.units.vectordata.values;
        data=double(nwb.units.id.data.load');        
                
    case 'pc_feature_ind' % nTemplates x nLocalChannels
        vectordata=nwb.units.vectordata.values;
        data=nwb.units.id.data.load;
        
        
    case 'cluster_groups' %spike_clusters cluster_groups cluster_group are same right now
        vectordata=nwb.units.vectordata.values;
        data=vectordata{1}.data.load;
        
    case 'cluster_group' %spike_clusters cluster_groups cluster_group are same right now
        vectordata=nwb.units.vectordata.values;
        data=vectordata{1}.data.load;
        
    case 'channel_positions'
        metadata=values(nwb.general_extracellular_ephys_electrodes.vectordata);
        pos(:,1)=int32(metadata{6}.data.load);
        pos(:,2)=int32(metadata{7}.data.load);
        data=double(pos);
        
    case 'templates'
%         data=nwb.units.waveform_mean.data.load;
        data=pullfrommat('sp.temps');        
        
    case 'whitening_mat_inv' %what is this even??
        data=1;
        
    case 'channel_map' %just using x-y positions of channels
        data=nwb.general_extracellular_ephys_electrodes.id.data.load;
        
    otherwise
        disp('don''t know what to pull from nwb file')
end
