function val = smcLCCF700v2(ico,val,~)
%function val = smcLCCF700(ico,val,~)
%   Fetch the temperature from a Leiden Cryogenics fridge
%   Requires that the fridge computer log to a file that can be read
%   (if logs aren't appearing, likely the Fridge computer is not on the
%   server). 
%   smdata.inst(xx).data.fname has the base name for the file (settable in
%   the LC temperature control program)
%   also requires that both computers be on the same timezone!
%   will return temperatures in mK, use rangeramp(4) to set units
%   will only be as accurate as the update rate (usually 1 min) of the
%   leiden program
%   Can only read. 
global smdata;
timeout = 120; % in seconds. emit a warning of the last line is older than this
val = 0;
switch ico(3)
    case 0 
        if isfield(smdata.inst(ico(1)).data,'fpath')
            dirData = dir(smdata.inst(ico(1)).data.fpath);
            fnames = [dirData.name];
            fmatch=regexp(fnames,[smdata.inst(ico(1)).data.fpattern '(\d+)-(\d+)-(\d+).dat'],'match');
            fstr = char(fmatch);
            fname = fstr(end,:);
            fname = [smdata.inst(ico(1)).data.fpath fname]; 
        else
            dind = 0;
            while ~exist([smdata.inst(ico(1)).data.fname,datestr(now-dind,'yyyy-mm-dd'),'.dat'],'file')
                dind = dind+1; 
            end
            fname = [smdata.inst(ico(1)).data.fname,datestr(now-dind,'yyyy-mm-dd'),'.dat'];
        end
        
        
        fid = fopen(fname,'r');
        if fid < 0
            error('Unable to open file %s',fname)
        end
        
        %the first 6 lines are formatting, fgets skips pointer in file past
        %them. 
        for i = 1:7 
            fgets(fid);
        end
        
        %Format of data will be: 3 dates, 3 times (y-m-d, h:m:s), 1 big number we skip, 8
        %resistances, 8 temperatures, Then zeros (possibly the last two
        %sensors?
        sizeArr = [26 Inf];
        formatSpec = '%d-%d-%d %d:%d:%d %*f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';          
        data = fscanf(fid, formatSpec, sizeArr);
        tempData = data(7:end,end); %contains resistances and temps. 
        dateData = data(1:6,end)'; 
        fclose(fid); %important!
        temps = tempData(9:16);
        % check when the last update to the file was. datenum / now are in
        % units of days. 
        if 60*60*24*abs(datenum(dateData)-now) > timeout
           warning('Last line in file is %.0d seconds old \n',60*60*24*abs(datenum(dateData)-now)); 
        end
        switch ico(2)
            case {1,2,3,4,5,6,7,8,9}
                val = temps(ico(2));
            otherwise
                error('Invalid channel')
        end
    otherwise
        error('Only read operations supported');
end

end

