function demoColorCompatibility
% Runs the color compatibility code on one image
% 
% ----------
% Jean-Francois Lalonde

%% Setup paths

imgPath = '/Users/jflalonde/Documents/research/data/colorStatistics/fromSu/ToLalonde/1/Composite.jpg';
objMaskPath = '/Users/jflalonde/Documents/research/data/colorStatistics/fromSu/ToLalonde/1/Composite_Mask.jpg';

nbTextonClusters = 1000;
clusterCentersPath = getPathName('results', 'illuminationContext', 'textons', ...
    sprintf('clusterCentersTest_%d.mat', nbTextonClusters));

databasesPath = getPathName('results', 'databases');

colorConcatHistPath = getPathName('results', 'globalMeasures', 'concatHisto');
textonConcatHistPath = getPathName('results', 'globalMeasures', 'concatHistoTextons');

%% User parameters (from ICCV'07)

% number of bins in color histogram
nbColorBins = 50;

% number of nearest neighbors to retrieve from the database
k = 50; 

% threshold on distance to objects in the database to determine whether the
% global or local measure should be used
maxDistance = 0.35; 

% blend between using color and texton distance
alpha = 0.75;


%% Load image information
img = imread(imgPath);
objMask = im2double(imread(objMaskPath));
objMask = all(objMask>0.5, 3);

%% Load object database information
% load(fullfile(databasesPath, 'objectDb.mat'), 'objectDb');

%% Load concatenated histogram files


load(fullfile(databasesPath, 'indActiveLab_50.mat'));

%% Load texton information

% create filter bank from parameters
numOrient = 8;
startSigma = 1;
numScales = 2;
scaling = 1.4;
elong = 2;
filterBank = fbCreate(numOrient, startSigma, numScales, ...
    scaling, elong);

% load cluster centers
load(clusterCentersPath, 'clusterCenters');

%% Process the image

% compute texton map
textonMap = textonify(img, filterBank, clusterCenters);

% compute object and background distributions
textonObjHist = histc(textonMap(objMask), 1:1000);
textonBgHist = histc(textonMap(~objMask), 1:1000);

imgLab = rgb2lab(img);
imgLabVec = reshape(imgLab, size(imgLab,1)*size(imgLab,2), size(imgLab,3));

% compute color distributions
colorObjHist = myHistoND(imgLabVec(objMask, :), nbColorBins, [0 -100 -100], [100 100 100]);
colorObjHist = colorObjHist(indActiveLab);
colorBgHist = myHistoND(imgLabVec(~objMask, :), nbColorBins, [0 -100 -100], [100 100 100]);
colorBgHist = colorBgHist(indActiveLab);

clear('textonMap', 'img', 'imgLab', 'imgLabVec', 'objMask');

%% Find k-nearest neighbors in the database
% Distance measure = 0.75*color + 0.25*texture on objects
% Use distance on background as realism measure

globalDistance = computeGlobalDistanceMeasure(colorConcatHistPath, textonConcatHistPath, ...
    colorObjHist, textonObjHist, 'Obj', alpha, k);

%% Decide whether to use the local or global measure for evaluating realism

useGlobal = false;
if globalDistance < maxDistance
    % we found a good object. Rely on the distance to background.
    fprintf('Using the global measure.\n');
    realismScore = computeGlobalDistanceMeasure(colorConcatHistPath, textonConcatHistPath, ...
        colorBgHist, textonBgHist, 'Bg', alpha, k);
    
    useGlobal = true;
    
else
    % we didn't find a good object. Rely on the local measure.
    fprintf('Using the local measure.\n');
    realismScore = alpha*chisq(colorBgHist, colorObjHist) + ...
        (1-alpha)*chisq(textonBgHist, textonObjHist);
end

fprintf('Realism score: %.2f\n', realismScore);

%% Re-color the object according to 
% 1. background in the same image if the local measure was used
% 2. background in the nearest-neighbor image if the global measure was used

if useGlobal
    error('implement me!');
    bgImg = [];
    bgMask = [];
    
    imgRecolored = recolorImage(img, objMask, bgImg, bgMask)
else
    imgRecolored = recolorImage(img, objMask);
end

% Recolor the image
