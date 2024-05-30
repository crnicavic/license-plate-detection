function character = determine_character(letterimg, template)
%DETERMINE_LETTER Summary of this function goes here
% A function that will match

letterimg = imresize(letterimg, size(template{1}));
% calculate correlations
cor = corr2(template{1}, letterimg);

letter_ind = 1;
for j = 2:length(template)
    new_cor = corr2(template{j}, letterimg);
    if new_cor > cor
        cor = new_cor;
        letter_ind = j;
    end
end
% now translate the letter index to the actual character
if letter_ind <= 26
    % there are 26 characters in the alphabet
    character = char('A' + letter_ind - 1);
else
    character = char('0' + letter_ind - 27);
end


