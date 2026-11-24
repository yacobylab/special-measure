function [val, rate] = smcZIMFIA(ico, val, rate)
%SMCZIMFIA  Special Measure (smdata) control function for the Zurich Instruments MFIA.
%   [VAL, RATE] = SMCZIMFIA(ICO, VAL, RATE) reads from or writes to a Zurich
%   Instruments MFIA impedance analyzer through the LabOne MATLAB API (ziDAQ).
%   It is registered as smdata.inst(i).cntrlfn and is invoked by
%   smget/smset/smrun; it is not normally called directly.
%
%   Inputs:
%     ICO  - 1x3 index [instrument channel operation].
%     VAL  - value to write on a set; for the channel 7 configure op it is the
%            sweep point count.
%     RATE - ramp rate; used by the channel 7 configure op to derive the
%            averaging time (data.tr = 1/rate).
%
%   Outputs:
%     VAL  - value read on a get; unchanged on a set.
%     RATE - unchanged.
%
%   The ziDAQ device id is at smdata.inst(ICO(1)).data.inst; the impedance
%   analyzer index (imp_c) is '0'.
%
%   Channels:
%     1  param0     get      first impedance parameter  (mean of polled sample)
%     2  param1     get      second impedance parameter (mean of polled sample)
%     3  frequency  get/set  test frequency             [Hz]
%     4  amplitude  get/set  drive amplitude            [V]
%     5  bias       get/set  DC bias voltage            [V]
%     6  maxbw      get/set  maximum bandwidth          [Hz]
%     7  biassweep  buffered DC-bias sweep (sweeper module); get returns
%                   [param0 param1]
%
%   Operations:
%     0 get, 1 set, 3 trigger, 4 arm, 5 configure.
%
%   Channels 1 and 2 share one poll: a get returns the cached value if it is
%   newer than 0.1 s, otherwise it polls the impedance sample, averages param0
%   and param1, and caches both (smdata.inst(i).data.p0/.p1/.time) so the
%   device is polled only once per point.
%
%   Channel 7 drives the LabOne sweeper over the DC bias: configure (5) sets
%   the bandwidth/averaging/point count from RATE and VAL, arm (4) builds and
%   subscribes the sweeper, trigger (3) executes it, and get (0) waits for it
%   to finish and returns the [param0 param1] buffer.
%
%   See also SMGET, SMSET, SMRUN.


%Channels
% 1: param 0 
% 2: param 1
% 3: frequency
% 4: amplitude
% 5: bias
% 6: max bw
% 7: bias sweep data 

% operations
% 0: get
% 1: set
% 3: trigger
% 4: arm
% 5: configure

%TODO: 
% implement data storage in smdata so we don't have to get the data twice
% for param 0 and param 1
% implement sweeper module
% get better idea of time constant


global smdata;
device=smdata.inst(ico(1)).data.inst;
imp_c='0'; %impedance analyzer number

switch ico(2) % Channel
    case 1 % param 0
        switch ico(3)
            case 0  % get
                if now-smdata.inst(ico(1)).data.time<0.1/(24*60*60) %the value stored in smdata is still fresh
                    val=smdata.inst(ico(1)).data.p0;
                else
                    imp_c = '0';
                    imp_index = 1;
                    
                    % Subscribe to the impedance sample
                    % The Data Server's node tree uses 0-based indexing; Matlab uses
                    % 1-based indexing:
                    imp_node_path = ['/' device, '/imps/' imp_c '/sample'];
                    ziDAQ('subscribe', imp_node_path);
                    
                    bw=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/maxbandwidth']);
                    tc=1/(2*pi*bw);
                    
                    poll_duration = 10*tc;
                    poll_timeout = 100;
                    
                    %not needed because this code is pretty slow.
                    %pause(poll_duration); %wait for data to accumulate
                    data = ziDAQ('poll', poll_duration, poll_timeout);
                    
                    % Unsubscribe from all paths.
                    ziDAQ('unsubscribe', '*');
                    
                    if ziCheckPathInData(data, imp_node_path)
                        sample = data.(device).imps(imp_index).sample;
                        val=mean(sample.param0);
                        val2=mean(sample.param1);
                        
                    else
                        error(['Poll did not return the expected data (', imp_node_path, ') - data transfer rate is 0?']);
                        val=NaN;
                    end
                    
                    smdata.inst(ico(1)).data.p0=val;
                    smdata.inst(ico(1)).data.p1=val2;
                    smdata.inst(ico(1)).data.time=now;
                end
            otherwise
                error('Operation not supported');
        end

    case 2 % param 1
        switch ico(3)
             case 0  % get
                 if now-smdata.inst(ico(1)).data.time<0.1/(24*60*60) %the value stored in smdata is still fresh
                     val=smdata.inst(ico(1)).data.p1;
                 else
                     imp_c = '0';
                     imp_index = 1;
                     
                     % Subscribe to the impedance sample
                     % The Data Server's node tree uses 0-based indexing; Matlab uses
                     % 1-based indexing:
                     imp_node_path = ['/' device, '/imps/' imp_c '/sample'];
                     ziDAQ('subscribe', imp_node_path);
                     
                     bw=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/maxbandwidth']);
                     tc=1/(2*pi*bw);
                     
                     poll_duration = 10*tc;
                     poll_timeout = 100;
                     
                     %not needed because this code is pretty slow.
                     %pause(poll_duration); %wait for data to accumulate
                     data = ziDAQ('poll', poll_duration, poll_timeout);
                     
                     % Unsubscribe from all paths.
                     ziDAQ('unsubscribe', '*');
                     
                     if ziCheckPathInData(data, imp_node_path)
                         sample = data.(device).imps(imp_index).sample;
                         val=mean(sample.param1);
                         val2=mean(sample.param0);
                     else
                         error(['Poll did not return the expected data (', imp_node_path, ') - data transfer rate is 0?']);
                         val=NaN;
                     end
                     
                     smdata.inst(ico(1)).data.p0=val2;
                     smdata.inst(ico(1)).data.p1=val;
                     smdata.inst(ico(1)).data.time=now;
                 end
            otherwise
                error('Operation not supported');
        end

    case 3 % Frequency
        switch ico(3)
            case 0  %get
                val=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/freq']); % [Hz
            case 1 %set
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/freq'], val); % [Hz]
        end
        
    case 4 % amplitude
        switch ico(3)
            case 0  %get
                val=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/output/amplitude']); % [V]
            case 1 %set
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/output/amplitude'], val); % [V] 
        end

    case 5 % dc bias voltage
        switch ico(3)
            case 0  %get
                val=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/bias/value']); % [V]
            case 1 %set
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/bias/value'], val); % [V] 
        end
        
    case 6 % max bandwidth
        switch ico(3)
            case 0  %get
                val=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/maxbandwidth']); % [Hz]
            case 1 %set
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/maxbandwidth'], val); % [Hz]
        end
        
    case 7 % bias sweep
        switch ico(3)
            case 0 %get
                h=smdata.inst(ico(1)).data.sweeper;
                while ~ziDAQ('finished', h)
                    pause(1);
                end
                tmp = ziDAQ('read', h);
                imp_node_path = ['/' device, '/imps/' imp_c '/sample'];
                if ziCheckPathInData(tmp, imp_node_path)
                    sample = tmp.(device).imps.sample{1};
                    if ~isempty(sample)
                        % Get the parameter 0 and parameter 1 from the data
%                         bias = sample.bias;
                        param0 = sample.param0;
                        param1 = sample.param1;
                        val=[param0 param1];
                    else
                        val=NaN;
                    end
                else
                    val=NaN;
                end
                
                ziDAQ('unsubscribe', '*');
                ziDAQ('clear', h);
                
            case 1 %set
                
            case 3 %trigger
                h=smdata.inst(ico(1)).data.sweeper;                
                ziDAQ('execute', h);                
                
            case 4 %arm        
               
                h = ziDAQ('sweep');
                
                % Lively calculate and update the bandwidth and time constance.
                freq=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/freq']);
                %bw = max(freq/100, 0.1);
                %bw = min(100, bw);
                bw=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/maxbandwidth']);
                
                % Set the maximum bandwidth of imps to updated bw and omega
                % suppression
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/maxbandwidth'], bw);
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/omegasuppression'], smdata.inst(ico(1)).data.omegas)
                
                % Calculate the time constant of the filter
                tc=1/(2*pi*bw);
                
                % Base on the ramp time, determine the # of avg time
                avg=round((smdata.inst(ico(1)).data.tr)/tc);
                
                % Update them in smdata
                smdata.inst(ico(1)).data.bw=bw;   
                smdata.inst(ico(1)).data.avg=avg;
                
                ziDAQ('set', h, 'device', device);
                ziDAQ('set', h, 'gridnode', ['imps/' '0' '/bias/value']);
                
                start=smdata.inst(ico(1)).data.bstart;
                stop=smdata.inst(ico(1)).data.bstop;
                
                if start>stop
                    scan_mode=3; %reverse scan
                    ziDAQ('set', h, 'start', stop);
                    ziDAQ('set', h, 'stop', start);
                else
                    scan_mode=0; %forward scan
                    ziDAQ('set', h, 'start', start);
                    ziDAQ('set', h, 'stop', stop);
                end
                
                ziDAQ('set',h,'scan',scan_mode);
                
                ziDAQ('set', h, 'samplecount', smdata.inst(ico(1)).data.npts);
                ziDAQ('set', h, 'loopcount', 1);
                ziDAQ('set', h, 'xmapping', 0);
                %ziDAQ('set', h, 'scan', 0);
%                 ziDAQ('set', h, 'settling/time', 4* tc);
                ziDAQ('set', h, 'settling/inaccuracy', 0.01); %was 0.00001
                % Find out what is tc? how can we setup properly for tc.
                ziDAQ('set', h, 'averaging/tc', max(smdata.inst(ico(1)).data.avg, 1)); %was 10
                ziDAQ('set', h, 'averaging/time', max(tc, smdata.inst(ico(1)).data.tr));
                ziDAQ('set', h, 'averaging/sample', smdata.inst(ico(1)).data.nsample);
                ziDAQ('set', h, 'bandwidthcontrol', 1);
                ziDAQ('set', h, 'bandwidth', smdata.inst(ico(1)).data.bw); %set the sweeper bandwidth to the maxbw in labone
                ziDAQ('set', h, 'bandwidthoverlap', 0);
                ziDAQ('set', h, 'omegasuppression', smdata.inst(ico(1)).data.omegas);
                %ziDAQ('setDouble', ['/' device '/imps/' imp_c '/output/amplitude'], smdata.inst(ico(1)).data.Vtest)
                smdata.inst(ico(1)).data.sweeper=h;
                
%                 print(ziDAQ('getDouble', h, 'averaging/sample'));
%                 print(ziDAQ('getDouble', h, 'averaging/time'));
%                 print(ziDAQ('getDouble', h, 'averaging/sample'));
%                 print(ziDAQ('getDouble', h, 'averaging/tc'));

                
                h=smdata.inst(ico(1)).data.sweeper;
                imp_node_path = ['/' device, '/imps/' imp_c '/sample'];
                ziDAQ('subscribe', h, imp_node_path);
                
            case 5 %configure
                % How we set the bandwidth
                bw=ziDAQ('getDouble', ['/' device '/imps/' imp_c '/maxbandwidth']);
                tc=1/(2*pi*bw);
                % 1/rate = t_ramp, 
                avg=round((1/rate)/tc);
%                 srate = ziDAQ('getDouble', ['/' device '/imps/' imp_c '/demod/rate']);
                smdata.inst(ico(1)).data.tr=1/rate;
                smdata.inst(ico(1)).data.avg=avg;
                smdata.inst(ico(1)).data.npts=val;
                smdata.inst(ico(1)).data.bw=bw;      
%                 smdata.inst(ico(1)).data.srate=srate;
                smdata.inst(ico(1)).datadim(7) = 2*val;
                
                % change the imps range controler to manual mode
                % 0 = Manual, 1 = auto
                %ziDAQ('setDouble', ['/' device '/imps/' imp_c '/auto/inputrange'], 0);
                %ziDAQ('setDouble', ['/' device '/imps/' imp_c '/current/range'], 10.0000e-06); %used to be 1e-6
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/voltage/range'], 3);
                % turn on the 
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/output/on'], 1);
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/output/range'], 1);%Changed to 1 by DIO
                ziDAQ('setDouble', ['/' device '/imps/' imp_c '/bias/enable'], 1);
%                 
%                 h = ziDAQ('sweep');
%                 ziDAQ('set', h, 'device', device);
%                 ziDAQ('set', h, 'gridnode', ['imps/' '0' '/bias/value']);
%                 ziDAQ('set', h, 'start', smdata.inst(ico(1)).data.bstart);
%                 ziDAQ('set', h, 'stop', smdata.inst(ico(1)).data.bstop);
%                 ziDAQ('set', h, 'samplecount', val);
%                 ziDAQ('set', h, 'loopcount', 1);
%                 ziDAQ('set', h, 'settling/time', 0);
%                 ziDAQ('set', h, 'averaging/tc', avg);
%                 ziDAQ('set', h, 'averaging/sample', 10);
%                 ziDAQ('set', h, 'bandwidthcontrol', 1);
%                 ziDAQ('set', h, 'bandwidth', bw); %set the sweeper bandwidth to the maxbw in labone
%                 ziDAQ('set', h, 'bandwidthoverlap', 0);
%                 smdata.inst(ico(1)).data.sweeper=h;
%                 smdata.inst(ico(1)).datadim(7) = val;

                
            otherwise
                error('Operation not supported');
        end
end

end
        
