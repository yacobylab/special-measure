function scandef = initTrafofn(scandef)
for i = 1:length(scandef)
    nsetchan = length(scandef(i).setchan);
    if ~isfield(scandef,'trafofn') || isempty(scandef(i).trafofn)
        scandef(i).trafofn = {};
       [scandef(i).trafofn{1:nsetchan}] = deal(@(x, y) x(i));
    else
        for j = 1:nsetchan
            if iscell(scandef(i).trafofn)
                if isempty(scandef(i).trafofn{j})
                    scandef(i).trafofn{j} = @(x, y) x(i);
                end
            else
                if isempty(scandef(i).trafofn(j).fn)
                  scandef(i).trafofn(j).fn = @(x, y) x(i);
                  scandef(i).trafofn(j).args = {};
                end
                if ~iscell(scandef(i).trafofn(j).args)
                    if ~isempty(scandef(i).trafofn(j).args)
                        error('Trafofn args must be a cell array');
                    else
                        scandef(i).trafofn(j).args={};
                    end
                end
            end                
        end
    end
end