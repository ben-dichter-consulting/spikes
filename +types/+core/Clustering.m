classdef Clustering < types.core.NWBDataInterface
% Clustering DEPRECATED Clustered spike data, whether from automatic clustering tools (e.g., klustakwik) or as a result of manual sorting.


% PROPERTIES
properties
    description; % Description of clusters or clustering, (e.g. cluster 0 is noise, clusters curated using Klusters, etc)
    num; % Cluster number of each event
    peak_over_rms; % Maximum ratio of waveform peak to RMS on any channel in the cluster (provides a basic clustering metric).
    times; % Times of clustered events, in seconds. This may be a link to times field in associated FeatureExtraction module.
end

methods
    function obj = Clustering(varargin)
        % CLUSTERING Constructor for Clustering
        %     obj = CLUSTERING(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        % description = char
        % num = int32
        % peak_over_rms = float32
        % times = float64
        varargin = [{'help' 'DEPRECATED Clustered spike data, whether from automatic clustering tools (eg, klustakwik) or as a result of manual sorting'} varargin];
        obj = obj@types.core.NWBDataInterface(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'description',[]);
        addParameter(p, 'num',[]);
        addParameter(p, 'peak_over_rms',[]);
        addParameter(p, 'times',[]);
        parse(p, varargin{:});
        obj.description = p.Results.description;
        obj.num = p.Results.num;
        obj.peak_over_rms = p.Results.peak_over_rms;
        obj.times = p.Results.times;
        if strcmp(class(obj), 'types.core.Clustering')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    function obj = set.description(obj, val)
        obj.description = obj.validate_description(val);
    end
    function obj = set.num(obj, val)
        obj.num = obj.validate_num(val);
    end
    function obj = set.peak_over_rms(obj, val)
        obj.peak_over_rms = obj.validate_peak_over_rms(val);
    end
    function obj = set.times(obj, val)
        obj.times = obj.validate_times(val);
    end
    %% VALIDATORS
    
    function val = validate_description(obj, val)
        val = types.util.checkDtype('description', 'char', val);
    end
    function val = validate_num(obj, val)
        val = types.util.checkDtype('num', 'int32', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        else
            valsz = size(val);
        end
        validshapes = {[Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_peak_over_rms(obj, val)
        val = types.util.checkDtype('peak_over_rms', 'float32', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        else
            valsz = size(val);
        end
        validshapes = {[Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_times(obj, val)
        val = types.util.checkDtype('times', 'float64', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        else
            valsz = size(val);
        end
        validshapes = {[Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.description)
            if startsWith(class(obj.description), 'types.untyped.')
                refs = obj.description.export(fid, [fullpath '/description'], refs);
            elseif ~isempty(obj.description)
                io.writeDataset(fid, [fullpath '/description'], class(obj.description), obj.description, false);
            end
        else
            error('Property `description` is required.');
        end
        if ~isempty(obj.num)
            if startsWith(class(obj.num), 'types.untyped.')
                refs = obj.num.export(fid, [fullpath '/num'], refs);
            elseif ~isempty(obj.num)
                io.writeDataset(fid, [fullpath '/num'], class(obj.num), obj.num, true);
            end
        else
            error('Property `num` is required.');
        end
        if ~isempty(obj.peak_over_rms)
            if startsWith(class(obj.peak_over_rms), 'types.untyped.')
                refs = obj.peak_over_rms.export(fid, [fullpath '/peak_over_rms'], refs);
            elseif ~isempty(obj.peak_over_rms)
                io.writeDataset(fid, [fullpath '/peak_over_rms'], class(obj.peak_over_rms), obj.peak_over_rms, true);
            end
        else
            error('Property `peak_over_rms` is required.');
        end
        if ~isempty(obj.times)
            if startsWith(class(obj.times), 'types.untyped.')
                refs = obj.times.export(fid, [fullpath '/times'], refs);
            elseif ~isempty(obj.times)
                io.writeDataset(fid, [fullpath '/times'], class(obj.times), obj.times, true);
            end
        else
            error('Property `times` is required.');
        end
    end
end

end