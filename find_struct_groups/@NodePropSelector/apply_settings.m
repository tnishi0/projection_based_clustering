function ok = apply_settings(obj, src, event)

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

ok = true;
for i = 1:length(obj.checkbox)
    if get(obj.checkbox(i), 'value')
        
        % set to compute this property
        obj.np_functions(i).compute = true;
        
        % Set max neighbor level
        s = get(obj.neighbor_level_selector(i), 'string');
        max_nbr_level = str2num(s);
        if isempty(max_nbr_level)
            errordlg(sprintf(...
                'Error converting max_nbr_level for "%s"', ...
                obj.np_functions(i).name))
            ok = false;
            return
        end
        obj.np_functions(i).max_nbr_level = max_nbr_level;
        
        % set number of outputs
        s = get(obj.output_selector(i), 'string');
        num_outputs = str2num(s);
        if isempty(num_outputs)
            errordlg(sprintf(...
                'Error converting num_outputs for "%s"', ...
                obj.np_functions(i).name))
            ok = false;
            return
        end
        obj.np_functions(i).num_outputs = num_outputs;
    else
        % set NOT to compute this property
        obj.np_functions(i).compute = false;
    end
end

obj.compute_np = true;
close(obj.h_fig)
