function [time,out]=test_temp(nwb)

tic
matst=pullfrommat('sp.st'); %get first array
ourst=nwb.units.spike_times.data.load; %get second array
scalingAmps=pullfrommat('sp.tempScalingAmps'); %get actual data that i need to reorder based on 1st array/second array relationship

ourst(:,2)=1:length(ourst);
[~,rows]=sort(ourst(:,1));
ourstSORTED=ourst(rows,:);

matst(:,2)=1:length(matst);
[~,rows]=sort(matst(:,1));
matstSORTED=matst(rows,:);

combinedIDX=[ourstSORTED(:,2) matstSORTED(:,2)];

[~,rows]=sort(combinedIDX(:,1));
combinedIDX_sorted=combinedIDX(rows,:);

out=scalingAmps(combinedIDX_sorted(2,:));
time=toc;

end