function smobj(type,number,smnumber,drvr)
%function smobj(type,number,smnumber,drvr)
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
%                drvr = installedDrivers{1};
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
                drvr = installedDrivers{1};
            else
                error('No VISA drivers installed');
            end
        end
        smdata.inst(smnumber).data.inst = visa(drvr,number);        
end
end