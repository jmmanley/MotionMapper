function [mu,vecs,vals,vecsS,valsS, s] = onlineImagePCA_tiff(path,batchSize,scale,pixels,numPerFile)
%onlineImagePCA_radon finds postural eigenmodes based upon a set of
%aligned images (called by findPosturalEigenmodes.m).
%
%   Input variables:
%
%       paths -> path to tiff files
%       batchSize -> # of images to process at once
%       scale -> image scaling factor
%       pixels -> pixels to use (Lx1 or 1xL array)
%       numPerFile -> # of images to use per file
%
%
%   Output variables:
%
%       mu -> mean value for each of the pixels
%       vecs -> postural eignmodes (LxL array).  Each column (vecs(:,i)) is
%                   an eigenmode corresponding to the eigenvalue vals(i)
%       vals -> eigenvalues of the covariance matrix
%
%
% (C) Gordon J. Berman, 2014
%     Princeton University
% Modified JM: remove radon, use tiffs instead.


if nargin < 3 || isempty(scale)
    scale = 1;
end

if nargin < 6 || isempty(numPerFile)
    numPerFile = -1;
end

file_list = dir(fullfile(path, '*.tif*'));
M = numel(file_list);
files = {file_list.name};

testImage = imread(fullfile(path, files{1}));
testImage = imresize(testImage(:,:,1), scale);
s = size(testImage);

if isempty(pixels)
    pixels = 1:length(testImage(:));
end
L = length(pixels);

firstBatch = true;
tempMu = zeros(1,L);
totalImages = 0;

if numPerFile == -1
    currentNumPerFile = M;
else
    currentNumPerFile = numPerFile;
end


if M < currentNumPerFile
    currentIdx = 1:M;
else
    currentIdx = randperm(M,currentNumPerFile);
end
M = min([M currentNumPerFile]);


if M < batchSize
    currentBatchSize = M;
else
    currentBatchSize = batchSize;
end
num = ceil(M/currentBatchSize);

currentImage = 0;
X = zeros(currentBatchSize,L);
for j=1:num
    
    fprintf(1,'\t Batch #%5i out of %5i\n',j,num);
    
    if firstBatch
        
        firstBatch = false;
        
        parfor i=1:currentBatchSize
            
            a = imread(fullfile(path, files{currentIdx(i)}));
            a = double(imresize(a(:,:,1),scale));
            % lowVal = min(a(a>0));
            % highVal = max(a(a>0));
            % a = (a - lowVal) / (highVal - lowVal);
            
            X(i,:) = a(pixels);
            
        end
        currentImage = currentBatchSize;
        
        mu = sum(X);
        C = cov(X).*currentBatchSize + (mu'*mu)./ currentBatchSize;
        
        shuffledC = cov(shuffledMatrix(X)).*batchSize + (mu'*mu)./ batchSize;
        
    else
        
        if j == num
            maxJ = M - currentImage;
        else
            maxJ = currentBatchSize;
        end
        
        tempMu(:) = 0;
        iterationIdx = currentIdx((1:maxJ) + currentImage);
        parfor i=1:maxJ
            
            a = imread(fullfile(path, files{iterationIdx(i)}));
            a = double(imresize(a(:,:,1),scale));
            % lowVal = min(a(a>0));
            % highVal = max(a(a>0));
            % a = (a - lowVal) / (highVal - lowVal);
            
            y = a(pixels);
            X(i,:) = y';
            tempMu = tempMu + y';
            
        end
        
        mu = mu + tempMu;
        C = C + cov(X(1:maxJ,:)).*maxJ + (tempMu'*tempMu)./maxJ;
        currentImage = currentImage + maxJ;
        
        
        shuffledC = shuffledC + cov(shuffledMatrix(X(1:maxJ,:))).*maxJ + (tempMu'*tempMu)./maxJ;
        
    end
    totalImages = totalImages + currentImage;
end

mu = mu ./ totalImages;
C = C ./ totalImages - mu'*mu;

shuffledC = shuffledC ./ totalImages - mu'*mu;

fprintf(1,'Finding Principal Components\n');
[vecs,vals] = eig(C);

vals = flipud(diag(vals));
vecs = fliplr(vecs);

fprintf(1,'Finding Shuffled Principal Components\n');
[vecsS,valsS] = eig(shuffledC);

valsS = flipud(diag(valsS));
vecsS = fliplr(vecsS);

end