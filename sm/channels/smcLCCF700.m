function val = smcLCCF700(ico,~,~)
% Fetch the temperature from a Leiden Cryogenics fridge (hackier old method) 
%function val = smcLCCF700(ico,val,~)
%   fetch the temperature from a leiden cryogenics fridge
%   requires that the fridge computer log to a file that can be read
%   smdata.inst(xx).data.fname has the base name for the file (settable in
%   the LC temperature control program)
%   also requires that both computers be on the same timezone!
%   will return temperatures in mK, use rangeramp(4) to set units
%   will only be as accurate as the update rate (usually 1 min) of the
%   leiden program
global smdata;
timeout = 25200; % in seconds. emit a warning if the last line is older than this 7 hrs to account for time between us and laptop.
val = 0; 
switch ico(3)
    case 0
        dind = 0;
%         while ~strcmp(datestr(now-dind,'d'),'M')
%             dind = dind+1;
%         end
        while ~exist([smdata.inst(ico(1)).data.fname,datestr(now-dind,'yyyy-mm-dd'),'.dat'],'file')
           dind = dind+1; 
        end
        fname = [smdata.inst(ico(1)).data.fname,datestr(now-dind,'yyyy-mm-dd'),'.dat'];
        fid = fopen(fname,'r');
        if fid<0
           error('unable to open file %s',fname) 
        end
        % the next bunch of lines pull the last line of the file
        tline = fgets(fid);
        lastln = tline;
        while true
            tline = fgets(fid);
            if ischar(tline)
                lastln = tline;
            else
                break
            end
        end
        fclose(fid); %important!
        Ts = str2double(lastln);
        %changed from Ts(12:16) to this. its more robust.
        % find the last time T < 0. After this they make sense
        Ts = Ts(1+find(Ts<0,1,'last'):end);
        %Ts = Ts(12:16);
        %disp(lastln);
        % check when the last update to the file was
        if 60*60*24*abs(datenum(lastln(1:19))-now) > timeout
           warning('last line in file is %.0d seconds old',60*60*24*abs(datenum(lastln(1:19))-now)); 
        end
        switch ico(2)
            case {1,2,3,4,5}
                val = Ts(ico(2));
            otherwise
                error('invalid channel')
        end
    otherwise
        error('only read operations supported');
end
end