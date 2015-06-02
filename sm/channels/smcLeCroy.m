function val = smcLeCroy(ico, val, rate)

global smdata;


switch ico(3)                
    case 0
       
        
        fprintf(smdata.inst(ico(1)).data.inst, 'C%i:WF? ALL', ico(2));
        
        %ndig = fscanf(smdata.inst(ico(1)).data.inst, '%*11c%d', 12);
        nbyte = fscanf(smdata.inst(ico(1)).data.inst, '%*12c%d', 21);
        
        data = int8(fread(smdata.inst(ico(1)).data.inst, nbyte, 'int8'));


        offset = typecast(data(37:40), 'int32');
        scale = typecast(data(157:164), 'single');  % GAIN, Offset

        %val = double(data(offset+1:end)) * scale(1) - scale(2);
        %val = double(typecast(data(offset+1:end), 'int16')) * scale(1) - scale(2);
        if typecast(data(33:34), 'int16')
            val = double(typecast(data(offset+1:end), 'int16')) * scale(1) - scale(2);
        else
            val = double(data(offset+1:end)) * scale(1) - scale(2);
        end

    otherwise
        error('Operation not supported');
end
