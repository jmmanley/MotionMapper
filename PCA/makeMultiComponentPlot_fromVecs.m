function image = makeMultiComponentPlot_fromVecs(C,N,pixels,imageSize)
%makes an pictoral representation of a set of postural eigenmodes
%
% Inputs:
%   C -> Lxd matrix of eigenvectors (each along a column) to be plotted
%   N -> number of eigenvectors to be chosen (first N will be used)
%   pixels -> pixels that are used
%   imageSize -> size of image

    if nargin < 2 || isempty(N)
        N = length(C(1,:));
    end
    
    if nargin < 4 || isempty(imageSize)
        imageSize = [201 90];
    end

    L = ceil(sqrt(N));
    M = ceil(N/L);
    
    P = imageSize(1);
    Q = imageSize(2);
    
    currentImage = zeros(P,Q);
    for i=1:N
        disp(i)
        currentImage(pixels) = C(:,i);
        X1 = mod(i-1,M)+1;
        Y1 = ceil(i/M);
        image(((Y1-1)*P+1):(Y1*P),((X1-1)*Q+1):(X1*Q)) = currentImage;
    end
    
    imagesc(image);
    axis equal 
    axis off
    caxis([-3e-3 3e-3])