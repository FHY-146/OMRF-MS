function spectral_weights = FeatureDisCalculating(Img,labels,theta_spec)

[row,col,dim] = size(Img);
% ImgData = reshape(Img,row*col,dim);
rgnCount = max(labels(:));
SpectralMean = zeros(rgnCount,dim);

% for i = 1:rgnCount
%     SpectralMean(i,:) = mean(ImgData(labels==i,:));
% end

for i = 1:dim
    S = regionprops(labels,Img(:,:,i),"MeanIntensity");
    SpectralMean(:,i) = cell2mat(struct2cell(S(:)))';
end

spectral_weights = zeros(rgnCount,rgnCount);
for i = 1:dim
    spec_dis = pdist2(SpectralMean(:,i),SpectralMean(:,i),'mahalanobis');
    spectral_weights = spectral_weights+spec_dis;
end

spectral_weights = spectral_weights/3;
spectral_weights = exp(-1*(spectral_weights/(theta_spec^2)/2)) - diag(ones(1,rgnCount),0);
