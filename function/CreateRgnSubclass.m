function varargout = CreateRgnSubclass(rgnData, region_class, maxIte, Threshold, varargin)

% [row,col,dim] = size(Img);
% ImgData = reshape(Img,row*col,dim);
NumClass = max(region_class(:));

GMModels = cell(1,NumClass);
rgnSubclass = zeros(1,NumClass);
options = statset('MaxIter',1000);
for i = 1:NumClass
%     bic = zeros(1,maxIte);
    bic = [];
    Difference = [];
    GMModel = cell(1,maxIte);
%     options = statset('MaxIter',100);

    Data = rgnData(region_class==i,:);
    if isempty(Data)
        continue
    end
    [m,n] = size(Data);
    if m<=NumClass || m<=n
        rgnSubclass(i) = 1;
        continue
    end
    for k = 1:maxIte
        GMModel{k} = fitgmdist(Data,k,'RegularizationValue' ,0.1,'Options',options,'CovarianceType','full');
        bic= [bic,GMModel{k}.BIC];
        if k>=2
            firstdescend = bic(1)  - bic(2);
            difference = bic(k-1) - bic(k);
            Difference = [Difference,difference];
            if difference/firstdescend < Threshold || difference<=0
                bic(k) = [];
                break
            end
        end
    end
    
    [~,numComponents] = min(bic);
    rgnSubclass(i) = numComponents;
    GMModels{i} = GMModel{numComponents};
end

varargout{1} = rgnSubclass;
varargout{2} = GMModels;