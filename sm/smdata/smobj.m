function inst=smobj(type,number,smnumber,drvr,extraInfo)
% Create new instrument objects in your smdata rack 
% function smobj(type,number,smnumber,drvr)
% type can be tcpip, tcpipVisa, serial, gpib (through visa), usb, or visa. 
% seemingly can't set port number with visa-tcpip, so tcpip sometimes
% necessary. 
% number: ip address for tcpip, com # for serial, gpib # for gpib/visa, 
% usb is the model number/serial number/ etc. string. Need to improve. 
% smnumber adds object to that smdata.inst(smnumber). You can also give the
% device name or instrument name. 
% drvr is optional: for visa/gpib, will have either ni or agilnent. if not
% given, chooses first installed. 
% visa creates a generic visa object, you need to provide full command string.
% extraInfo provides anything extra -- perhaps in the future this can be a
% list of options for configuring instruments. Right now, acts as port number for tcpip. 

global smdata
if ~exist('extraInfo','var'), extraInfo = ''; end
visaObj = {'tcpipVisa','gpib','visa','usb'};
if any(strcmp(type,visaObj)) % For visa, check which drivers installed. 
    if ~exist('drvr','var') || isempty(drvr)
        installedDrivers = instrhwinfo('visa');
        if ~isempty(installedDrivers)
            drvr = installedDrivers.InstalledAdaptors{2};
        else
            error('No VISA drivers installed');
        end
    end
end

switch type
    case 'tcpipVisa'         
         inst = visa(drvr,sprintf('TCPIP::%s::INSTR',number)); % or gpib1?=        
    case 'tcpip'
        if isempty(extraInfo)
            inst = tcpip(number);
        else % extraInfo is the port number, not always necessary. 
            inst = tcpip(number,extraInfo);
        end
    case 'serial'
        inst =  serial(sprintf('COM%d',number));
    case 'gpib'        
        drvrInfo = instrhwinfo('visa',drvr);
        boardIndex = drvrInfo.InstalledBoardIds(1);
        inst = visa(drvr,sprintf('GPIB%d::%d::INSTR',boardIndex,number)); % or gpib1?
    case 'visa'       
        inst = visa(drvr,number);
    case 'usb' % this probably doesn't quite work. 
        inst = visa(drvr,sprintf('USB0::%s::INSTR',number));        
end
if ~exist('smnumber','var'), smnumber = length(smdata.inst)+1; end
if ~isempty(smnumber)
    smnumber =sminstlookup(smnumber);
    smdata.inst(smnumber).data.inst=inst;
end
    
end