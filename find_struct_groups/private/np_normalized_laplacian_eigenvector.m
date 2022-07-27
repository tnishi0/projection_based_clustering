function [np, prop_name] = np_normalized_laplacian_eigenvector(A,m)
% Normalized Laplacian eignevector

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

% number of eigenvectors
if m > size(A,1)
    error('The number of non-trivial eigenvectors m must be <= n.')
end
[V,D] = eig(full(laplacian(A, 'normalized')));
[c,i] = sort(diag(D), 'descend');
np = V(:,i(1:m));
for i = 1:m
    prop_name{i} = sprintf('#%03d',i);
end
