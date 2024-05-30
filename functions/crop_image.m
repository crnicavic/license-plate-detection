function cropped = crop_image(img, y, x)
%CROP_IMAGE Summary of this function goes here

start_row = ceil(min(x));
end_row = floor(max(x));
start_col = ceil(min(y));
end_col = floor(max(y));
cropped = img(start_row:end_row, start_col:end_col, :);
end

