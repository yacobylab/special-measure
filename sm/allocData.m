function data = allocData(procfn,data,newdata,count,dataindPrev,ndim)
%function data = allocData(procfn,data,newdata,count,dataindPrev,ndim)
for k = 1:length(procfn)
    if isfield(procfn(k).fn, 'outdata')
        for fn = procfn(k).fn
            if isempty(fn.outchan)
                data{dataindPrev + fn.outdata} = fn.fn(newdata{fn.inchan}, data{dataindPrev + fn.indata}, fn.args{:});
            else
                [newdata{fn.outchan}, data{dataindPrev + fn.outdata}] = fn.fn(newdata{fn.inchan}, data{dataindPrev + fn.indata}, fn.args{:});
            end
        end
    else
        for fn = procfn(k).fn
            if isempty(fn.fn)
                newdata(fn.outchan) = newdata(fn.inchan); % only permute channels
            else
                [newdata{fn.outchan}] = fn.fn(newdata{fn.inchan}, fn.args{:});
            end
        end
        s.type = '()'; 
        s.subs = [num2cell(count), repmat({':'}, 1, ndim(dataindPrev + k))]; %fix
        if isempty(fn)
            data{dataindPrev + k} = subsasgn(data{dataindPrev + k}, s, newdata{k});
        else
            data{dataindPrev + k} = subsasgn(data{dataindPrev + k}, s, newdata{fn.outchan(1)});
        end
    end
end

end