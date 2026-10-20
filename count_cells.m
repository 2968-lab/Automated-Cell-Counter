% Function that counts the number of cells within an inputted image and returns an image marking cell positions

function [numCells,labeled_image] = count_cells (image)
    %% Make the Image Grayscale
    Igc = im2gray(image); % Converts a color image to grayscale

    %% Smooth the Image
    Igc = imgaussfilt(Igc,2); % Applies a gaussian filter to smooth the image

    %% Isolate Bright Sections and Remove Noise
    T = adaptthresh(Igc,0.5);   % Creates a threshold map that provides a customized threshold value for a given region of pixels
    IBright = imbinarize(Igc,T); % Applies the threshold map to the image, creating a binary image where a pixel that is above its threshold is 1 and a pixel that is not is 0
    IBright = bwareaopen(IBright,350); % Removes small noise (less than 350 pixels)

    %% Fragment Dilation
    IBright = imdilate(IBright, strel('disk',4)); % Dilates and connects fragments
    IBright = imclose(IBright, strel('disk',20)); % Fills holes

    %% Watershed Segmentation (Separate Touching Cells)
    D = -bwdist(~IBright); % First inverts the image, so it focusses on the background. Then it peforms bwdist, which tells you how far a pixel is from the closest background pixel. Then it becomes negative. Pixels in the center of blobs are very negative, those around the edges are slightly negative, and those fully in the background are very small. 
    L = watershed(D); % Applies the watershed algorithm, which starts from identified minima (center of blobs) and works out until the boundary of two blobs meet
    IBright(L==0) = 0; % Removes the watershed identified boundaries from the image

    %% Define BlobAnalysis
    hblob = vision.BlobAnalysis( ... % Initializes settings for BlobAnalysis
    'AreaOutputPort', true, ... % Output the area for each blob (or cell)
    'MinimumBlobArea', 1500,... % The blob must be at least 1500 pixels
    'MaximumCount', 1000); % Increases the maximum number of blobs to 1000 (default is 50)

    %% Peforme BlobAnalysis
    [blobArea,blobCentroid] = hblob(IBright); % Performs the BlobAnalysis on the image

    %% Count Cells
    numCells = length(blobArea); % Records the number of blobs (cells)

    %% Label Image
    strDisplay = 1:numCells; % Initialize numbered labels for each cell

    % Add numbers to the image at the locations determined by the blobCentroid of the blob analysis
    labeled_image = insertText(image, blobCentroid, strDisplay, ...
    'TextColor', 'red', 'BoxOpacity', 0, 'AnchorPoint', 'Center','FontSize',60);
end