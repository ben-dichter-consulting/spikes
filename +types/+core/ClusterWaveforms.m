classdef ClusterWaveforms < types.core.NWBDataInterface
% ClusterWaveforms DEPRECATED The mean waveform shape, including standard deviation, of the different clusters. Ideally, the waveform analysis should be performed on data that is only high-pass filtered. This is a separate module because it is expected to require updating. For example, IMEC probes may require different storage requirements to store/display mean waveforms, requiring a new interface or an extension of this one.


% PROPERTIES
properties
    clustering_interface; % HDF5 link to Clustering interface that was the source of the clustered data
    waveform_filtering; % Filtering applied to data before generating mean/sd
    waveform_mean; % The mean waveform for each cluster, using the same indices for each wave as cluster numbers in the associated Clustering module (i.e, cluster 3 is in array slot [3]). Waveforms corresponding to gaps in cluster sequence should be empty (e.g., zero- filled)
    waveform_sd; % Stdev of waveforms for each cluster, using the same indices as in mean
end

methods
    function obj = ClusterWaveforms(varargin)
        % CLUSTERWAVEFORMS Constructor for ClusterWaveforms
        %     obj = CLUSTERWAVEFORMS(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        % clustering_interface = Clustering
        % waveform_filtering = char
        % waveform_mean = float32
        % waveform_sd = float32
        varargin = [{'help' 'DEPRECATED Mean waveform shape of clusters. Waveforms should be high-pass filtered (ie, not the same bandpass filter used waveform analysis and clustering)'} varargin];
        obj = obj@types.core.NWBDataInterface(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'clustering_interface',[]);
        addParameter(p, 'waveform_filtering',[]);
        addParameter(p, 'waveform_mean',[]);
        addParameter(p, 'waveform_sd',[]);
        parse(p, varargin{:});
        obj.clustering_interface = p.Results.clustering_interface;
        obj.waveform_filtering = p.Results.waveform_filtering;
        obj.waveform_mean = p.Results.waveform_mean;
        obj.waveform_sd = p.Results.waveform_sd;
        if strcmp(class(obj), 'types.core.ClusterWaveforms')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    function obj = set.clustering_interface(obj, val)
        obj.clustering_interface = obj.validate_clustering_interface(val);
    end
    function obj = set.waveform_filtering(obj, val)
        obj.waveform_filtering = obj.validate_waveform_filtering(val);
    end
    function obj = set.waveform_mean(obj, val)
        obj.waveform_mean = obj.validate_waveform_mean(val);
    end
    function obj = set.waveform_sd(obj, val)
        obj.waveform_sd = obj.validate_waveform_sd(val);
    end
    %% VALIDATORS
    
    function val = validate_clustering_interface(obj, val)
        val = types.util.checkDtype('clustering_interface', 'types.core.Clustering', val);
    end
    function val = validate_waveform_filtering(obj, val)
        val = types.util.checkDtype('waveform_filtering', 'char', val);
    end
    function val = validate_waveform_mean(obj, val)
        val = types.util.checkDtype('waveform_mean', 'float32', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        else
            valsz = size(val);
        end
        validshapes = {[Inf Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_waveform_sd(obj, val)
        val = types.util.checkDtype('waveform_sd', 'float32', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        else
            valsz = size(val);
        end
        validshapes = {[Inf Inf]};
        types.util.checkDims(valsz, validshapes);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.NWBDataInterface(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.clustering_interface)
            refs = obj.clustering_interface.export(fid, [fullpath '/clustering_interface'], refs);
        else
            error('Property `clustering_interface` is required.');
        end
        if ~isempty(obj.waveform_filtering)
            if startsWith(class(obj.waveform_filtering), 'types.untyped.')
                refs = obj.waveform_filtering.export(fid, [fullpath '/waveform_filtering'], refs);
            elseif ~isempty(obj.waveform_filtering)
                io.writeDataset(fid, [fullpath '/waveform_filtering'], class(obj.waveform_filtering), obj.waveform_filtering, false);
            end
        else
            error('Property `waveform_filtering` is required.');
        end
        if ~isempty(obj.waveform_mean)
            if startsWith(class(obj.waveform_mean), 'types.untyped.')
                refs = obj.waveform_mean.export(fid, [fullpath '/waveform_mean'], refs);
            elseif ~isempty(obj.waveform_mean)
                io.writeDataset(fid, [fullpath '/waveform_mean'], class(obj.waveform_mean), obj.waveform_mean, true);
            end
        else
            error('Property `waveform_mean` is required.');
        end
        if ~isempty(obj.waveform_sd)
            if startsWith(class(obj.waveform_sd), 'types.untyped.')
                refs = obj.waveform_sd.export(fid, [fullpath '/waveform_sd'], refs);
            elseif ~isempty(obj.waveform_sd)
                io.writeDataset(fid, [fullpath '/waveform_sd'], class(obj.waveform_sd), obj.waveform_sd, true);
            end
        else
            error('Property `waveform_sd` is required.');
        end
    end
end

end