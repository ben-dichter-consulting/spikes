classdef OpticalSeries < types.core.ImageSeries
% OpticalSeries Image data that is presented or recorded. A stimulus template movie will be stored only as an image. When the image is presented as stimulus, additional data is required, such as field of view (eg, how much of the visual field the image covers, or how what is the area of the target being imaged). If the OpticalSeries represents acquired imaging data, orientation is also important.


% PROPERTIES
properties
    distance; % Distance from camera/monitor to target/eye.
    field_of_view; % Width, height and depth of image, or imaged area (meters).
    orientation; % Description of image relative to some reference frame (e.g., which way is up). Must also specify frame of reference.
end

methods
    function obj = OpticalSeries(varargin)
        % OPTICALSERIES Constructor for OpticalSeries
        %     obj = OPTICALSERIES(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        % distance = float32
        % field_of_view = float32
        % orientation = char
        varargin = [{'comments' 'no comments' 'description' 'no description' 'help' 'Time-series image stack for optical recording or stimulus'} varargin];
        obj = obj@types.core.ImageSeries(varargin{:});
        
        
        p = inputParser;
        p.KeepUnmatched = true;
        p.PartialMatching = false;
        p.StructExpand = false;
        addParameter(p, 'distance',[]);
        addParameter(p, 'field_of_view',[]);
        addParameter(p, 'orientation',[]);
        parse(p, varargin{:});
        obj.distance = p.Results.distance;
        obj.field_of_view = p.Results.field_of_view;
        obj.orientation = p.Results.orientation;
        if strcmp(class(obj), 'types.core.OpticalSeries')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    function obj = set.distance(obj, val)
        obj.distance = obj.validate_distance(val);
    end
    function obj = set.field_of_view(obj, val)
        obj.field_of_view = obj.validate_field_of_view(val);
    end
    function obj = set.orientation(obj, val)
        obj.orientation = obj.validate_orientation(val);
    end
    %% VALIDATORS
    
    function val = validate_comments(obj, val)
        val = types.util.checkDtype('comments', 'char', val);
    end
    function val = validate_description(obj, val)
        val = types.util.checkDtype('description', 'char', val);
    end
    function val = validate_distance(obj, val)
        val = types.util.checkDtype('distance', 'float32', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        else
            valsz = size(val);
        end
        validshapes = {[1]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_field_of_view(obj, val)
        val = types.util.checkDtype('field_of_view', 'float32', val);
        if isa(val, 'types.untyped.DataStub')
            valsz = val.dims;
        else
            valsz = size(val);
        end
        validshapes = {[2], [3]};
        types.util.checkDims(valsz, validshapes);
    end
    function val = validate_orientation(obj, val)
        val = types.util.checkDtype('orientation', 'char', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.ImageSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
        if ~isempty(obj.distance)
            if startsWith(class(obj.distance), 'types.untyped.')
                refs = obj.distance.export(fid, [fullpath '/distance'], refs);
            elseif ~isempty(obj.distance)
                io.writeDataset(fid, [fullpath '/distance'], class(obj.distance), obj.distance, false);
            end
        end
        if ~isempty(obj.field_of_view)
            if startsWith(class(obj.field_of_view), 'types.untyped.')
                refs = obj.field_of_view.export(fid, [fullpath '/field_of_view'], refs);
            elseif ~isempty(obj.field_of_view)
                io.writeDataset(fid, [fullpath '/field_of_view'], class(obj.field_of_view), obj.field_of_view, true);
            end
        end
        if ~isempty(obj.orientation)
            if startsWith(class(obj.orientation), 'types.untyped.')
                refs = obj.orientation.export(fid, [fullpath '/orientation'], refs);
            elseif ~isempty(obj.orientation)
                io.writeDataset(fid, [fullpath '/orientation'], class(obj.orientation), obj.orientation, false);
            end
        end
    end
end

end