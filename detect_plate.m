clear, clc

imrgb = imread('images/Cars11.png');
if strcmp(class(imrgb), 'double')
    imrgb = im2double(imrgb);
end
%resize image
imrgb = imresize(imrgb, 2);
imrgb = im_eq(imrgb);

subplot(221), imshow(imrgb);

%convert to gray
imgray = rgb2gray(imrgb);
%imgray_transformed = gray_stretch(imgray, 130/255, 1);
%subplot(222), imshow(imgray_transformed);

%now do processing to figure out what works
%find edges between color changes
im = edge(imgray, 'sobel');
subplot(222), imshow(im);

im = imdilate(im, strel('diamond', 2));
im = imfill(im, 'holes');
subplot(223), imshow(im);
%MORE IDEAS: Erode the shit out of the picture than just dilate it back
im = imerode(im, strel('diamond', 10));
im = imerode(im, strel('diamond', 10));
im = imdilate(im, strel('square', 20));
im = im .* imgray;
subplot(224), imshow(im);
imarea = numel(im);

iprops = regionprops(im, 'BoundingBox', 'Area', 'Image');
for i = 1:length(iprops)
    %if iprops(i).Area > imarea * 0.0005 && iprops(i).Area < imarea * 0.005
    bbox = iprops(i).BoundingBox;
    
    subplot(221), rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2); 
    %end
end

function newim = gray_stretch(im, fmin, fmax)
    [rows, cols] = size(im);
    newim = zeros(rows, cols);
    range = fmax - fmin;
    for row = 1:rows
        for col = 1:cols
            if im(row, col) < fmin
                newim(row, col) = 0;
            elseif im(row, col) > fmax
                newim(row, col) = 1;
            else
                newim(row, col) = (im(row, col) - fmin) / range;
            end
        end
    end
end

%histogram eq of rgb picture
function new_imrgb = im_eq(imrgb)
   
    %best way to equalize rgb image
    imhsv = rgb2hsv(imrgb);
    % equalize histogram for v
    v1 = imhsv(:, :, 3);
    v1 = histeq(v1);
    imhsv(:, :, 3) = v1;
    %convert back to rgb
    new_imrgb = hsv2rgb(imhsv);
 
end