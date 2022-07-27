function G = lda_qr(A,group,gam)
%
% Computing 2D projection using LDA/QR-regGSVD algorithm 
%
%    G = lda_qr(A,group,gam)
%
% will compute a N x 2 projection matrix G that makes 
%
%      across-group variance
%     -----------------------
%      within-group variance
%
% in the projection as large as possible.
% 
% A      : m x n data matrix
% group  : vector of group indices, 1,2,...,k
% gam > 0: regularization parameter
%
% The regularization parameter is the gamma in the paper, and is used in
% the case of undersampled problem, but ignored for oversampled problems.
% Default: gam = 1e-6.
%
% This is Algorithm 3 & 4 in H. Park, B. Drake, S. Lee, and C. Park, Fast
% linear discriminant analysis using QR decomposition and regularization,
% Georgia Institute of Technology, GA, Tech. Rep. GT-CSE-07-21, 2007.

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

[m,N] = size(A);
I = eye(N);
if nargin < 3, gam = 1e-6; end
            
% Compute n_i
k = max(group);
n = zeros(1,k);
for i = 1:length(group)
    n(group(i)) = n(group(i)) + 1;
end

% Re-index groups, removing empty groups
ix = 1:k;
ix(n==0) = [];
n = n(ix);
for i = 1:length(ix)
    group(group==ix(i)) = i;
end
k = max(group);

% Compute centroids
gc = zeros(m,k); % group centroids
A_group = cell(1,k);
for i = 1:k
    A_group{i} = A(:,group==i);
    gc(:,i) = mean(A_group{i},2);
end
c = mean(A,2); % global centroid

% Reorder columns so that they are partitioned according the grouping.
[gr_sorted,ix] = sort(group,'ascend');
A = A(:,ix);

% Oversampled or undersampled problem?
if m < N
    G = lda_qr_over;
else
    G = lda_qr_under;
end

    %--------------------------------------------------------------
    % Algorithm 3 in the paper for undersampled problems.
    function G = lda_qr_under
    
        % Check validity of gamma
        if gam <= 0, error('3rd argument gam must be positive'), end

        % 1) Compute the reduced QRD of A
        [Q,R] = qr(A);
        Q1 = Q(:,1:N);

        % 2) Compute Hb and Hw from R
        gc_hat = Q1'*gc; c_hat = Q1'*c;
        H_b = (ones(N,1)*sqrt(n)).*(gc_hat - c_hat*ones(1,k));
        for i = 1:k
            R_group{i} = Q1'*A_group{i};
            H_w_group{i} = R_group{i} - gc_hat(:,i)*ones(1,n(i));
        end
        H_w = [H_w_group{:}];

        % 3) Compute the reduced QRD of K_gam
        K_gam = [H_b'; H_w'; sqrt(gam)*I];
        [P_gam, R_gam] = qr(K_gam);

        % 4) Compute W_gam from SVD of P_gam(1:k,1:N)
        [U_gam,S_gam,W_gam] = svd(P_gam(1:k,1:N));

        % 5) Solve the triangular system R_gam*G_gam = W_gam(:,1:(k-1)) for G_gam
        G_gam = R_gam(1:N,:) \ W_gam(:,1:2);

        % 6)
        G = Q1*G_gam;
    
    end

    %--------------------------------------------------------------
    % Algorithm 4 in the paper for oversampled problems.
    function G = lda_qr_over
    
        % 1) Compute Hb and Hw from A
        H_b = (ones(m,1)*sqrt(n)).*(gc - c*ones(1,k));
        for i = 1:k
            H_w_group{i} = A_group{i} - gc(:,i)*ones(1,n(i));
        end
        H_w = [H_w_group{:}];
        
        % 2) Compute S_w and its Cholesky decomposition
        S_w = H_w*H_w'; 
        
        % This is to make sure that S_w is positive definite in the
        % presence of the numerical error.  Otherwise chol(S_w) below can
        % give error. 09/26/2010
        eps = 1e-8;
        S_w = S_w + 2*eps*eye(size(S_w));
        
        C_w = chol(S_w);
        
        % 3) Compute the reduced QR decomposition of K
        K = [H_b'; C_w];
        [P,F] = qr(K);
        
        % 4) Compute W from the SVD of P(1:k,1:m)
        [U,Sig,W] = svd(P(1:k,1:m));
        
        % 5) 
        G = F(1:m,:) \ W(:,1:2);
        
    end
end



