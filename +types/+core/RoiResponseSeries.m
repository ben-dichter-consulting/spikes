classdef RoiResponseSeries < types.core.TimeSeries
% RoiResponseSeries ROI responses over an imaging plane. Each row in data[] should correspond to the signal from one ROI.


% PROPERTIES
properties
    rois; % a dataset referencing into an ROITable containing information on the ROIs stored in this timeseries
end

methods
    function obj = RoiResponseSeries(varargin)
        % ROIRESPONSESERIES Constructor for RoiResponseSeries
        %     obj = ROIRESPONSESERIES(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        % rois = DynamicTableRegion
        varargin = [{'comments' 'no comments' 'data_conversion' types.util.correctType(1.0, 'float32') 'data_resolution' types.util.correctType(0.0, 'float32') 'description' 'no description' 'help' 'ROI responses over an imaging plane. Each element on the second dimension of data[] should correspond to the signal from one ROI'} varargin];
        obj = obj@types.core.TimeSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'rois',[]);
        parse(p, varargin{:});
        obj.rois = p.Results.rois;
        if strcmp(class(obj), 'types.core.RoiResponseSeries')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    function obj = set.rois(obj, val)
        obj.rois = obj.validate_rois(val);
    end
    %% VALIDATORS
    
    function val = validate_comments(obj, val)
        val = types.util.checkDtype('comments', 'char', val);
    end
    function val = validate_data(obj, val)
        val = types.util.checkDtype('data', 'numeric', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        else
            valsz = size(val);
        end
        validshapes = {[Inf], [Inf Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_data_conversion(obj, val)
        val = types.util.checkDtype('data_conversion', 'float32', val);
    end
    function val = validate_data_resolution(obj, val)
        val = types.util.checkDtype('data_resolution', 'float32', val);
    end
    function val = validate_data_unit(obj, val)
        val = types.util.checkDtype('data_unit', 'char', val);
    end
    function val = validate_description(obj, val)
        val = types.util.checkDtype('description', 'char', val);
    end
    function val = validate_rois(obj, val)
        val = types.util.checkDtype('rois', 'types.core.DynamicTableRegion', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.TimeSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.rois)
            refs = obj.rois.export(fid, [fullpath '/rois'], refs);
        else
            error('Property `rois` is required.');
        end
    end
end

end