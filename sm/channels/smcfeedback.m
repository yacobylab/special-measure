function val = smcfeedback(ico, val, rate)
% channels
% 1: fb val
% 2: set point
% 3: ctrlval
% 4: pain
% 5: igain
% 6: fb active flag
% 7: all the above (get only)
global fbdata;
global smdata;

switch ico(3)
    case 1
        switch ico(2)
            case 1
                fbdata.fbval(end) = val;
            case 2
                fbdata.setp = val;
            case 3
                fbdata.ctrlval(end) = val;
            case 4
                fbdata.pgain = val;
            case 5
                fbdata.igain = val;
            case 6
                fbdata.fbon = val;

            otherwise
                error('Invalid channel');
        end
        
    case 0
        data = [fbdata.fbval(end), fbdata.setp, fbdata.ctrlval(end), fbdata.pgain, ...
            fbdata.igain, fbdata.fbon];

        if ico(2) == 7
            if isfield(fbdata, 'pulseind')
                npind = smdata.inst(ico(1)).datadim(7)-6;
                val = [data, fbdata.pulseind(1:min(end, npind)), nan(1, npind-length(fbdata.pulseind))];
            else
                val = data;
            end
        else
            val = data(ico(2));
        end
        
    otherwise
        error('Operation not supported');
end
