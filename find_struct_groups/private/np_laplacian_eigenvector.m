function [np, prop_name] = np_laplacian_eigenvector(A,m)
% Non-trivial Laplacian eigenvectors
% m = number of non-trivial eigenvectors (must be < n)

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

n = size(A,1);
if m >= n
    error('The number of non-trivial eigenvectors m must be < n.')
end
np = nan(n,m);
[V,D] = eig(full(laplacian(A)));
np(:,1:m) = V(:,2:m+1);
for i = 1:m
    prop_name{i} = sprintf('#%03d',i);
end
