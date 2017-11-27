function smobj(type,number,smnumber,drvr,extraInfo)
% Create new instrument objects in your smdata rack 
%function smobj(type,number,smnumber,drvr)
% type can be tcpip, serial, gpib, or visa. 
% number: ip address for tcpip, com # for serial, gpib # for gpib/visa 
% smnumber adds object to that smdata.inst(smnumber)
% drvr is optional: for visa/gpib, will have either ni or agilnent. if not
% given, chooses first installed. 
% Currently for gpib uses visa. 
% visa just creates a generic visa object -- I guess useful for 
% for tcpip does not use visa (this may cause issues, we can adjust later).
% extraInfo provides anything extra -- perhaps in the future this can be a
% list of options for configuring instruments. 
% Right now, acts as port number for tcpip. 

global smdata
if ~exist('extraInfo','var'), extraInfo = ''; end
switch type
    case 'tcpip'
          if ~exist('drvr','var') || isempty(drvr)
              installedDrivers = instrhwinfo('visa');
              if ~isempty(installedDrivers)
                  drvr = installedDrivers{1};
              else
                  error('No VISA drivers installed');
              end
          end
         smdata.inst(smnumber).data.inst = visa(drvr,sprintf('TCPIP::%s::INSTR',number)); % or gpib1?=        
%        if ~isempty(extraInfo) 
%            smdata.inst(smnumber).data.inst = tcpip(number);
%        else % if extraInfo given, it is the port number. 
%            smdata.inst(smnumber).data.inst = tcpip(number,extraInfo);
%        end
    case 'serial'
        smdata.inst(smnumber).data.inst =  serial(sprintf('COM%d',number));
    case 'gpib'
        if ~exist('drvr','var') || isempty(drvr)
            installedDrivers = instrhwinfo('visa');            
            if ~isempty(installedDrivers)
                drvr = installedDrivers.InstalledAdaptors{1};
            else
                error('No VISA drivers installed');
            end                                 
        end
        drvrInfo = instrhwinfo('visa',drvr);
        boardIndex = drvrInfo.InstalledBoardIds(1);
        smdata.inst(smnumber).data.inst = visa(drvr,sprintf('GPIB%d::%d::INSTR',boardIndex,number)); % or gpib1?
    case 'visa'
        if ~exist('drvr','var') || isempty(drvr)
            installedDrivers = instrhwinfo('visa');
            if ~isempty(installedDrivers)
                drvr = installedDrivers.InstalledAdaptors{1};
            else
                error('No VISA drivers installed');
            end
        end
        smdata.inst(smnumber).data.inst = visa(drvr,number);        
end
end