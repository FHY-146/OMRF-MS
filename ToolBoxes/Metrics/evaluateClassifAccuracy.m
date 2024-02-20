function State = evaluateClassifAccuracy(Ref, Test)
% EVALUATECLASSIFACCURACY calculates the classfication Accuracy
% input:
% Ref:              参考的标记图像（从1开始）
% Test：             获得的分类结果
% output:
% State.kappa:       kappa系数
% State.OverallAccuracy：整体精度
% State.MixMatrix 混合矩阵
TestFlag = Ref;%共六类
%测试样本个数
SampCount = numel(TestFlag(TestFlag ~= 0));

%混淆矩阵
Num_of_class = max(Ref(:));
MixMatrix = zeros(Num_of_class + 1);
for i=1:size(Ref,1)
    for j=1:size(Ref,2)
        u = Test(i,j);
        v = TestFlag(i,j);
        if (u~=0) &&(v~=0)
            %标记为u类，参考类别为v的像素样本个数
            MixMatrix(u,v) = MixMatrix(u,v)+1;
        end
    end
end

%总体精度
OverallAccuracy = sum(diag(MixMatrix)) / SampCount;

%Kappa系数
sumRowColumn = 0;
for i = 1:Num_of_class
    sumRowColumn =sumRowColumn + MixMatrix(i,1:end-1)*MixMatrix(1:end-1,i);
end
kappa = (SampCount*sum(diag(MixMatrix))-sumRowColumn)...
    /(SampCount.^2-sumRowColumn);

%用户精度和生产者精度
MixMatrix(end,:) =  (diag(MixMatrix))' ./ (sum(MixMatrix(1:end,1:end), 1));
MixMatrix(:,end) = diag(MixMatrix) ./  sum(MixMatrix(1:end,1:end), 2);
MixMatrix(end,end) = OverallAccuracy;

State.kappa = kappa;
State.OverallAccuracy = OverallAccuracy*100;
State.MixMatrix = MixMatrix;




