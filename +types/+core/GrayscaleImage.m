classdef GrayscaleImage < types.core.Image
% GrayscaleImage Grayscale image



methods
    function obj = GrayscaleImage(varargin)
        % GRAYSCALEIMAGE Constructor for GrayscaleImage
        %     obj = GRAYSCALEIMAGE(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        obj = obj@types.core.Image(varargin{:});
        if strcmp(class(obj), 'types.core.GrayscaleImage')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    
    %% VALIDATORS
    
    function val = validate_data(obj, val)
    end
    function val = validate_description(obj, val)
        val = types.util.checkDtype('description', 'char', val);
    end
    function val = validate_help(obj, val)
        val = types.util.checkDtype('help', 'char', val);
    end
    function val = validate_resolution(obj, val)
        val = types.util.checkDtype('resolution', 'float', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.Image(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end