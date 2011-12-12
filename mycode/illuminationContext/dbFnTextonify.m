%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function dbFnTextonify(outputBasePath, annotation, varargin)
%  
% 
% Input parameters:
%
%   - varargin: Possible values:
%     - 'Recompute':
%       - 0: (default) will not compute the histogram when results are
%         already available. 
%       - 1: will re-compute histogram no matter what
%
% Output parameters:
%   
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function r = dbFnTextonify(outputBasePath, annotation, varargin) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2006-2007 Jean-Francois Lalonde
% Carnegie Mellon University
% Do not distribute
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
r = 0;  

% check if the user specified the option to relabel
defaultArgs = struct('Recompute', 0, 'ImagesPath', [], 'FilterBank', [], 'FilterBankParams', [], ...
    'ClusterCenters', []);
args = parseargs(defaultArgs, varargin{:});

% load the output xml structure
xmlPath = fullfile(outputBasePath, annotation.image.folder, strrep(annotation.image.filename, '.jpg', '.xml'));
imgInfo = loadXML(xmlPath);

if ~args.Recompute && isfield(imgInfo, 'univTextons')
    fprintf('Results already computed! Skipping...\n');
end

% read the image
imgPath = fullfile(args.ImagesPath, annotation.image.folder, annotation.image.filename);
img = imread(imgPath);
[h,w,c] = size(img); %#ok

% convert to grayscale
imgGray = rgb2gray(img);

% filter it
fprintf('Filtering image...'); tic;
filteredImg = fbRun(args.FilterBank, imgGray);
fprintf('done in %fs.\n', toc);

% stack it into a nbPixel * nbDims vector
filteredImg = cellfun(@(x) reshape(x, [size(x,1)*size(x,2) 1]), filteredImg, 'UniformOutput', 0);
filteredImg = reshape(filteredImg, [1, size(filteredImg,1)*size(filteredImg,2)]);
filteredImg = [filteredImg{:}];

% find nearest neighbors for each pixel, and assign its index
fprintf('Assigning textons...');
[ind, d] = vgg_nearest_neighbour(filteredImg', args.ClusterCenters);
textonMap = reshape(ind, [h w]);
fprintf('done in %fs\n', toc);

% build the output .mat file path
[path, baseFileName] = fileparts(annotation.image.filename);
texSubDir = 'textonMap';
texName = fullfile(texSubDir, sprintf('%s_textonMap.mat', baseFileName));

texDir = fullfile(outputBasePath, annotation.image.folder);
[s,s,s] = mkdir(fullfile(texDir, texSubDir)); %#ok

% save the filtered pixels in the corresponding .mat file
fprintf('Saving filtered pixels: %s\n', fullfile(texDir, texName));
save(fullfile(texDir, texName), 'textonMap');

% save xml information
imgInfo.univTextons.textonMap = texName;

% save the file (overwrite)
fprintf('Saving xml file: %s\n', xmlPath);
writeXML(xmlPath, imgInfo);

