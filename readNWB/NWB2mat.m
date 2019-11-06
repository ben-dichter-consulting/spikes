function [sp,lickt,lickx,posx,post,trial,trial_contrast,trial_gain]=NWB2mat(varargin)
defaultFolder=pwd;
dafaultSave=0;
p=inputParser;
addOptional(p,'NWBdir',defaultFolder,@isstring)
addOptional(p,'save',dafaultSave)
parse(p,varargin{:})
NWBdir=p.Results.NWBdir;

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
sp.xcoords = coords(:,2)';
sp.ycoords = coords(:,1)';

temp=nwb.units.waveform_mean;
sp.temps = temp.data.load;

sp.winv = 1;

sp.pcFeat = [];

sp.pcFeatInd = nwb.units.id.data.load;
%% trial_contrast
step1=nwb.intervals_trials.vectordata.values;
trial_contrast=step1{1, 1}.data.load;

%% trial_gain FAKED NOW
trial_gain=ones(150,1);
%% posx
acquisition=nwb.acquisition.map.values;
position=acquisition{1, 2}.spatialseries.values;
posx=position{1, 2}.data.load;
%% trial
zero_idx=(posx==0);
beginnings=strfind(zero_idx',[0 1])+1;
for trialcount=1:length(beginnings)
    trial(1:beginnings(trialcount))=1;
end
%% post
post=1:0.02:length(posx);
%% lickx
behEvents=acquisition{1, 1}.timeseries.values;
lickx=behEvents{1, 1}.data.load;
%% lickt
lickt=behEvents{1, 1}.timestamps.load;
if p.Results.save
    name=nwbPathTemp.name;
    save(name,'sp','lickt','lickx','post','posx','trial','trial_contrast','trial_gain')
end
end