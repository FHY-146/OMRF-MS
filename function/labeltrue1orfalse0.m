function labels = labeltrue1orfalse0(TestFlag,ClassLabels)
%Default use of 0 for misclassification, 1 for correct classification or 0 for true labelling
 
[row,col] = size(TestFlag);
labels = zeros(row,col);

idxfalse = (TestFlag~=ClassLabels) - (TestFlag==0);
labels(idxfalse==0) = 1;
