function smdispchan(chan, data)

global smdata;

if ishandle(999)
    str = get(smdata.chandisph, 'string');
    for k = 1:length(chan)
        str{chan(k)} = sprintf('%.5g', data(k));       
    end
    set(smdata.chandisph, 'string', str);    
    drawnow;
end
