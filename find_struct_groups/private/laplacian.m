function L = laplacian(A, opt)
% Laplacian matrix of a network
%-------------------------------
%
% Usage:
%
%  L = laplacian(A)
%
% Parameters:
%
%  * *A* is the adjacency matrix of the network.

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

if nargin >= 2 && strcmp(opt, 'normalized')
    n = size(A,1);
    L = eye(n);
    for i = 1:size(A,1)
        idx = [1:i-1, i+1:n];
        L(i,idx) = - A(i,idx)/sum(A(i,:));
    end
else
    L = diag(sum(A,2)) - A;
end