function smobj(type,number,smnumber,drvr)
%function smobj(type,number,smnumber,drvr)
% Create new instrument objects in your smdata rack 
% type can be tcpip, serial, gpib, or visa. 
% number: ip address for tcpip, com # for serial, gpib # for gpib/visa 
% smnumber adds object to that smdata.inst(smnumber)
% drvr is optional: for visa/gpib, will have either ni or agilnent. if not
% given, chooses first installed. 
% Currently for gpib just uses visa. 

global smdata
switch type
    case 'tcpip'
%         if ~exist('drvr','var') || isempty(drvr)
%             installedDrivers = instrhwinfo('visa');
%             if ~isempty(installedDrivers)
%                 drvr = installedDrivers{1};
%             else
%                 error('No VISA drivers installed');
%             end
        %end
        smdata.inst(smnumber).data.inst = tcpip(number);
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