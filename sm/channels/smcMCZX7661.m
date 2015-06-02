function val = smcMCZX7661(ico,val,~)
    %function val = smcMCZX7661(ico,val,~)
    % control minicircuits digital step attenuators with the NI-USB6501
    % smdata.inst(xx).data should have:
        % session: matlab data acquisition session
        % config: struct array with fields:
        %   atten: attenuation of each line
        %   line: e.g. 'port0/line2' on the USB device
        %   val: 0 for off, 1 for on
    % the NI USB doesn't allow reading the values, so the values are always
    % cached in smdata.inst(xx).data.config.val
    % ico(3) = 0: read
    % ico(3) = 1: set
    % ico(3) = 4: config- look for the usb device, make a new session, set
        % up the session with channels etc.
   global smdata;
   if ico(2)~=1
       error('channel must be = 1');
   end
    switch ico(3)
       case 0
           val = sum([smdata.inst(ico(1)).data.config().val].*[smdata.inst(ico(1)).data.config().atten]);
       case 1
           if val > sum(ones(size(smdata.inst(ico(1)).data.config())).*[smdata.inst(ico(1)).data.config().atten])
              val =  sum(ones(size(smdata.inst(ico(1)).data.config())).*[smdata.inst(ico(1)).data.config().atten]);
           end
           if val < min([smdata.inst(ico(1)).data.config.atten])
              val = 0; 
           end
           bits = false(1,length(smdata.inst(ico(1)).data.config));
           [attens, ii]=sort([smdata.inst(ico(1)).data.config.atten],'descend');
           for j = 1:length(attens)
               if j==1
                  bits(j)= (val>attens(j)); 
               else
                   bits(j) = (val-bits(1:j-1)*attens(1:j-1)')>=attens(j);
               end
           end
           bits = bits(ii);
           for j= 1:length(bits)
              smdata.inst(ico(1)).data.config(j).val = bits(j); 
           end
           outputSingleScan(smdata.inst(ico(1)).data.session,[0,bits]);
           outputSingleScan(smdata.inst(ico(1)).data.session,[1,bits]);
           pause(smdata.inst(ico(1)).data.pause);
           outputSingleScan(smdata.inst(ico(1)).data.session,[0,bits]);
           
        case 4
           %set up a matlab data acquisition session
           devices = daq.getDevices();
           d = [];
           for j= 1:length(devices)
               if strcmp(devices(j).Model,'USB-6501')
                  d = [d,j]; 
               end
           end
            if length(d)~=1
               error('looking for one NI-USB device, found %i\n',length(d)); 
            end
           clear smdata.inst(ico(1)).data.session;
           warning('off','daq:Session:onDemandOnlyChannelsAdded');
           smdata.inst(ico(1)).data.session = daq.createSession('ni');
           smdata.inst(ico(1)).data.session.addDigitalChannel(devices(d).ID,...
                   smdata.inst(ico(1)).data.latch,'OutputOnly');
           for j = 1:length(smdata.inst(ico(1)).data.config)
               smdata.inst(ico(1)).data.session.addDigitalChannel(devices(d).ID,...
                   smdata.inst(ico(1)).data.config(j).line,'OutputOnly');
           end
           %set(smdata.inst(ico(1)).data.session.Channels,'Direction','Output');
           warning('on','daq:Session:onDemandOnlyChannelsAdded')
           outputSingleScan(smdata.inst(ico(1)).data.session,[0,[smdata.inst(ico(1)).data.config.val]]);
           outputSingleScan(smdata.inst(ico(1)).data.session,[1,[smdata.inst(ico(1)).data.config.val]]);
           pause(smdata.inst(ico(1)).data.pause);
           outputSingleScan(smdata.inst(ico(1)).data.session,[0,[smdata.inst(ico(1)).data.config.val]]);
       otherwise
            error('operation not supported');
   end
end
