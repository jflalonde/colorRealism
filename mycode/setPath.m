%% Path setup for the color statistics project
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear global;

% Do not call this if we're in deployed mode (mcc)
if isdeployed
    return;
end

%% Initialize the random number generator (initialized to the same value each time!)
rand('state', sum(100*clock));

basePath = '/nfs/hn01/jlalonde/results/colorStatistics/iccv07';

path3rdParty = '/nfs/hn01/jlalonde/code/matlab/trunk/3rd_party';
pathMyCode = '/nfs/hn01/jlalonde/code/matlab/trunk/mycode/';
rootPath = fullfile(pathMyCode, 'colorStatistics');

% Restore to initial state 
restoredefaultpath;

%% Setup mycode paths
addpath(fullfile(pathMyCode, 'database'));
addpath(fullfile(pathMyCode, 'database', 'labelme'));
addpath(fullfile(pathMyCode, 'histogram'));
addpath(fullfile(pathMyCode, 'xml'));
addpath(fullfile(pathMyCode, 'html'));
addpath(fullfile(pathMyCode, 'util'));
addpath(fullfile(pathMyCode, 'util', 'labelme'));

%% Setup util paths
utilPath = fullfile(pathMyCode, 'util');
addpath(utilPath);
addpath(fullfile(utilPath, 'rendering'));

%% Setup project paths
addpath(rootPath);
addpath(fullfile(rootPath, 'datasetGeneration'));
addpath(fullfile(rootPath, 'illuminationContext'));
addpath(fullfile(rootPath, 'localMatching'));
addpath(fullfile(rootPath, 'globalMatching'));
addpath(fullfile(rootPath, 'recoloring'));
addpath(fullfile(rootPath, 'measuresCombination'));
addpath(fullfile(rootPath, 'labeling'));

%% Additional useful stuff
addpath(fullfile(pathMyCode, 'imageCompositing', 'clustering', 'util'));

%% Setup 3rd party paths
% vgg
addpath(fullfile(path3rdParty, 'vgg_matlab'));
addpath(fullfile(path3rdParty, 'vgg_matlab', 'vgg_numerics'));
addpath(fullfile(path3rdParty, 'vgg_matlab', 'vgg_general'));
% Arguments parsing
addpath(fullfile(path3rdParty, 'parseArgs'));
% Labelme
addpath(fullfile(path3rdParty, 'LabelMeToolbox'));
% Color conversion
addpath(fullfile(path3rdParty, 'color'));
% Useful stuff
addpath(fullfile(path3rdParty, 'util'));
% for MM
addpath(fullfile(path3rdParty, 'netlab'));
% for Hungarian matching
% addpath(fullfile(path3rdParty, 'FullBNT', 'KPMtools'));
% Berkeley code
addpath(fullfile(path3rdParty, 'segmentationBerkeley', 'lib', 'matlab'));
% lightspeed
addpath(fullfile(path3rdParty, 'lightspeed'));
% EMD code
addpath(fullfile(path3rdParty, 'emd'));

