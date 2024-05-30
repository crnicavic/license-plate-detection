%clc, clearvars -except template y x

% this function is crazy slow, no need to call it every run
if ~exist('template', 'var')
    template = create_template();
end

% only in case of a new image being loaded
img_num = 54;
img_path = sprintf('images/Car (%d).png', img_num);
imrgb = imread(img_path);
imrgb = im_eq(imrgb);
subplot(221), imshow(imrgb);

if ~isa(imrgb, 'double')
    imrgb = im2double(imrgb);
end

if exist('previmg_path', 'var')
    % comparing strings is slower, but more flexible
    if ~strcmp(previmg_path, img_path)        
        [y, x] = ginput(2);
    end
end
% i need to implement one thing and that is to save the bounding boxes
% for images that already have good accuracy to save myself time
previmg_path = img_path;

plate = imrgb(floor(min(x)):ceil(max(x)), floor(min(y)):ceil(max(y)), :);
plate = rgb2gray(plate);
%plate = histeq(plate);
plate = imsharpen(plate);
plate = imsharpen(plate);
subplot(222), imshow(plate);

h = [-1 -1 -1; -1 8 -1; -1 -1 -1];
%plate = imfilter(plate, h);
subplot(223), imshow(plate);

binplate = ~imbinarize(plate);
%plate = imfill(plate, 'holes');
%binplate = imdilate(binplate, strel('diamond', 1));
subplot(224), imshow(binplate);

iprops = regionprops(binplate, 'BoundingBox', 'Area', 'Image');

platetxt = [];
for i = 1:length(iprops)
    %bbox is described as [x y ; w h]
    bbox = iprops(i).BoundingBox;
    box_area = iprops(i).Area;
    [h, w] = size(binplate);
    % i also need to add an aspect ratio filter
    condition = bbox(3) > 0.02 * w && bbox(3) < 0.3 * w ;
    condition = condition && bbox(4) > 0.1 * h && bbox(4) < 0.95 * h;
    condition = condition && box_area > 0.01 * numel(plate) && box_area < 0.4 * numel(plate);
    
    if condition
        subplot(222), rectangle('Position', bbox, 'EdgeColor', 'r', 'LineWidth', 2); 
        % now i need to translate the rectangle to coordinates
        start_row = ceil(bbox(2));
        end_row = floor(bbox(2)+bbox(4));
        start_col = ceil(bbox(1));
        end_col = floor(bbox(1)+bbox(3));
        letter = binplate(start_row:end_row, start_col:end_col);
        %resize the letter to fit the template
        letter = imresize(letter, size(template{1}));
        % calculate correlations
        cor = corr2(template{1}, letter);
        %cor = match_template(letter, template{1});
        letter_ind = 1;
        for j = 2:length(template)
            new_cor = corr2(template{j}, letter);
            %new_cor = match_template(letter, template{j});
            if new_cor > cor
                cor = new_cor;
                letter_ind = j;
            end
        end
        % now translate the letter index to the actual character
        if letter_ind <= 26
            % there are 26 characters in the alphabet
            platetxt = [platetxt char('A' + letter_ind - 1)];
        else
            platetxt = [platetxt char('0' + letter_ind - 27)];
        end
        
    end
end

disp(platetxt);

