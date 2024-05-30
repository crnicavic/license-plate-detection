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