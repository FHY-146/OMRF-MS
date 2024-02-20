function [stat,edges] = labels2edges_self(labels)

% count number of regions
N = double(max(labels(:)));

if size(labels,3) ~=1
    error('The labelling matrix must be one-dimensional')
end

% size of label matrix
dim = size(labels);

%Creating an adjacency matrix
stat=sparse(N,N);

%//Statistically calculates whether the label of the current point is 
% the same as the label of the right, lower, lower right, and lower left 
% to determine the region adjacency.

%---1.Calculate up and down changes
diff1 = abs(diff(double(labels), 1, 1)); 

%Non-zero elements imply a change in region
[rows_1,cols_1] = find(diff1);

% Indexes corresponding to the current position of the change 
% and neighbouring positions in the labels matrix
indx1_1 = sub2ind(dim, rows_1, cols_1);   %Converting subscripts to linear indexes
indx2_1 = sub2ind(dim, rows_1+1, cols_1);

%---2.Calculate the left-right change
diff2 = abs(diff(double(labels), 1, 2));

%Non-zero elements imply a change in region
[rows_2,cols_2] = find(diff2);

% Indexes corresponding to the current position of 
% the change and neighbouring positions in the labels matrix
indx1_2 = sub2ind(dim, rows_2, cols_2);
indx2_2 = sub2ind(dim, rows_2, cols_2+1);

%---3.Calculate the lower right diagonal change
diff3 =abs(labels(2:end,2:end)-labels(1:end-1,1:end-1));

%Non-zero elements imply a change in region
[rows_3,cols_3] = find(diff3);

% Indexes corresponding to the current position of the change and 
% neighbouring positions in the labels matrix
indx1_3 = sub2ind(dim, rows_3, cols_3);
indx2_3 = sub2ind(dim, rows_3+1, cols_3+1);

% %---Calculate the lower left diagonal change
diff4 =abs(labels(2:end,1:end-1)-labels(1:end-1,2:end));

%Non-zero elements imply a change in region
[rows_4,cols_4] = find(diff4);

% Indexes corresponding to the current position of the change and neighbouring 
% positions in the labels matrix
indx1_4 = sub2ind(dim, rows_4, cols_4+1);
indx2_4 = sub2ind(dim, rows_4+1, cols_4);

%% Statistical index
indx1=[indx1_1;indx1_2;indx1_3;indx1_4];
indx2=[indx2_1;indx2_2;indx2_3;indx2_4];
l1=labels(indx1);
l2=labels(indx2);

indx_a=[indx1;indx2];indx_b=[indx2;indx1];
%counting side
edges = unique([l1 l2], 'rows');
[~,ia,~] = unique([(indx_a) labels(indx_b)], 'rows');

%statistical matrix
num_1=numel(ia);
for i=1:num_1
    stat(labels(indx_a(ia(i))),labels(indx_b(ia(i))))=stat(labels(indx_a(ia(i))),labels(indx_b(ia(i))))+1;
end

edges = sortrows(sort(edges, 2));

% remove eventual double edges
edges = unique(edges, 'rows');
stat=floor(stat);
 
% 
% if nargout == 1
%     varargout{1} = edges;
% end
% 
% if nargout == 2
%     varargout{1} = floor(stat);
%     varargout{2} = edges;
% end

