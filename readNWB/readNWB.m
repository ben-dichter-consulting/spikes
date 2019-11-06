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
        stind_temp=nwb.units.spike_times_index.loadAll;
        stind=stind_temp.data;
%         tempclus=values(nwb.units.vectordata);
        id=nwb.units.id.data.load';
        data(1:stind(1),1)=id(1);
        for chan=2:length(stind)
            data(stind(chan-1):stind(chan),1)=id(chan);
        end

        
    case 'cgs'
        tempdata=values(nwb.units.vectordata);
        data=double(load(tempdata{1, 1}.data))';
        
    case 'spike_clusters' %spike_clusters cluster_groups cluster_group are same right now
        vectordata=nwb.units.vectordata.values;
        data=vectordata.data.load;
        
    case 'amplitudes' %does this exist in nwb
        step1=nwb.processing.values;
        step2=step1{1, 1}.nwbdatainterface.values;
        step3=step2{1, 1}.vectordata.values;
        data=step3{1, 1}.data.load;
        
    case 'pc_features' % figure this out later % nSpikes x nFeatures x nLocalChannels
        %         vectordata=nwb.units.vectordata.values;
        %         data=nwb.units.id.data.load;
        %
    case 'cids' % nTemplates x nLocalChannels
        data=double(nwb.units.id.data.load');
        
    case 'pc_feature_ind' % nTemplates x nLocalChannels
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
        %         data=pullfrommat('sp.temps'); %this is to pull from provided matlab file
        temp=nwb.units.waveform_mean;
        data=temp.data.load;
        
    case 'whitening_mat_inv' %what is this even??
        data=1;
        
    case 'channel_map' %just using x-y positions of channels
        data=nwb.general_extracellular_ephys_electrodes.id.data.load;
        
    otherwise
        disp('don''t know what to pull from nwb file')
end


