% filename
%if exist('filename','var') 
function filename = checkFile(filename)
if filename(2)~=':'
    if isempty(filename)
        filename = 'data';
    end
    if all(filename ~= '/')     % relative path
        filename = sprintf('sm_%s.mat', filename);
    end
    
    str = '';
    while (exist(filename, 'file') || exist([filename, '.mat'], 'file')) && ~strcmp(str, 'yes')
        fprintf('File %s exists. Overwrite? (yes/no)', filename);
        while 1
            str = input('', 's');
            switch str
                case 'yes'
                    break;
                case 'no'
                    filename = sprintf('sm_%s.mat', input('Enter new name:', 's'));
                    break
            end
        end
    end
end
end