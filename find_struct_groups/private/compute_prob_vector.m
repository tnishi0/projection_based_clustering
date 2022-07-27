function q = compute_prob_vector(data, is_auto)
% Computation of probability vector to be used to drive selection of random
% projections.
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

if nargin < 2, is_auto = false; end

% Maximum value for N
N = 5000;
% Prepare data
[p,n] = size(data);
if N > 0
    % Train q by using N random 1D projections
    % Choosing N based on an estimate of the probability of good 1D projection
    theta = pi/10; % angle of tolerance
    I_num_int = quad(@(y)sin(y).^(p-2), 0, theta);
    P_theory = 2*I_num_int.*(p-1)/sqrt(pi)./p.*gamma(p/2+1)./gamma((p-1)/2+1);
    N = min(ceil(1/P_theory),N); 
    if ~is_auto
        h_waitbar = waitbar(0, ...
            sprintf('Going through %d 1D projections...', N));
    end
    gap = nan(N,1);
    v = nan(p,N);
    for i = 1:N
        u = randn(p,1);
        u = u/norm(u);
        x = u'*data;
        x = sort(x);
        gap(i) = max((x(2:end)-x(1:end-1)).*(1:n-1).*(n-1:-1:1)/n^2);
        v(:,i) = u;
        if mod(i,N/20) == 0 && ~is_auto
            waitbar(i/N)
        end
    end
    mv = v.^2*gap;
    % Normalize the scores
    score = ((mv - min(mv))/(max(mv) - min(mv))).^2;
    q = score;
    clear x

    if ~is_auto, close(h_waitbar), end
else
    q = ones(p,1);
end
