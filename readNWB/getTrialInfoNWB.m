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
end