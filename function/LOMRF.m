function f = LOMRF(E_ob, labels, statt, region_weights, beta)
[row,col,~] = size(labels);
rgnCount = max(labels(:));
NumClass = size(E_ob,2);

RegionWeights = region_weights * beta * 100;
% Hierweights = getHierarchicalWeights(E_ob,statt);
% RegionWeights = RegionWeights.*Hierweights;
%%Graph Cut
%Spectrum-based optimisation implemented by calling the GraphCut 3.0 toolkit
% Create new object with NumSites*NumLabels
h = GCO_Create(rgnCount,NumClass);

% Set Data Cost
Dc = (E_ob)'*10; % DC with NumLabels*NumSites
GCO_SetDataCost(h,Dc);

%Set Smooth Cost
Sc = ones(NumClass) - eye(NumClass);%Sc with NumLabels*NumLabels
% GCO_SetSmoothCost(h,100000*AniMat.*Sc);
GCO_SetSmoothCost(h,Sc);

%Set Neighbors
GCO_SetNeighbors(h,RegionWeights);

% Compute optimal labeling via alpha-expansion
% GCO_Expansion(h);
GCO_Swap(h);

%get labels
region_class = GCO_GetLabeling(h);
region_class = double(region_class);
f = zeros(row,col);
% for i = 1:rgnCount
%     f(labels==i) = region_class(i);
% end

S_idxlist = regionprops(labels,'PixelIdxList');
for i = 1:NumClass
    idx = cell2mat(struct2cell(S_idxlist(region_class==i))');
    f(idx) = i;
end

end
