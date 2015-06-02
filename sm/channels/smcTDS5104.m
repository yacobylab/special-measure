function val = smcTDS5104(ico, val, rate)

global smdata;


switch ico(3)                
    case 0
       
        %byten = query(TDS, 'WFMO:BYT_N?', '%s\n', '%d');
        if ico(2) <= 4
            fprintf(smdata.inst(ico(1)).data.inst, 'DAT:SOU CH%i', ico(2));
            while smdata.inst(ico(1)).data.nacq(ico(2)) < Inf && ...
                smdata.inst(ico(1)).data.nacq(ico(2)) >= query(smdata.inst(ico(1)).data.inst, 'ACQ:NUMAC?', '%s\n', '%d');
                pause(.02);
            end

            fprintf(smdata.inst(ico(1)).data.inst, 'CURV?');

            %ndig = fscanf(smdata.inst(ico(1)).data.inst, '#%d', 2);
            %nbyte = fscanf(smdata.inst(ico(1)).data.inst, '%d', ndig);
            ndig = sscanf(char(fread(smdata.inst(ico(1)).data.inst, 2)'), '#%d');
            nbyte = sscanf(char(fread(smdata.inst(ico(1)).data.inst, ndig)'), '%d');
            npts = smdata.inst(ico(1)).datadim(ico(2), 1);

            val = fread(smdata.inst(ico(1)).data.inst, npts, sprintf('int%d', nbyte/npts*8));

            fscanf(smdata.inst(ico(1)).data.inst);

            scale(1) =  query(smdata.inst(ico(1)).data.inst,'WFMP:YMU?', '%s\n', '%f');
            scale(2) =  query(smdata.inst(ico(1)).data.inst,'WFMP:YOFF?', '%s\n', '%f');
            scale(2) =  scale(2) - query(smdata.inst(ico(1)).data.inst,'WFMP:YZE?', '%s\n', '%f')/scale(1);


            val = (val-scale(2)) * scale(1);

            if smdata.inst(ico(1)).data.nacq(ico(2)) < Inf
                smdata.inst(ico(1)).data.nacq(ico(2)) = query(smdata.inst(ico(1)).data.inst, 'ACQ:NUMAC?', '%s\n', '%d');
            end
        else
            val = query(smdata.inst(ico(1)).data.inst, sprintf('MEASU:MEAS%d:VAL?', ico(2)-4), '%s\n', '%f');
        end
        
    case 3
        fprintf(smdata.inst(ico(1)).data.inst, 'TRIG FORCE');
        
    otherwise
        error('Operation not supported');
end
