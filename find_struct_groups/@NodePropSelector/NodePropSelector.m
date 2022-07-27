classdef NodePropSelector < handle

%
% Copyright (C) 2011  Takashi Nishikawa
% 
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307,
% USA. 

    properties
        h_fig
        checkbox
        neighbor_level_selector
        output_selector
        np_functions
        compute_np
    end
        
    methods
        
        function obj = NodePropSelector(np_functions)
            obj.create_gui(np_functions)
            obj.np_functions = np_functions;
        end
        
        function close_button_callback(obj, src, event)
            obj.compute_np = false;
            close(obj.h_fig)
        end
        
        function delete(obj)
            if ishandle(obj.h_fig)
                delete(obj.h_fig)
            end
        end
    end
end

