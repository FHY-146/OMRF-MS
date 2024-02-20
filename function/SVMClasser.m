function  [ClassSVM, probalities] = SVMClasser(Img, TestFlag, NumSamples, varargin)    
    % Img = double(imread(['.\DataSet\ISPRS_Vaihingen\',SceneName]));
    [row,col, dim] = size(Img);
    imgData = reshape(Img,[row*col,dim]);
       
    % 50/100 of each class in the test data were selected for training and the rest were used as test
    % (50 for hy and 100 for spectral)
%     NumSamples = 100;%500;
    NumSamples = double(NumSamples);
    TrainIdx = randomSelectTrainSet(TestFlag,NumSamples);
    NewTrainImg = zeros(size(TestFlag));
    NewTrainImg(TrainIdx) = TestFlag(TrainIdx);
    TrainFlag = NewTrainImg;
    ClassCount = max(TestFlag(:));
    
    %Extraction of features based on training samples (EMP)
    fprintf('Generate SVM training feature set......\n');
    
    %Each band takes m opens and m closes.
    OpenCloseCount = 2;%4
    TestData = zeros([row col (2*OpenCloseCount+1)*dim]);
    for m = 1:dim
        tmp  = mat2gray(Img(:,:,m));
        TestData(:,:,(2*OpenCloseCount+1)*(m-1)+1) = tmp;
        for n = 1:OpenCloseCount
            se = strel('disk',2*n-1);
            TestData(:,:,(2*OpenCloseCount+1)*(m-1)+2*n) = imopen(tmp,se);
            TestData(:,:,(2*OpenCloseCount+1)*(m-1)+2*n+1) = imclose(tmp,se);
        end
    end
    TestData = reshape(TestData,row*col, (2*OpenCloseCount+1)*dim);

    
    %Generate training and test samples
    [TrainData, TestData] = createPixelSvmTrainSet(ClassCount,TestData,TrainFlag);
    
    % SVM parameter optimisation
    fprintf('SVM parameter optimisation......\n');
    if nargin==3
        bestcv = 0;
        for log2c = 0:5%-5:15
            for log2g = -5:5%-5:15
                
                cmd = ['-v 5 -c ', num2str(2^log2c), ' -g ', num2str(2^log2g),' -q',' -b 1'];
                cv = svmtrain(TrainData(:,1), TrainData(:,2:end), cmd);
                
                if (cv >= bestcv)
                    bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
                end
                fprintf('%g %g %g (best c=%g, g=%g, rate=%g)\n', log2c, log2g, cv, bestc, bestg, bestcv);
            end
        end
    elseif nargin==4
        parameter = cell2mat(varargin);
        bestc = parameter(1);
        bestg = parameter(2);
    end
    %Generate initial classification results and category probabilities
    fprintf('SVM prediction......\n');
    cmd = ['-t 2',' -c ', num2str(bestc),' -g ',num2str(bestg),' -q',' -b 1'];
    modelRBF = svmtrain(TrainData(:,1), TrainData(:,2:end), cmd);
    [ClassSVM, accuracy_L2, probalities] = svmpredict(TestFlag(:), TestData, modelRBF,' -b 1');
    [~,Idx] = sort(modelRBF.Label);
    probalities = probalities(:,Idx);
    ClassSVM = reshape(ClassSVM, [row,col]);