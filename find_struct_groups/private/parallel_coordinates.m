function parallel_coordinates(network, n, h)
% Dras parallel coordinates plot.
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

np = network.np;
combined_grouping = network.combined_grouping;
p = size(np,1);

if nargin < 3, h = gca; end
axes(h), cla

if max(combined_grouping) == 1 || isempty(n)
    idx_focused = []; idx_others = 1:p;
else
    idx_focused = find(combined_grouping==n);
    idx_others = find(combined_grouping~=n);
end

color_focused = [1 0.4 0.4];
color_others = 0.7*[1 1 1];
plot(np(:, idx_others),'-o', ...
    'markersize', 4, ...
    'color', color_others, ...
    'markerfacecolor', color_others, ...
    'markeredgecolor', color_others)
hold on
plot(np(:, idx_focused),'-o', ...
    'markersize', 4, ...
    'color', color_focused, ...
    'markerfacecolor', color_focused, ...
    'markeredgecolor', color_focused)

% bars indicating mean
% mean_all = mean(np,2);
color_mean_others = 0.2*[1 1 1];
mean_others = mean(np(:,idx_others), 2);
plot(mean_others, '-', ...
    'linewidth', 2, ...
    'color', color_mean_others)
color_mean_focused = [1 0 0];
mean_focused = mean(np(:,idx_focused), 2);
plot(mean_focused, '-', ...
    'linewidth', 2, ...
    'color', color_mean_focused)
% errorbar(1:p, 0.5*ones(1,p), ...
%     mean_focused - mean_all, ...
%     mean_others - mean_all,...
%     'linestyle', 'none') 

% transparent patch to serve as clickable handles
del = 0.3;
for i = 1:p
    patch([i-del, i+del, i+del, i-del], [0,0,1,1], 'b', ...
        'facealpha', 0.2, 'edgecolor', 'none', ...
        'userdata', i, 'tag', 'coordinate')
end

hold off
set(gca, 'ytick', [])
set(gca, 'xlim', [0.5, max(size(np,1)+0.5, 30.5)])
