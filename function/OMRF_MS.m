function varargout = OMRF_MS(Img,probility2,beta,beta1,beta2,mra)

[row,col,dim] = size(Img);
ImgData = reshape(Img,row*col,dim);
NumClass = size(probility2,2);

k2 = size(probility2,2);
[~,yini2] = max(probility2,[],2);
yini2 = reshape(yini2,row,col);

%% mean shift

if dim>3
    [~,score,~,~] = pca(ImgData,'NumComponents',3);
    Img = reshape(score,row,col,3);
    ImgData = three22(Img);
    dim = 3;
end
[~, labels] = edison_wrapper(Img, @RGB2Luv,'MinimumRegionArea',mra);

labels = double(labels+1);

Img = double(Img);

rgnCount = max(labels(:));

% Regional analysis
[statt, ~] = labels2edges_self(labels);

%Initialising a high semantic label graph
object_k2_img = zeros(row,col);
object_k2 = getRegionClass(yini2, labels);

S_idxlist = regionprops(labels,'PixelIdxList');
for i = 1:k2
    idx = cell2mat(struct2cell(S_idxlist(object_k2==i))');
    object_k2_img(idx) = i;
end

rgnData = zeros(rgnCount,dim);
for i = 1:dim
    S = regionprops(labels,Img(:,:,i),"MeanIntensity");
    rgnData(:,i) = cell2mat(struct2cell(S(:)))';
end

[subClass,GMMs] = CreateRgnSubclass(rgnData, object_k2, 6, 0.2, labels);

object_k1_img = rgnLabels2SubLabels(rgnData, labels, object_k2, subClass,GMMs);

%Create a hash-like index table
HashTable = HashTableCreating(NumClass,subClass); 

object_k1 = getRegionClass(object_k1_img, labels);
k1 = max(object_k1);

%interactive energy
E_ClassInter_k1 = E_ClassInterCalculating(object_k2,HashTable,2);
E_ClassInter_k2 = E_ClassInterCalculating(object_k1,HashTable,1);

%Calculation of inter-regional spectral heterogeneity
theta_spec = 4;
spectral_weights = FeatureDisCalculating(Img,labels,theta_spec);
region_weights = spectral_weights .* statt;

%Low-semantic feature field energy
mu_l2_k1 = zeros(k1, dim);

sigma_l2_k1 = zeros(dim,dim,k1);

E_object_k1 = zeros(row*col,k1);

for i = 1:k1
    Im_i_2_k1 = ImgData(object_k1_img == i,:);
    [I1, ~] = size(Im_i_2_k1);
    
    if I1 > 0
        [sigma_l2_k1(:,:,i),mu_l2_k1(i,:)] = covmatrix(Im_i_2_k1);
        
        mu_i_l2_k1 = mu_l2_k1(i,:);
        sigma_i_l2_k1 = sigma_l2_k1(:,:,i);
        
        diff_i_l2_k1 = ImgData - repmat(mu_i_l2_k1,[col*row,1]);
        E_object_k1(:,i) = sum(diff_i_l2_k1 /(sigma_i_l2_k1) .* diff_i_l2_k1, 2) + log(det(sigma_i_l2_k1));
    else
        E_object_k1(:,i) = 1/eps;
    end
end

E_ob_k1 = zeros(rgnCount,k1);
S_Area = regionprops(labels,"Area");
S_Area = cell2mat(struct2cell(S_Area(:)))';
for i = 1:k1
    S = regionprops(labels,reshape(E_object_k1(:,i),row,col),"MeanIntensity");
    E_ob_k1(:,i) = cell2mat(struct2cell(S(:)))'.*S_Area;
end

%High-semantic feature field energy
E_object_k2 = -log(probility2+eps);

E_ob_k2 = zeros(rgnCount,k2);
for i = 1:k2
    S = regionprops(labels,reshape(E_object_k2(:,i),row,col),"MeanIntensity");
    E_ob_k2(:,i) = cell2mat(struct2cell(S(:)))'.*S_Area;
end

% % model solution
tic
object_k1_img = LOMRF(E_ob_k1+beta2*E_ClassInter_k1, labels, statt, region_weights, beta);
toc

%High-semantic markup field energy
tic
object_k2_img = LOMRF(E_ob_k2+beta2*E_ClassInter_k2, labels, statt, region_weights, beta1);
toc

ClassLabelMats = cat(3,object_k1_img,object_k2_img);

varargout{1} = ClassLabelMats;
varargout{2} = subClass;











