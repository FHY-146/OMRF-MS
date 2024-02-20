function [C,m]=covmatrix(X)
[K,n]=size(X);
X=double(X);
if K==1
    C=eye(n)*eps;
    m=X;
else
    m=sum(X,1)/K;  %,,Find the mean of each column, that is, there are a total of K rows, 
                   % I add up the K rows and divide by K to get the mean of this column, 
                   % which can also be regarded as the mean of this band, m is a row vector
    X=X-m(ones(K,1),:);  %  
    C=(X'*X)/(K-1);  %£¬Find its variance
    m=m';
end
end
