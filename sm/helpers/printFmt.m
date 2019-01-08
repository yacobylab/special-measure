function printFmt(prtCell)

for j = 1:length(prtCell)
    if ischar(prtCell{j})
        fprintf(' %s',prtCell{j});
    elseif isnumeric(prtCell{j})
        fprintf(' %g',prtCell{j});
    elseif isa(prtCell{j},'function_handle')
        fprintf(' %s',func2str(prtCell{j}));
    elseif iscell(prtCell{j})
        printFmt(prtCell{j});
    else
        warning('Arg is not a number, string or func')
    end
    fprintf(',');
end
end