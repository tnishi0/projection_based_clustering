function proj_data = compute_projections(data, arg2, arg3)
% Computes random projections
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

is_auto = false;
if nargin < 2
%     cd('private')
    options = compute_projections_dialog;
%     cd('..')
else
    switch arg2
        case 'auto'
            options.use_q = 1;
            options.min_coord = 4;
            options.num_proj = 30;
            is_auto = true;
        case 'options'
            if nargin >= 3
                options = arg3;
            end
    end
end

num_proj = options.num_proj;

% compute probability vector based on 1D projections
if options.use_q
    options.q = compute_prob_vector(data, is_auto);
end

% Parameters: with probability r the projection plance is chosen to be
% parallel to one particular node property coordinate.  Node property i
% has probability q(i) chance to get selected.  q(i) is computed based on
% the maximum gap in the projection onto that coordinate.
q_np = q_node_prop(data);
r = 0;

if ~is_auto
    h_waitbar = waitbar(0, ...
        sprintf('Computing %d random projetions...', num_proj));
end
for n = 1:num_proj
    [u, v, xp, yp] = NewProjection(data, options, q_np, r);
    proj_data(n).u = u;
    proj_data(n).v = v;
    proj_data(n).xp = xp;
    proj_data(n).yp = yp;
    proj_data(n).grouping = [];
    if ~is_auto, waitbar(n/num_proj), end
end
if ~is_auto, close(h_waitbar), end

%--------------------------------------------------------------------------
function [u, v, xp, yp] = NewProjection(data, options, q_np, r)
% Random 2D projection: u,v are orthonormal set of two vectors spanning the
% 2D subspace on which the projection is made.

% With probability r, we choose projection plane to be parallel to the
% coordinate #9 (2nd Laplacian eigenvector) axis.

p = size(data,1);
if rand >= r
    p0 = p;    
    switch options.use_q
        case 1
            % Choose coordinates of p-dimensional space randomly according to the
            % probability vector q
            while 1
                idx = find(rand(p,1) <= options.q);
                if length(idx) >= options.min_coord % minimal number of coordinates to use
                    break
                end
            end
        case 0
            idx = 1:p;
    end

    data = data(idx, :);
    p = size(data,1);

    % Random Gaussian components
    u = randn(1,p);
    v = randn(1,p);

    % Make u and v orthonormal set
    u = u/norm(u);
    v = v/norm(v);
    v = v - (v*u')*u;
    v = v/norm(v);

    % Project onto plane spanned by u and v
    xp = u*data;
    yp = v*data;

    % make u & v vectors of the original dimensions
    u0 = u; v0 = v;
    u = zeros(1,p0); v = zeros(1,p0);
    u(idx) = u0; v(idx) = v0;

else
    % Random Gaussian components
    u = randn(1,p); u = u/norm(u);
    
    % choose node property i with probability q(i)
    rn = rand;
    s = q_np(1); i = 1;
    while s < rn
        i = i + 1;
        s = s + q_np(i);
    end
%     fprintf('Using node property #%d...\n', i)
    
    % Choose v to be orthogonal to u, and in the plane spanned by u and e9,
    % where e is the i-th coordinate axis.
    e = zeros(1,p); e(i) = 1;
    v = e - (e*u')*u;
    v = v/norm(v);
    
    % Project onto plane spanned by u and v
    xp = u*data;
    yp = v*data;

end

function q = q_node_prop(np)
% Computes the probability q(i) that node property i will be chosen

[p,n] = size(np);
for i = 1:p
    x = sort(np(i,:));
    max_gap(i) = max((x(2:end)-x(1:end-1)).*(1:n-1).*(n-1:-1:1)/n^2);
end
q = (max_gap/norm(max_gap)).^2;

