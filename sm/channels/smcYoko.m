function val = smcYoko(ic, val, rate)
% 1: direct set
% 2: ramped (readout same)

global smdata;


switch ic(3);
    case 2    
        % compute remaining ramp time
        val(1) = query(smdata.inst(ic(1)).data.inst, 'OD', '%s\n', '%*4c%f');
        query(smdata.inst(ic(1)).data.inst, 'OP', '%s\n');
        val(2) = fscanf(smdata.inst(ic(1)).data.inst, '%*5c%f');
        
        while smdata.inst(ic(1)).data.inst.BytesAvailable > 0
            fscanf(smdata.inst(ic(1)).data.inst);
        end
        
        val = abs(diff(val)/rate);
    case 1
        switch ic(2)
            case 1
                fprintf(smdata.inst(ic(1)).data.inst, 'S %f E', val);
            case 2
                %set rate, start value?
                curr = query(smdata.inst(ic(1)).data.inst, 'OD', '%s\n', '%*4c%f');

                if rate == 0
                    if abs(curr - val) < abs(val)*1e-4
                        val = 0;
                        return
                    else
                        error('Cannot ramp at zero rate.');
                    end
                end
                
                rt = round(10 * min(abs((curr - val)/rate), 3600))/10;

                cmd = sprintf('PI%.1f SW%.1f PRS S%.4e PRE M1', max(rt, .1), rt, val);
                if rate > 0
                    % program and start ramp
                    fprintf(smdata.inst(ic(1)).data.inst, [cmd, 'RU2']);
                else % program only
                    fprintf(smdata.inst(ic(1)).data.inst, cmd);
                end
                val = max(rt, .1);
        end
        
    case 0
        val = query(smdata.inst(ic(1)).data.inst, 'OD', '%s\n', '%*4c%f');
        
    case 3    
        fprintf(smdata.inst(ic(1)).data.inst, 'RU2');
          
    otherwise
        error('Operation not supported');
end

