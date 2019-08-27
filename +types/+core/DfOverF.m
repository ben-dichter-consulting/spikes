classdef DfOverF < types.core.NWBDataInterface
% DfOverF dF/F information about a region of interest (ROI). Storage hierarchy of dF/F should be the same as for segmentation (ie, same names for ROIs and for image planes).


% PROPERTIES
properties
    roiresponseseries; % RoiResponseSeries object containing dF/F for a ROI
end

methods
    function obj = DfOverF(varargin)
        % DFOVERF Constructor for DfOverF
        %     obj = DFOVERF(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        % roiresponseseries = RoiResponseSeries
        varargin = [{'help' 'Df/f over time of one or more ROIs. TimeSeries names should correspond to imaging plane names'} varargin];
        obj = obj@types.core.NWBDataInterface(varargin{:});
        [obj.roiresponseseries, ivarargin] = types.util.parseConstrained(obj,'roiresponseseries', 'types.core.RoiResponseSeries', varargin{:});
        varargin(ivarargin) = [];
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        parse(p, varargin{:});
        if strcmp(class(obj), 'types.core.DfOverF')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    function obj = set.roiresponseseries(obj, val)
        obj.roiresponseseries = obj.validate_roiresponseseries(val);
    end
    %% VALIDATORS
    
    function val = validate_roiresponseseries(obj, val)
        constrained = {'types.core.RoiResponseSeries'};
        types.util.checkSet('roiresponseseries', struct(), constrained, val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.roiresponseseries)
            refs = obj.roiresponseseries.export(fid, fullpath, refs);
        else
            error('Property `roiresponseseries` is required.');
        end
    end
end

end