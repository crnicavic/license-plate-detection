clear, clc
%load image and convert to uint8 
imrgb = imread('images/Cars12.png');
%resize image
imrgb = imresize(imrgb, 2);

%best way to equalize rgb image
imhsv = rgb2hsv(imrgb);
% equalize histogram for v
v1 = imhsv(:, :, 3);
v1 = histeq(v1);
imhsv(:, :, 3) = v1;
%convert back to rgb
imrgb = hsv2rgb(imhsv);

imrgb = histeq(imrgb);
subplot(221), imshow(imrgb);

%convert to gray
imgray = rgb2gray(imrgb);

%convert to black and white
imbw = imbinarize(imgray, 0.4);
subplot(222), imshow(imbw);

%now do processing to figure out what works
%find edges between color changes
im = edge(imbw, 'sobel');
subplot(223), imshow(im);

im = imdilate(im, strel('diamond', 2));
im = imfill(im, 'holes');
%im = imclearborder(im);
im = imerode(im, strel('diamond', 4'));
subplot(224), imshow(im);
imarea = numel(im);

%AN IDEA!
% look for a bounding box with the most boxes inside it
iprops = regionprops(im, 'BoundingBox', 'Area', 'Image');
for i = 1:length(iprops)
    %if iprops(i).Area > imarea * 0.0005 && iprops(i).Area < imarea * 0.005
    bbox = iprops(i).BoundingBox;
    
    subplot(221), rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2); 
    %end
end