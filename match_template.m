function cor = match_template(img, template)
%MATCH_TEMPLATE Summary of this function goes here
%   Detailed explanation goes here
if size(img) ~= size(template)
    img = imgresize(img, size(template));
end

matches = 0;
[rows, cols] = size(img);
for i = 1:rows
    for j = 1:cols
        matches = matches + img(i, j) == template(i ,j);
    end
end
cor = matches / numel(img);
end

