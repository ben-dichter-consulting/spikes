classdef OptogeneticSeries < types.core.TimeSeries
% OptogeneticSeries Optogenetic stimulus.  The data[] field is in unit of watts.


% PROPERTIES
properties
    site; % link to OptogeneticStimulusSite group that describes the site to which this stimulus was applied
end

methods
    function obj = OptogeneticSeries(varargin)
        % OPTOGENETICSERIES Constructor for OptogeneticSeries
        %     obj = OPTOGENETICSERIES(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        % site = OptogeneticStimulusSite
        varargin = [{'comments' 'no comments' 'data_conversion' types.util.correctType(1.0, 'float32') 'data_resolution' types.util.correctType(0.0, 'float32') 'data_unit' 'watt' 'description' 'no description' 'help' 'Optogenetic stimulus'} varargin];
        obj = obj@types.core.TimeSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'site',[]);
        parse(p, varargin{:});
        obj.site = p.Results.site;
        if strcmp(class(obj), 'types.core.OptogeneticSeries')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    function obj = set.site(obj, val)
        obj.site = obj.validate_site(val);
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
        validshapes = {[Inf]};
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
    function val = validate_site(obj, val)
        val = types.util.checkDtype('site', 'types.core.OptogeneticStimulusSite', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.TimeSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.site)
            refs = obj.site.export(fid, [fullpath '/site'], refs);
        else
            error('Property `site` is required.');
        end
    end
end

end