function D = hamming_distances(P)
% Computes the (symmetric) matrix D of hamming distances between patterns
% in the columns of the matrix P. 
%
%   D = hamming_distances(P)

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

[dim, num_points] = size(P);
D = zeros(num_points);
for i = 1:num_points
    for j = i+1:num_points
        D(i,j) = length(find(P(:,i) ~= P(:,j)));
        D(j,i) = D(i,j);
    end
end
