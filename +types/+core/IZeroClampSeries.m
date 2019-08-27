classdef IZeroClampSeries < types.core.CurrentClampSeries
% IZeroClampSeries Stores recorded voltage data from intracellular recordings when all current and amplifier settings are off (i.e., CurrentClampSeries fields will be zero). There is no CurrentClampStimulusSeries associated with an IZero series because the amplifier is disconnected and no stimulus can reach the cell.



methods
    function obj = IZeroClampSeries(varargin)
        % IZEROCLAMPSERIES Constructor for IZeroClampSeries
        %     obj = IZEROCLAMPSERIES(parentname1,parentvalue1,..,parentvalueN,parentargN,name1,value1,...,nameN,valueN)
        varargin = [{'comments' 'no comments' 'description' 'no description' 'help' 'Voltage from intracellular recordings when all current and amplifier settings are off'} varargin];
        obj = obj@types.core.CurrentClampSeries(varargin{:});
        if strcmp(class(obj), 'types.core.IZeroClampSeries')
            types.util.checkUnset(obj, unique(varargin(1:2:end)));
        end
    end
    %% SETTERS
    
    %% VALIDATORS
    
    function val = validate_comments(obj, val)
        val = types.util.checkDtype('comments', 'char', val);
    end
    function val = validate_description(obj, val)
        val = types.util.checkDtype('description', 'char', val);
    end
    function val = validate_stimulus_description(obj, val)
        val = types.util.checkDtype('stimulus_description', 'char', val);
    end
    function val = validate_sweep_number(obj, val)
        val = types.util.checkDtype('sweep_number', 'uint64', val);
    end
    %% EXPORT
    function refs = export(obj, fid, fullpath, refs)
        refs = export@types.core.CurrentClampSeries(obj, fid, fullpath, refs);
        if any(strcmp(refs, fullpath))
            return;
        end
    end
end

end