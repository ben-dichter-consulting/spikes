function out=pullfrommat(whattopull)
    if ~ismember('TheirMat',evalin('base','who'))
        TheirMat=load('npI5_0417_baseline_1.mat');
    else
        TheirMat = evalin('base', 'TheirMat');
    end
    
    out=eval(['TheirMat.' whattopull]);
end