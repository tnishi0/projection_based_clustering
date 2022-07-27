function np_functions = default_np_functions

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

np_functions = [  
    struct( ...
        'name', 'degree', ...
        'f_handle', @np_degree, ...
        'compute', true, ...
        'input', 'adj_list', ...
        'max_nbr_level', 1, ...
        'num_outputs', 1), ...
    struct( ...
        'name', 'clustering coefficient', ...
        'f_handle', @clustering_coefficients, ...
        'compute', true, ...
        'input', 'sparse', ...
        'max_nbr_level', 0, ...
        'num_outputs', 1), ...
    struct( ...
        'name', 'mean shortest path', ...
        'f_handle', @np_mean_shortest_path, ...
        'compute', true, ...
        'input', 'sparse', ...
        'max_nbr_level', 0, ...
        'num_outputs', 1), ...
    struct( ...
        'name', 'betweenness centrality', ...
        'f_handle', @betweenness_centrality, ...
        'compute', true, ...
        'input', 'sparse', ...
        'max_nbr_level', 1, ...
        'num_outputs', 1), ...
    struct( ...
        'name', 'subgraph centrality', ...
        'f_handle', @(A)np_subgraph_centrality(A), ...
        'compute', true, ...
        'input', 'sparse', ...
        'max_nbr_level', 1, ...
        'num_outputs', 1), ...
    struct( ...
        'name', 'Laplacian eigenvector', ...
        'f_handle', @(A)np_laplacian_eigenvector(A,10), ...
        'compute', true, ...
        'input', 'sparse', ...
        'max_nbr_level', 0, ...
        'num_outputs', 10), ...
    struct( ...
        'name', 'normalized Laplacian eignevector', ...
        'f_handle', @(A)np_normalized_laplacian_eigenvector(A,10), ...
        'compute', true, ...
        'input', 'sparse', ...
        'max_nbr_level', 0, ...
        'num_outputs', 10)
        ];
