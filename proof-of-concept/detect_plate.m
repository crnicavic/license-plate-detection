clear, clc
% the function now is very good at finding letters of the license plate
% but needs to be tuned for each image
% for some image contrast stretching just makes the image unreadable
%       i.e Car206
% for some images the second erosion removes just about all pixels
%       for most of these the first erosion also needs to be smaller

% One thing i will definetely do is add those settings in the gui
% but i still wish to be ableto find a way 
imrgb = imread('images/Car (59).png');
if isa(imrgb, 'double')
    imrgb = im2double(imrgb);
end
%resize image
%imrgb = imresize(imrgb, 2);
imrgb = im_eq(imrgb);

subplot(221), imshow(imrgb);

%convert to gray
imgray = im2double(rgb2gray(imrgb));
%imgray_transformed = gray_stretch(imgray, 130/255, 1);
%subplot(222), imshow(imgray_transformed);

%now do processing to figure out what works
%find edges between color changes
im = edge(imgray, 'sobel');
%subplot(222), imshow(im);

im = imdilate(im, strel('diamond', 2));
im = imfill(im, 'holes');
subplot(222), imshow(im);
% doing multiple erosions to get rid of all small artifacts
% then dilating it back so that i don't lose relevant data
im = imerode(im, strel('diamond', 1));
im = imerode(im, strel('diamond', 3));
im = imdilate(im, strel('square', 30));
subplot(223), imshow(im);
%im = im .* imgray;
%im = imbinarize(im);
%im = ~im;
subplot(224), imshow(im);
imarea = numel(im);
    
%TODO: figure out what size bounding boxes to filter
% this function looks for white around black, so i abuse it
iprops = regionprops(im, 'BoundingBox', 'Area', 'Image');
for i = 1:length(iprops)
    %if iprops(i).Area > imarea * 0.00005 && iprops(i).Area < imarea * 0.005
    bbox = iprops(i).BoundingBox;
    
    subplot(221), rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2); 
    %end
end
