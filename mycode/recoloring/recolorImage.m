function img = recolorImage(srcImg, objMask, tgtImg, bgMask)
% Recolors the object in an image with the ICCV'07 algorithm.
% 
%   img = recolorImage(srcImg, objMask, <tgtImg, bgMask>)
%
%  

assert(islogical(objMask), 'Object mask must be logical');

srcImg = im2double(srcImg);
if nargin == 2
    tgtImg = im2double(srcImg);
    bgMask = ~objMask;
end

% Parameters
nbClusters = 50;

% imgVector = reshape(img, [w*h c]);
srcImgVector = reshape(srcImg, [size(srcImg,1)*size(srcImg,2) size(srcImg,3)]);
tgtImgVector = reshape(tgtImg, [size(tgtImg,1)*size(tgtImg,2) size(tgtImg,3)]);

% Retrieve the background and object pixels
bgPixels = double(tgtImgVector(bgMask(:), :));
objPixels = double(srcImgVector(objMask(:), :));

%% Compute signatures
[centersObj, weightsObj, indsObj] = signaturesKmeans(objPixels, nbClusters);
[centersBg, weightsBg, indsBg] = signaturesKmeans(bgPixels, nbClusters);

%% Compute the EMD between signatures
distMat = pdist2(centersObj', centersBg');
[distEMD, flowEMD] = emd_mex(weightsObj', weightsBg', distMat);

emdFig = figure(4); hold on;
plotEMD(emdFig, centersObj, centersBg, flowEMD);
plotSignatures(emdFig, centersObj, weightsObj, 'lab');
plotSignatures(emdFig, centersBg, weightsBg, 'lab');
title(sprintf('K-means clustering with k=%d on image colors, EMD=%f', nbClusters, distEMD));
xlabel('l'), ylabel('a'), zlabel('b');

%% Weight each background clusters by its texton matching to the object
weightsBgTextons = reweightClustersFromTextons(weightsBg, textonWeight(bgMask(:)), indsBg);

% re-compute the EMD with the texton-weighted clusters
[distEMD, flowEMDTextons] = emd_mex(weightsObj', weightsBgTextons', distMat);

emdFig = figure(5); hold on;
plotEMD(emdFig, centersObj, centersBg, flowEMDTextons);
plotSignatures(emdFig, centersObj, weightsObj, 'lab');
plotSignatures(emdFig, centersBg, weightsBgTextons, 'lab');
title(sprintf('EMD with weighted clusters with k=%d on image colors, EMD=%f', nbClusters, distEMD));
xlabel('l'), ylabel('a'), zlabel('b');

%% Recolor
sigma = 5;
[imgTgtNN, imgTgtNNW, pixelShift, clusterShift, clusterShiftWeight] = ...
    recolorImageFromEMD(centersBg, centersObj, img, indsObj, find(objMask(:)), flowEMD, sigma);

figure(7), subplot(1,2,1), imshow(uint8(rgbImage)), title('Original image'), ...
    subplot(1,2,2), imshow(lab2rgb(imgTgtNNW)), title(sprintf('Weighted nn cluster center, \\sigma=%d', sigma));

clusterShiftWeightMax = max(clusterShiftWeight, [], 2);
pctDist(sigmas==sigma) = nnz(clusterShiftWeightMax<0.5) / length(clusterShiftWeightMax);

%% Recolor with texton weighting
sigma = 5;
[imgTgtNN, imgTgtNNW, pixelShift, clusterShift, clusterShiftWeight] = ...
    recolorImageFromEMD(centersBg, centersObj, img, indsObj, find(objMask(:)), flowEMDTextons, sigma);

figure(8), subplot(1,2,1), imshow(uint8(rgbImage)), title('Original image'), ...
    subplot(1,2,2), imshow(lab2rgb(imgTgtNNW)), title(sprintf('Weighted nn cluster center (textons), \\sigma=%d', sigma));

clusterShiftWeightMax = max(clusterShiftWeight, [], 2);
pctDist(sigmas==sigma) = nnz(clusterShiftWeightMax<0.5) / length(clusterShiftWeightMax);
