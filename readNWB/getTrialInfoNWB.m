function getTrialInfoNWB
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
beginnings=[1 beginnings length(zero_idx)];
for trialcount=1:length(beginnings)-1
    trial(beginnings(trialcount):beginnings(trialcount+1))=trialcount;
end
%% post
post=[0:0.02:(length(posx)-1)*0.02]';
%% lickx
behEvents=acquisition{1, 1}.timeseries.values;
lickx=behEvents{1, 1}.data.load;
%% lickt
lickt=behEvents{1, 1}.timestamps.load;
end