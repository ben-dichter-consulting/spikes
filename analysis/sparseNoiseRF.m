

function [rfMap, stats] = sparseNoiseRF(spikeTimes, stimTimes, stimPositions, params)
% function [rfmap, stats] = sparseNoiseRF(spikeTimes, stimTimes, stimPositions, params)
%
% Assumes that stimPositions describe a rectangle and are evenly spaced.
%
% - spikeTimes is nSpikes x 1
% - stimTimes is nStimulusEvents x 1
% - stimPositions is nStimulusEvents x 2 (x and y coordinates)
%
% params can have: 
% - makePlots - logical
% - useSVD - logical, whether to compute the RF by using SVD on the PSTHs for all
% stimulus responses. If not, will just count spikes in a window. 
% - countWindow - 1x2, start and end time relative to stimulus onset to
% consider
% - binSize - 1x1, to use for making rasters
% - fit2Dgauss - logical, try to fit a 2D gaussian
%
% TODO
% - show some rasters of the peak and of an average site
% - implement statistical test(s)

% default parameters
p.makePlots = true; 
p.useSVD = true;
p.countWindow = [0 0.2];
p.binSize = 0.01;
p.fit2Dgauss = false;

fn = fieldnames(p);
for f = 1:length(fn)
    if isfield(params, fn{f}) && ~isempty(params.(fn{f}))
        p.(fn{f}) = params.(fn{f});
    end
end

[stimTimes, ii] = sort(stimTimes);
stimPositions = stimPositions(ii,:);

xPos = unique(stimPositions(:,1)); nX = length(xPos);
yPos = unique(stimPositions(:,2)); nY = length(yPos);

if p.useSVD
    timeBins = [p.countWindow(1):p.binSize:p.countWindow(2)];
    timeBins = timeBins(1:end-1)+p.binSize/2;
    nBins = length(timeBins);
    thisRF = zeros(nX, nY, nBins);
else
    thisRF = zeros(nX,nY);
end

% for x = 1:nX
%     for y = 1:nY
%         theseStims = stimPositions(:,1)==xPos(x) & stimPositions(:,2)==yPos(y);
% %         [psth, bins, rasterX, rasterY, spikeCounts] = psthRasterAndCounts(spikeTimes, stimTimes(theseStims), p.countWindow, p.binSize);
%         [psth, bins, rasterX, rasterY, spikeCounts, ba] = psthAndBA(spikeTimes, stimTimes(theseStims), p.countWindow, p.binSize);
%             
%         if p.useSVD
%             thisRF(x,y,:) = psth;
%         else
%             thisRF(x,y) = mean(spikeCounts);
%         end
%     end
% end
[psth, bins, rasterX, rasterY, spikeCounts, ba] = psthAndBA(spikeTimes, stimTimes, p.countWindow, p.binSize);

for x = 1:nX
    for y = 1:nY
        theseStims = stimPositions(:,1)==xPos(x) & stimPositions(:,2)==yPos(y);
        if p.useSVD
            thisRF(x,y,:) = mean(ba(theseStims,:));
        else
            thisRF(x,y) = mean(spikeCounts(theseStims));
        end
    end
end





if p.useSVD
    allPSTH = reshape(thisRF, nX*nY, size(thisRF,3));
    bsl = mean(allPSTH(:,1)); % take the first bin as the baseline
    [U,S,V] = svd(allPSTH - bsl,'econ');
    rfMapVec = U(:,1);
    rfMap = reshape(rfMapVec,nX, nY);
    timeCourse = V(:,1)';
    Scalar = S(1,1);
    Model = rfMapVec*timeCourse*Scalar + bsl;
    Residual = allPSTH - Model;
else
    rfMap = thisRF;
end


% statistical test(s)
% - shuffle test: idea is that if you relabel each stimulus event with a different
% position, on what proportion of relabelings do you get a peak as big as
% the one actually observed? or can calculate this analytically from the
% distribution of all spike counts.
% - simplest: just the z-score of the peak relative to the whole population
maxZ = (max(rfMap(:))-mean(rfMap(:)))./std(rfMap(:));
minZ = (min(rfMap(:))-mean(rfMap(:)))./std(rfMap(:));
stats.peakZscore = max(abs([minZ maxZ]));


if p.fit2Dgauss
    
    if abs(minZ)>maxZ
        % peak is negative - neuron is suppressed        
        useRF = -rfMap; 
    else
        useRF = rfMap;
    end
    useRF = useRF-quantile(useRF(:),0.25);
    
    x = fit2dGaussRF(yPos, xPos, useRF, false);
    stats.fit2D = x;
    
end







if p.makePlots
    
    
    figure; 
    
    
    if p.useSVD
        nCol = 2;
        
        subplot(3,nCol,2);
        plot(timeBins, timeCourse);
        xlim([timeBins(1) timeBins(end)]);
        title('response time course')
        xlabel('time')
        
        subplot(3,nCol,4);
        imagesc(1:size(allPSTH,1), timeBins,  allPSTH');
        title('all PSTHs, ordered');
        xlabel('space')
        ylabel('time')
        
        subplot(3,nCol,6); 
        imagesc(Residual');
        title('residual')
        xlabel('space')
        ylabel('time')
    else
        nCol = 1;
    end
    
    subplot(3,nCol,1);
    imagesc(rfMap);
    title(sprintf('map, peakZ = %.2f', stats.peakZscore));
    colormap hot
    
    if p.fit2Dgauss
        subplot(3,nCol,(nCol-1)*2+1)
        imagesc(rfMap);
        title('map with fit');
        colormap hot
        
        
        %subplot(3,nCol,(nCol-1)*3+1)
        t = 0:0.1:2*pi;
        xx = x(2)+x(3)*3*cos(t)*cos(x(6)) - x(5)*3*sin(t)*sin(x(6));
        yy = x(4)+x(3)*3*cos(t)*sin(x(6)) - x(5)*3*sin(t)*cos(x(6));
        
        hold on;
        plot(xx,yy,'g', 'LineWidth', 2.0);
    end
    
    
    
end

stats = [];