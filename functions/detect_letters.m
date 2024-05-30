function [boxes, binplate] = detect_letters(plate, dilate)
%READ_LETTERS Summary of this function goes here
%   Detailed explanation goes here
%load necessary data
try
plate = rgb2gray(plate);
end
%figure, imshow(plate);
plate = imsharpen(plate);
plate = imsharpen(plate);
%subplot(222), imshow(plate);

binplate = ~imbinarize(plate);
%plate = imfill(plate, 'holes');
if dilate
    binplate = imdilate(binplate, strel('diamond', 1));
end
%subplot(224), imshow(binplate);

iprops = regionprops(binplate, 'BoundingBox', 'Area', 'Image');

boxes = cell(0, 1);
for i = 1:length(iprops)
    %bbox is described as [x y ; w h]
    bbox = iprops(i).BoundingBox;
    box_area = iprops(i).Area;
    [h, w] = size(binplate);
    %TODO: change these to just use area and aspect ratio
    condition = bbox(3) > 0.02 * w && bbox(3) < 0.3 * w ;
    condition = condition && bbox(4) > 0.1 * h && bbox(4) < 0.95 * h;
    condition = condition && box_area > 0.01 * numel(plate) && box_area < 0.4 * numel(plate);
    if condition
        boxes = [boxes bbox];
    end
    
end
end

