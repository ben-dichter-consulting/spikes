function [sp,lickt,lickx,posx,post,trial,trial_contrast,trial_gain]=NWB2mat(varargin)
defaultFolder=pwd;
dafaultSave=0;
p=inputParser;
addOptional(p,'NWBdir',defaultFolder,@isstring)
addOptional(p,'save',dafaultSave)
parse(p,varargin{:})
NWBdir=p.Results.NWBdir;

nwbPathTemp=dir(fullfile(NWBdir, '*.nwb'));
if ~ismember('nwb',evalin('base','who')) %only does the next part of the code if nwb does not exist in the workspace
    %% get the NWB filename from existing vars    
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
%% get params
sp=loadParamsNWB_internal(NWBdir);
%% get the data for sp structure
sp.st = nwb.units.spike_times.data.load;

stind_temp=nwb.units.spike_times_index.loadAll;
stind=stind_temp.data;
id=nwb.units.id.data.load';
for chan=2:length(stind)
    spikeTemplates(stind(chan-1):stind(chan),1)=id(chan);
end
sp.spikeTemplates = spikeTemplates;

sp.clu = spikeTemplates;

step1=nwb.processing.values;
step2=step1{1, 1}.nwbdatainterface.values;
step3=step2{1, 1}.vectordata.values;
sp.tempScalingAmps = step3{1, 1}.data.load;

tempdata=values(nwb.units.vectordata);
sp.cgs = double(load(tempdata{1, 1}.data))';

sp.cids = double(nwb.units.id.data.load');

metadata=values(nwb.general_extracellular_ephys_electrodes.vectordata);
pos(:,1)=int32(metadata{6}.data.load);
pos(:,2)=int32(metadata{7}.data.load);
coords=double(pos);
sp.xcoords = coords(:,2);
sp.ycoords = coords(:,1);

temp=nwb.units.waveform_mean;
temp2= temp.data.load;
temp3 =permute(temp2, [3,2,1]);
% expanding the matrix to match bad units(?)
id=nwb.units.id.data.load+1;
sp.temps=zeros(max(id),size(temp3,2),size(temp3,3));
for units=1:length(id)
    sp.temps(id(units),:,:)=temp3(units,:,:);
end

sp.winv =pullfrommat('sp.winv'); %Where is the inverted mask?

sp.pcFeat = [];

sp.pcFeatInd = (1:1:size(sp.temps,1))'; %this is clearly not the indicies of PCs
%% trial_contrast
step1=nwb.intervals_trials.vectordata.values;
trial_contrast=step1{1, 1}.data.load;


%% posx
acquisition=nwb.acquisition.map.values;
position=acquisition{1, 2}.spatialseries.values;
posx=position{1, 2}.data.load;

%% trial
zero_idx=(posx==0);
beginnings=strfind(zero_idx',[0 1])+1;
beginnings=[1 beginnings length(zero_idx)];
for trialcount=1:length(beginnings)-1
    trial(beginnings(trialcount):beginnings(trialcount+1))=trialcount;
end
trial=trial';
%% trial_gain 
unit_gain=position{1, 1}.data.load./position{1, 2}.data.load;
[~,trial_switch_id]=unique(trial);
trial_gain=unit_gain(trial_switch_id);
trial_gain(isnan(trial_gain))=1;
%% post
post=((0:(length(posx)-1))*position{1, 1}.starting_time_rate)';
%% lickx
behEvents=acquisition{1, 1}.timeseries.values;
lickx=behEvents{1, 1}.data.load;
%% lickt
lickt=behEvents{1, 1}.timestamps.load;
if p.Results.save
    name=[nwbPathTemp.name(1:end-4) '.mat'];
    save(name,'sp','lickt','lickx','post','posx','trial','trial_contrast','trial_gain')
end
end

function sp = loadParamsNWB_internal(NWBdir)
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


metadata=values(nwb.general_extracellular_ephys_electrodes.vectordata);

sp.dat_path=''; %not sure if this fiels is used so assigning it as empty
sp.n_channels_dat=size(metadata{1, 2}.data,1);
sp.dtype='double'; %not sure whether data type really matters here so assigning it as double
sp.offset=0;
sp.sample_rate = 30000; %figureoutsamplerate; %can't find in nwb file, manually adding for now
if strcmp(metadata{1}.data.load(1),'The raw voltage signals from the electrodes were not high-pass filtered')
    sp.hp_filtered = false;
else
    sp.hp_filtered = true;
end
% S.gain=1;
end