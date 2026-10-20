% This is a script that demonstrates each stage of the processing pipeline
% of the count_cells function

clear; clc; close all

%% Initial Image
image= imread('example_image.JPG'); % Load the image
figure, imshow(image); title ('Original Image'); % Display the unedited image

%% Convert to Grayscale
Igc = im2gray(image); % Convert to grayscale
figure, imshow(Igc); title ('Grayscale Image'); % Display image

%% Smooth the Image
Igc = imgaussfilt(Igc,2); % Apply gaussian filter to smooth the image
figure, imshow(Igc); title ('Smoothed Image'); % Display image

%% Isolate Bright Sections and Remove Noise
T = adaptthresh(Igc,0.5);   % Creates a threshold map that provides a customized threshold value for a given region of pixels
IBright = imbinarize(Igc,T); % Applies the threshold map to the image, creating a binary image where a pixel that is above its threshold is 1 and a pixel that is not is 0
figure, imshow(IBright); title('Adaptive Threshold'); % Display image

IBright = bwareaopen(IBright,350); % Removes small noise (less than 350 pixels)
figure, imshow(IBright); title('Remove Small Noise') % Display image

%% Fragment Dilation
IBright = imdilate(IBright, strel('disk',4)); % Dilates and connects fragments
IBright = imclose(IBright, strel('disk',20)); % Fills holes
figure, imshow(IBright); title('Dilate and Connect Fragments') % Display image

%% Watershed Segmentation (Separate Touching Cells)
D = -bwdist(~IBright); % First inverts the image, so it focusses on the background. Then it performs bwdist, which tells you how far s pixel is from the closest background pixel. Then it becomes negative. Pixels in the center of blobs are very negative, those around the edges are slightly negative, and those fully in the background are very small. 
L = watershed(D); % Applies the watershed algorithm, which starts from identified minima (center of blobs) and works out until the boundary of two blobs meet
IBright(L==0) = 0; % Removes the watershed identified boundaries from the image
figure, imshow(IBright); title('Separated cells'); % Display image

%% Define BlobAnalysis
hblob = vision.BlobAnalysis( ... % Initializes settings for BlobAnalysis
'AreaOutputPort', true, ... % Output the area for each blob (or cell)
'MinimumBlobArea', 1500,... % The blob must be at least 1500 pixels
'MaximumCount', 1000); % Increases the maximum number of blobs to 1000 (default is 50)

%% Run BlobAnalysis
[blobArea, blobCentroid, blobBoundingBox] = hblob(IBright); % Perform the BlobAnalysis on the image
numCells = length(blobArea); % number of blobs (cells)

%% Label the Cells
label = 1:numCells; % Initialize numbered labels for each cell

% Add numbers to the image at the locations determined by the blobCentroid of the blob analysis
labeled_image = insertText(image, blobCentroid, label, ...
'TextColor', 'red', 'BoxOpacity', 0, 'AnchorPoint', 'Center','FontSize',60);

figure, imshow(labeled_image); title('Cell Count Result'); % Display Image