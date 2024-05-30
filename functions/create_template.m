function template = create_template()
    template = cell(36, 1);
    for i = 'A':'Z'
        txt = sprintf("C:/Users/user/Desktop/slike/projekat/Alpha/%c.bmp" , i);
        template{1 + i - 'A'} = imread(txt.char);
        if ~isa(template{1 + i - 'A'}, 'logical')
            template{1 + i - 'A'} = imbinarize(template{1 + i - 'A'});
        end
    end
    
    for i = '0':'9'
        txt = sprintf("C:/Users/user/Desktop/slike/projekat/Alpha/%c.bmp" , i);
        template{27 + i - '0'} = imread(txt.char);
        if ~isa(template{27 + i - '0'}, 'logical')
            template{27 + i - '0'} = imbinarize(template{27 + i - '0'});
        end        
    end
end

