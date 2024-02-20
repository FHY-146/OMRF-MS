function State = evaluateClassifAccuracy(Ref, Test)
% EVALUATECLASSIFACCURACY calculates the classfication Accuracy
% input:
% Ref:              �ο��ı��ͼ�񣨴�1��ʼ��
% Test��             ��õķ�����
% output:
% State.kappa:       kappaϵ��
% State.OverallAccuracy�����徫��
% State.MixMatrix ��Ͼ���
TestFlag = Ref;%������
%������������
SampCount = numel(TestFlag(TestFlag ~= 0));

%��������
Num_of_class = max(Ref(:));
MixMatrix = zeros(Num_of_class + 1);
for i=1:size(Ref,1)
    for j=1:size(Ref,2)
        u = Test(i,j);
        v = TestFlag(i,j);
        if (u~=0) &&(v~=0)
            %���Ϊu�࣬�ο����Ϊv��������������
            MixMatrix(u,v) = MixMatrix(u,v)+1;
        end
    end
end

%���徫��
OverallAccuracy = sum(diag(MixMatrix)) / SampCount;

%Kappaϵ��
sumRowColumn = 0;
for i = 1:Num_of_class
    sumRowColumn =sumRowColumn + MixMatrix(i,1:end-1)*MixMatrix(1:end-1,i);
end
kappa = (SampCount*sum(diag(MixMatrix))-sumRowColumn)...
    /(SampCount.^2-sumRowColumn);

%�û����Ⱥ������߾���
MixMatrix(end,:) =  (diag(MixMatrix))' ./ (sum(MixMatrix(1:end,1:end), 1));
MixMatrix(:,end) = diag(MixMatrix) ./  sum(MixMatrix(1:end,1:end), 2);
MixMatrix(end,end) = OverallAccuracy;

State.kappa = kappa;
State.OverallAccuracy = OverallAccuracy*100;
State.MixMatrix = MixMatrix;




