function lenrate = smabufconfig(instruments, npoints, rate, cntrl, inst)
%lenrate = smabufconfig(instruments, npoints, rate, cntrl)
% Set number of datapoints and samplerate for instruments.
% Instruments can be an index vector or string cell array. 
% npoints and rate are updated for each instrument,
% so make sure no inconsistencies result - there should be only
% one "picky" instrument, and it has to come first.
% cntrl: sync: SR830  triggered samplewise
%        trig: SR830 external trigger enabled
%        conffn
global smdata;

if nargin < 4
   cntrl = '';
end

if strfind(cntrl, 'conffn')
   lenrate = instruments;
   instruments = inst; 
end

for i = 1:length(instruments)
    ind = sminstlookup(instruments(i));
    
    switch smdata.inst(ind).device
        
        case 'SR830'        
            if strfind(cntrl, 'sync')
                n = 14;
            else
                n = round(log2(rate)) + 4;
                rate = 2^-(4-n);
                % allow ext trig?
                if n < 0 || n > 13
                    error('Samplerate not supported by SR830');
                end
            end
            if strfind(cntrl, 'trig')
                fprintf(smdata.inst(ind).data.inst, 'REST; SEND 1; TSTR 1; SRAT %i', n);
            else
                fprintf(smdata.inst(ind).data.inst, 'REST; SEND 1; TSTR 0; SRAT %i', n);
            end
            pause(.1);
            smdata.inst(ind).data.currsamp = 0;

            smdata.inst(ind).data.sampint = 1/rate;
            smdata.inst(ind).datadim(15:16, 1) = npoints;
            
        case 'TDS5104'
            fprintf(smdata.inst(ind).data.inst, 'ACQ:STATE 0');
            %fprintf(smdata.inst(ind).data.inst, 'ACQ:STOPA SEQ');
            %fprintf(smdata.inst(ind).data.inst, 'ACQ:STOPA RUNST'); % hack to reset acq
            fprintf(smdata.inst(ind).data.inst,'HOR:POS 10');
            fprintf(smdata.inst(ind).data.inst, 'TRIG:A:HOLD:BY TIME');
            
            fprintf(smdata.inst(ind).data.inst, 'DAT:ENC SRIB');
            fprintf(smdata.inst(ind).data.inst, 'HOR:ROLL OFF');
            fprintf(smdata.inst(ind).data.inst,'HOR:DEL:MOD 0');
            fprintf(smdata.inst(ind).data.inst,'HOR:POS 0');
            fprintf(smdata.inst(ind).data.inst,'TRIG:A:MODE NORM');

            fprintf(smdata.inst(ind).data.inst, 'HOR:MAI:SAMPLER %f', rate);
            if query(smdata.inst(ind).data.inst, 'HOR:MAI:SAMPLER?', '%s\n', '%f') < rate;
                fprintf(smdata.inst(ind).data.inst, 'HOR:MAI:SAMPLER %f', 2* rate);
            end

           
            rate = query(smdata.inst(ind).data.inst, 'HOR:MAI:SAMPLER?', '%s\n', '%f');

            fprintf(smdata.inst(ind).data.inst, 'HOR:RECO %d', npoints);
            if query(smdata.inst(ind).data.inst, 'HOR:RECO?', '%s\n', '%d') < npoints;
                fprintf(smdata.inst(ind).data.inst, 'HOR:RECO %d', 2*npoints);
            end

            npoints = query(smdata.inst(ind).data.inst, 'HOR:RECO?', '%s\n', '%d');
            fprintf(smdata.inst(ind).data.inst, 'DAT:STOP %d', npoints)
            fprintf(smdata.inst(ind).data.inst, 'DAT:START 1');            
            smdata.inst(ind).datadim(1:4, 1) = npoints;
            
            pause(.1); % need a break for rearming. 
            fprintf(smdata.inst(ind).data.inst, 'ACQ:STATE 1');
            smdata.inst(ind).data.nacq(1:4) = query(smdata.inst(ind).data.inst, 'ACQ:NUMAC?', '%s\n', '%d');

            
        case 'HP34401A'
            samptime = .035; % minumum time per sample for dmm - heuristic and mode dependent

            if 1/rate < samptime
                trigdel = 0;
                rate = 1/samptime;
            else
                trigdel = 1/rate - samptime;
            end

            if npoints > 512
                error('More than 512 samples not supported by DMM. Correct and try again!\n');
            end
            fprintf(smdata.inst(ind).data.inst, 'TRIG:SOUR BUS');
            %fprintf(smdata.inst(ind).data.inst, 'VOLT:NPLC 1'); %integrate 1 power line cycle
            fprintf(smdata.inst(ind).data.inst, 'SAMP:COUN %d', npoints);
            fprintf(smdata.inst(ind).data.inst, 'TRIG:DEL %f', trigdel);
            smdata.inst(ind).datadim(2, 1) = npoints;
        
        case 'LeCroy'
            
            fprintf(smdata.inst(ind).data.inst, 'CFMT DEF9,BYTE,BIN;CORD LO;');
            
            sp = floor(50002/npoints);
            npoints = ceil(50002/sp);
            fprintf(smdata.inst(ind).data.inst, 'WFSU SP, %d', sp);

            fprintf(smdata.inst(ind).data.inst, 'TDIV %f', npoints /(rate * 10));
            tdiv = query(smdata.inst(ind).data.inst, 'TDIV?', '%s\n', '%*4c %f %*c');

            %if tdiv < % check for modifications of tdiv.
            rate = npoints / (tdiv * 10);

            smdata.inst(ind).datadim(1:4, 1) = npoints;

        case 'ATS660'
            
            %smdata.inst(ind).cntrlfn() %needs channel info -> revise
            %concept.
            smcATS660v2([ind, 1, 5], npoints, rate);
            
        case -1;
            rngtab = [.2 .4 .8, 2, 5, 8, 16
                       6, 7, 9,11,12,14, 18];
            for ch = 1:2
                [m, rng] = min(abs(rngtab(1, :) - smdata.inst(ind).data.rng(ch)));
                daqfn('InputControl', smdata.inst(ind).data.handle, ch, 2, rngtab(2, rng), ...
                    2-logical(smdata.inst(ind).data.highZ(ch)));
                smdata.inst(ind).data.rng(ch) = rngtab(1, rng);
            end
            
            if smdata.inst(ind).data.samprate >0
                downsamp = floor(smdata.inst(ind).data.samprate/rate);
                rate = smdata.inst(ind).data.samprate;
            else
                downsamp = 1;
            end
            
            rate = rate/1e6;
            dec = floor(130/rate);
            rate = max(min(130, round(rate * dec)))*1e6;
            daqfn('SetCaptureClock', smdata.inst(ind).data.handle, 7, rate, 0, dec-1); % external
            rate = rate/dec;
                         
            npoints = floor(min(npoints*downsamp, 2^23)/downsamp);
            daqfn('SetRecordSize', smdata.inst(ind).data.handle, 0, max(ceil(npoints*downsamp/16)*16, 128));
            smdata.inst(ind).datadim(1:2) = npoints;
            
            smdata.inst(ind).data.downsamp = downsamp;
            rate = rate/downsamp;

            smdata.inst(ind).data.nrec = 0;
    end
end
if isempty(strfind(cntrl, 'conffn'))
    lenrate = [npoints, rate];
end