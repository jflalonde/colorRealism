%% Path setup for the color statistics project

clear global;
global logFileRoot;

% host-dependent paths
[a, host] = system('hostname');

logFileRoot = getPathName('logs');
path3rdParty = getPathName('code', '3rd_party');
pathMyCode = getPathName('code', 'mycode');
pathUtils = getPathName('codeUtils');

%% Turn off some annoying warnings
warning off Images:initSize:adjustingMag;

% Restore to initial state
restoredefaultpath;

%% Setup project paths
addpath(genpath(pathMyCode));
addpath(genpath(pathUtils));
addpath(genpath(path3rdParty));
 
