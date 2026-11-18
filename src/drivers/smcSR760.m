function [val, rate] = smcSR760(ico, val, rate)
% driver for SR760 spectrum analyzer
% ico is a three element vector. ico(1) is the instrument number. ico(2) is
% the channel number. ico(3) is the operation.
% channels for this instrument:
% 1: spectrum
% 2: min frequency
% 3: max frequency
% 4: num of avg
% 5: df
% 6: input range
% 7. measurement type
% general operation codes are
% 0: get
% 1: set
% 2: get buffered data
% 3: trigger
% 4: arm
% 5: configure
% ramping not yet configured for this device.
global smdata;

inst = smdata.inst(ico(1)).data.inst;

switch ico(2) % 
    case 1 %spectrum
        switch ico(3)
            case 0 %get
                
                %pause to make sure the buffer is cleared
                %04/30/2026 LSD: pause time is unnecessary since 'STRT'
                %will reset the SR760 anyway. didn't measure any changes
                %with and without it.
                % 11/17/2026 JRM: I am finding this is necessary after all.
                % The first aquisition takes half as long as the aquisition
                % time and I found changing the signal just before
                % aquisition led to bad results
                pause(smdata.inst(ico(1)).data.pause);

                if smdata.inst(ico(1)).data.pause<10 %
                    warning('Pause probably too short.')
                end
                
                fprintf(inst,'STRT'); %start measurement
                while 1
                    stat=query(inst,'*STB?');
                    stat=str2num(stat);
                    if stat==16 %measurement ongoing
                        pause(0.5)
                    elseif stat==17 %measurement finished, get spectrum
                        val=query(inst,'SPEC?1'); 
                        val=str2num(val);
                        break
                    else
                        ermsg=strcat('Please check instrument settings. Stat = ',num2str(stat));
                        warning(ermsg);
                        pause(2)
                    end   
                end
            otherwise
                error('Operation not supported');
        end
        
    case 2 %min frequency
        switch ico(3)
            case 0 %get
                val=query(inst,'STRF?');
                val=str2num(val);
            case 1 %set
                set=strcat('STRF',num2str(val));
                fprintf(inst,set);
            otherwise
                error('Operation not supported');
        end
        
    case 3 %max frequency
        switch ico(3)
            case 0 %get
                cen=query(inst,'CTRF?'); %central frequency
                mini=query(inst,'STRF?'); %min frequency
                val=2*str2num(cen)-str2num(mini); %calculate max frequency
            otherwise
                error('Operation not supported');
        end
    
    case 4 %number of average
        switch ico(3)
            case 0 %get
                val=query(inst,'NAVG?');
                val=str2num(val);
            case 1 %set
                set=strcat('NAVG',num2str(val));
                fprintf(inst,set);
            otherwise
                error('Operation not supported');
        end
        
    case 5 %df
        switch ico(3)
            case 0 %get
                val=query(inst,'SPAN?');
                val=str2num(val);
                val=0.191*2^val/400;
            otherwise
                error('Operation not supported');
        end
        
    case 6 %input range
        switch ico(3)
            case 0 %get
                val=query(inst,'IRNG?');
                val=str2num(val);
                val=10^(val/10);
            otherwise
                error('Operation not supported');
        end
        
%     case 7 %measurement type
%         switch ico(3)
%             case 0%get
%                 val=query(inst,'MEAS?');
%                 val=str2num(val);
%                 if val==0 %spectrum
%                     val='Spectrum';
%                 if val==1 %PSD
%                    val='PSD';
%                 elseif val==2 %time
%                     val='Time';
%                 elseif val==3 %octave
%                     val='Octave'
%                 else
%                     ermsg=strcat('Please check instrument settings.');
%                         error(ermsg);
%                 end
%             case 1 %set
%                 if val=='Spectrum' %spectrum
%                     val=0;
%                 elseif val=='PSD' %%PSD
%                     val=1;
%                 elseif val=='Time' %time
%                     val=2;
%                 elseif val=='Octave' %octave
%                     val=3;
%                 set=strcat('MEAS', num2str(val));
%                 fprintf(inst,set);
%                 end
%            otherwise
%                 error('Operation not supported');
%         end
end

end 
