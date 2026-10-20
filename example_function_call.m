% This script is an example function call of the count_cells function

clear; clc; close all

%% Input Name of Image or Path to Image
image_name = "example_image.JPG";

%% Processing
image = imread(image_name); % Load the image as a variable

% Run count_cells function on the image
[num_cells,labeled_image] = count_cells(image);

%% Output
% Display the original image
figure
imshow(image)
title("Original Image")

% Display the outputted, labeled image
figure
imshow(labeled_image)
title("Image with Overlaid Cell Locations")

% Display number of cells
disp("The number of cells in " + image_name + " is " + num_cells)