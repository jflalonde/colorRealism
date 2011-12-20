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
objectDbPath = getPathName('results', 'objectDb');

colorConcatHistPath = getPathName('results', 'globalMeasures', 'concatHisto');
textonConcatHistPath = getPathName('results', 'globalMeasures', 'concatHistoTextons');

nbColorBins = 50;


%% Load image information
img = imread(imgPath);
objMask = imread(objMaskPath);

%% Load object database information
load(fullfile(databasesPath, 'objectDb.mat'), 'objectDb');

%% Load concatenated histogram files
colorHistFiles = dir(fullfile(colorConcatHistPath, '*lab_jointObj*'));
colorHistFiles = {colorHistFiles(:).name};
textonHistFiles = dir(fullfile(textonConcatHistPath, '*textonObj*'));
textonHistFiles = {textonHistFiles(:).name};

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
colorBgHist = myHistoND(imgLabVec(~objMask, :), nbColorBins, [0 -100 -100], [100 100 100]);

%% Find nearest neighbors in the database
% Distance measure = 0.75*color + 0.25*texture on objects
% Use distance on background as realism measure

% Note: this should take forever.
alpha = 0.75;
for i_obj = 1:length(objectDb)
    % load the object's color and texton histogram
    objInfo = objectDb(i_obj).document;
    
    % load all color histograms
    colorDist = zeros(length(objectDb), 1);
    textonDist = zeros(length(objectDb), 1);
    
    baseInd = 1;
    for i_file = 1:length(colorHistFiles)
        h = load(fullfile(colorConcatHistPath, colorHistFiles{1}));
        validInd = find(cellfun(@(x) ~isempty(x), h.concatHisto));
        
        curInd = validInd+baseInd-1;
        colorDist(curInd) = [];
        
        baseInd = baseInd + length(h.concatHisto)-1;
    end
    
    % compute distance to object
    colorDist = chisq(colorObjHist, colorDbObjHist);
    textonDist = chisq(textonObjHist, textonDbObjHist);
    
    combinedDist = alpha*colorDist + (1-alpha)*textonDist;
end



