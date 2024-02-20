function labels_img = rgnLabels2SubLabels(rgnData, labels, region_class, subclass,GMs)

[row,col,~] = size(labels);
labels_img = zeros(row,col);

num = 0;
E_subclass = zeros(length(region_class),sum(subclass));
% options = statset('MaxIter',1000);
for i = unique(region_class)'
    gm = GMs{i};
    mu = gm.mu;
    sigma = gm.Sigma;
    
    for k = 1:subclass(i)
        Im_i_2 = rgnData(region_class==i,:);
        [I1, ~] = size(Im_i_2);
        if I1 > 0
            sigma_2 = sigma(:,:,k);
            mu_2 = mu(k,:);
            diff_i_2 = rgnData - repmat(mu_2,[length(region_class),1]);
            E_subclass(:,k+num) = sum(diff_i_2 /(sigma_2) .* diff_i_2, 2) + log(det(sigma_2));
        else
            E_subclass(:,k+num) = 1/eps;
        end
    end
    num = num + subclass(i);
end

[~,sublabel] = min(E_subclass,[],2);
% for j = 1:length(sublabel)
%     labels_img(labels==j) = sublabel(j);
% end
NumClass = max(sublabel(:));
S_idxlist = regionprops(labels,'PixelIdxList');
for i = 1:NumClass
    idx = cell2mat(struct2cell(S_idxlist(sublabel==i))');
    labels_img(idx) = i;
end