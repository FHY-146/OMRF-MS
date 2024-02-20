clc
clear
close all
addpath(genpath('./function'));
addpath(genpath('./ToolBoxes'));
% dbstop error
%%     This code is used to experiment with MRF interactions on multiple scales
%      Code to build multi-semantic scale representations at regional granularity
%      Initial classifier is deep learning

%% Data loading
%% GID
load("./Data/GID/Data.mat");
Img = Data.Img;
[row,col,dim] = size(Img);
ImgData = reshape(Img,row*col,dim);
% [~,score,~,~] = pca(ImgData,'NumComponents',1);
% img = reshape(score,row,col,1);
% Img = imguidedfilter(Img,img); 
TestFlag = Data.TestFlag-1;
colorMap_GF = [255, 0, 0; 0, 255, 255; 0, 255, 0; 0, 0, 255];
probility2 = cell2mat(struct2cell(load('./Data/GID/cmtfnet_prob2.mat')));
                       
%% parameter setting
beta = 8; 
beta1 = 1;
beta2 = 200;
mra = 1000;

%% core algorithm
[ClassLabelMats,subclass] = OMRF_MS(Img,probility2,beta,beta1,beta2,mra);

% % low semantic transformations
ClassLabelMat_s1 = zeros(size(TestFlag));
num = 0;
for i = 1:length(subclass)
    for k = 1:subclass(i)
        ClassLabelMat_s1(ClassLabelMats(:,:,1)==k+num) = i;
    end
    num = num + subclass(i);
end
[row,col,dim] = size(Img);
[~,yini2] = max(probility2,[],2);
yini2 = reshape(yini2,row,col);

s0 = evaluateClassifAccuracy(TestFlag,yini2);
s1 = evaluateClassifAccuracy(TestFlag,ClassLabelMat_s1);
s2 = evaluateClassifAccuracy(TestFlag,ClassLabelMats(:,:,2));

% % Visualisation of classification results
figure,imshow(label2rgb(yini2)),title(['initial classification results:','OA = ',num2str(s0.OverallAccuracy)])
figure,imshow(label2rgb(ClassLabelMat_s1)),title(['low-semantic result:','OA = ',num2str(s1.OverallAccuracy)])
figure,imshow(label2rgb(ClassLabelMats(:,:,2))),title(['high-semantic result:','OA = ',num2str(s2.OverallAccuracy)])

