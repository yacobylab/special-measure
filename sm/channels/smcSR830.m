function val = smcSR830(ic, val, rate)
% 1: X, 2: Y, 3: R, 4: Theta, 5: freq, 6: ref amplitude
% 7:10: AUX input 1-4, 11:14: Aux output 1:4
% 15,16: stored data, length determined by datadim
% 17: sensitivity
% 18: time constant
% 19: sync filter on/off

global smdata;

cmds = {'OUTP 1', 'OUTP 2', 'OUTP 3', 'OUTP 4', 'FREQ', 'SLVL', ...
    'OAUX 1', 'OAUX 2', 'OAUX 3', 'OAUX 4', 'AUXV 1', 'AUXV 2', 'AUXV 3', 'AUXV 4' ...
    ,'','','SENS', 'OFLT', 'SYNC'};

switch ic(2) % Channel
    case {15, 16} % stored data, length determined by datadim
        switch ic(3)
            case 0  % get              
                npts = smdata.inst(ic(1)).datadim(ic(2), 1);
                while 1
                    navail = query(smdata.inst(ic(1)).data.inst, 'SPTS?', '%s\n', '%d');
                    if navail >= npts + smdata.inst(ic(1)).data.currsamp;
                        break;
                    else
                        pause(0.8 * (npts + smdata.inst(ic(1)).data.currsamp - navail) ...
                            * smdata.inst(ic(1)).data.sampint);
                    end
                end
                
                fprintf(smdata.inst(ic(1)).data.inst, 'TRCB? %d, %d, %d', ...
                    [ic(2)-14, smdata.inst(ic(1)).data.currsamp+[0, npts]]);
                val = fread(smdata.inst(ic(1)).data.inst, npts, 'single');
                smdata.inst(ic(1)).data.currsamp =  smdata.inst(ic(1)).data.currsamp + npts;
                
            case 3
                fprintf(smdata.inst(ic(1)).data.inst, 'STRT');

            otherwise
                error('Operation not supported');
        end
        
    otherwise
        switch ic(3) % action
            case 1 % set
                if ic(2)==17
                    val = SR830sensindex(val);
                elseif ic(2)==18
                    val = SR830tauindex(val);
                end
                fprintf(smdata.inst(ic(1)).data.inst, sprintf('%s %f', cmds{ic(2)}, val));
            case 0 % get
                val = query(smdata.inst(ic(1)).data.inst, sprintf('%s? %s',...
                    cmds{ic(2)}(1:4), cmds{ic(2)}(5:end)), '%s\n', '%f');
                if ic(2)==17
                    val = SR830sensvalue(val);
                elseif ic(2)==18
                    val = SR830tauvalue(val);
                end

            otherwise
                error('Operation not supported');
        end
end

function val = SR830sensvalue(sensindex)
% converts an index to the corresponding sensitivity value for the SR830
% lockin.
x = [2e-9 5e-9 10e-9];
sensvals = [x 1e1*x 1e2*x 1e3*x 1e4*x 1e5*x 1e6*x 1e7*x 1e8*x 1e9*x];
val = sensvals(sensindex+1);

function sensindex = SR830sensindex(sensval)
% converts a sensitivity to a corresponding index that can be sent to the
% SR830 lockin.  rounds up (sens = 240 will become 500)
x = [2e-9 5e-9 10e-9];
sensvals = [x 1e1*x 1e2*x 1e3*x 1e4*x 1e5*x 1e6*x 1e7*x 1e8*x 1e9*x];
sensindex = find(sensvals >= sensval,1)-1;

function val = SR830tauvalue(tauindex)
% converts an index to the corresponding sensitivity value for the SR830
% lockin.
x = [10e-6 30e-6];
tauvals = [x 1e1*x 1e2*x 1e3*x 1e4*x 1e5*x 1e6*x 1e7*x 1e8*x 1e9*x];
val = tauvals(tauindex+1);

function tauindex = SR830tauindex(tauval)
% converts a time constant to a corresponding index that can be sent to the
% SR830 lockin.  rounds up (tau = 240 will become 300)
x = [10e-6 30e-6];
tauvals = [x 1e1*x 1e2*x 1e3*x 1e4*x 1e5*x 1e6*x 1e7*x 1e8*x 1e9*x];
tauindex = find(tauvals >= tauval,1)-1;
        
