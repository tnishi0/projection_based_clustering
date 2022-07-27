function [np, prop_name, np0] = node_prop(A, np_functions, verbose)
% The node property function should return a column vector (or a matrix
% with columns representing different properties).  

% If verbose = 2, then do not pop up a status window.
% If verbose = 3, then no pop up window or command window print
% out (completely silent).

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

tic

np = [];
prop_name = {};
n = size(A,1);

% build adjacency list
adj_list = cell(1,n);
[row col] = find(A);
for i = 1:length(row)
    if row(i) ~= col(i)
        adj_list{row(i)} = [[adj_list{row(i)}], col(i)];
    end
end

if verbose ~= 2 && verbose ~= 3
    h_waitbar = waitbar(0, 'Computing node properties...');
end

% Compute each node property function
for i = 1:length(np_functions)
    if ~np_functions(i).compute, continue, end
    t0 = toc;
    if verbose && verbose ~= 3, fprintf('Computing "%s" ...\n', np_functions(i).name), end
    if verbose ~= 2  && verbose ~= 3
        waitbar((i-1)/length(np_functions), h_waitbar, ...
            sprintf('Computing "%s" ...', np_functions(i).name))
    end
    
    if np_functions(i).num_outputs == 1
        switch np_functions(i).input
            case 'sparse'
                this_np = np_functions(i).f_handle(A);
            case 'adj_list'
                this_np = np_functions(i).f_handle(adj_list);
            otherwise
                error('The 3rd column of np_functions must be either ''sparse'' or ''adj_list''')
        end
        prop_name = {prop_name{:}, np_functions(i).name};
    else
        switch np_functions(i).input
            case 'sparse'
                [this_np, this_prop_name] = np_functions(i).f_handle(A);
            case 'adj_list'
                [this_np, this_prop_name] = np_functions(i).f_handle(adj_list);
            otherwise
                error('The 3rd column of np_functions must be either ''sparse'' or ''adj_list''')
        end
        for j = 1:length(this_prop_name)
            this_prop_name{j} = [np_functions(i).name,' ',this_prop_name{j}];
        end
        prop_name = {prop_name{:}, this_prop_name{:}};
    end
    
    np = [np, this_np];
    
    % Compute average of the property over neighbors
    for j = 1:np_functions(i).max_nbr_level
        if verbose && verbose ~= 3, fprintf(' Neighbor average at level %d ... ', j), end
        t1 = toc;
        np_next_neighbor = nan(n, np_functions(i).num_outputs);
        for k = 1:n
            np_next_neighbor(k,:) ...
                = mean(np(adj_list{k}, ...
                (end - np_functions(i).num_outputs + 1):end), 1);
        end
        np = [np, np_next_neighbor];
        
        if np_functions(i).num_outputs == 1
            prop_name = {prop_name{:},...
                sprintf('%s, average at level %d neighbors', np_functions(i).name, j)};
        else
            this_prop_name = {};
            for k = 1:np_functions(i).num_outputs
                this_prop_name = {this_prop_name{:}, ...
                    sprintf('%s, average at level %d neighbors', ...
                    prop_name{end - j*np_functions(i).num_outputs + k}, j)};
            end
            prop_name = {prop_name{:}, this_prop_name{:}};
        end
        
        if verbose ~= 2 && verbose ~= 3
            waitbar(i/length(np_functions))
        end
        if verbose && verbose ~= 3, fprintf('Done in %f sec\n', toc - t1), end
    end
       
    if verbose && verbose ~= 3, fprintf(' Done in %f sec\n', toc - t0), end
end

% Make columns correspond to nodes, to match required input for projdiv
np = np';
    
% Save non-normalized data
np0 = np; 

% Normalize each property to the interval [0,1]
for i = 1:size(np,1)
    pmin = min(np(i,:));
    pmax = max(np(i,:));
    if pmax > pmin
        np(i,:) = (np(i,:)-pmin)/(pmax-pmin);
    else
        np(i,:) = np(i,:) - pmin + 0.5;
    end
end

if verbose && verbose ~= 3, toc, end

if verbose ~= 2 && verbose ~= 3, close(h_waitbar), end

