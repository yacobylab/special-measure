function val = smcCoarseStep(ic, val, rate)
%This is a driver for the coarse positioning of the SPM tip.
%
%The Bx command (x = 0, 1, or 2) corresponds to choosing the slot for 
%   DecaDAC use.
%The M2 command sets the output to 4-channel
%The Cx command (x = 0, 1, 2, or 3) corresponds to choosing the channel 
%   within the slot.
%The Dx command (0 < x < 65535) sets the voltage to be applied by the DAC.
%The d command returns the last data written to the selected channel.
%
%Channel numbers and corresponding movements:
%   1: -x
%   2: +x
%   3: -y
%   4: +y
%   5: Retract
%   6: Approach
%   7: SET grounding relay
%   8: Power supply for the relay box
%
%
%General pseudocode of the program:
%   Zero SET bias, followed by zeroing other applied biases (e.g. to the 
%       back gate & sample), and Ground SET    
%   Perform coarse steps
%   Unground SET, return SET bias to original value, followed by returning 
%       other systems (e.g. back gate and sample) to their original biases
%
%More detailed instructions will be added later.
    
%To do: set SET to ramp (1-2s time); Fix time left; Fix readout.



%% Set important variables
global smdata;
global smscan;

SETramp=0.1; %Ramp speed of SET
BGSramp=0.1; %Ramp speed of other components
Vfive=49151; %Corresponds to +5 V
Vzero=32768; %Corresponds to 0 V
pausetime=.200; %Length of square wave in seconds
rng = smdata.inst(ic(1)).data.rng(floor((ic(2)-1)/2)+1, :); %Sets the range of the dataset for readout

stepnum=10; %%CHANGE ME LATER!!

%% Perform steps

switch ic(2)
    case {1, 2, 3, 4, 5, 6}
        switch ic(3)
            
%Do we still need an estimate for remaining time if we are only using this
%to perform a sequence of coarse steps?
            case 2
                val = 0;
      
            case 1
                %Get values of SET bias as well as back gate, sample, etc. voltages.
                zerochanvals=cell2mat(smget(smscan.coarsemotors.chans));

                %Set SET bias to 0 in 10 mV steps, followed by setting other component
                %biases to zero in 10 mV steps
                smset(smscan.coarsemotors.chans(1), 0, SETramp);
                smset(smscan.coarsemotors.chans(2:end), 0, BGSramp);

                %Ground SET through relay box.
                dacwrite(smdata.inst(ic(1)).data.inst, sprintf('B%1d;M2;C%1d;D%05d;', 1, 2, Vfive));
                pause(1);

                for j=1:stepnum
                    dacwrite(smdata.inst(ic(1)).data.inst, ...
                       sprintf('B%1d;M2;C%1d;D%05d;', floor((ic(2)-1)/4), mod(ic(2)-1, 4), Vfive));
                    pause(pausetime);
                    dacwrite(smdata.inst(ic(1)).data.inst, ...
                       sprintf('B%1d;M2;C%1d;D%05d;', floor((ic(2)-1)/4), mod(ic(2)-1, 4), Vzero));
                    pause(pausetime);
                end
                
                %Unground SET
                pause(1);
                dacwrite(smdata.inst(ic(1)).data.inst, sprintf('B%1d;M2;C%1d;D%05d;', 1, 2, Vzero))
                pause(1);

                %Set applied voltages back to their original values, SET first, then others
                %simultaneously
                smset(smscan.coarsemotors.chans(1), zerochanvals(1), SETramp);
                smset(smscan.coarsemotors.chans(2:end), zerochanvals(2:end), BGSramp);
           
                
%Case 0 should not be needed for this function, as we are just applying
%voltages to the relay box using the DecaDAC.  Nonetheless, I leave it in
%for now, just in case.
            case 0
%                 val = dacread(smdata.inst(ic(1)).data.inst, ...
%                     sprintf('B%1d;C%1d;d;', floor((ic(2)-1)/4), mod(ic(2)-1, 4)), '%*7c%d');
%                 val = val*diff(rng)/65535 + rng(1);
                
                
            otherwise
                error('Operation not supported');
        end
            
    otherwise
        error('Only six channels are defined for coarse stepping');
end

%% Below are the functions to read and write information to a DecaDAC
function dacwrite(inst, str)
try
    query(inst, str);
catch
    fprintf('WARNING: error in DAC communication. Flushing buffer.\n');
    while inst.BytesAvailable > 0
        fprintf(fscanf(inst));
    end
end

%Again, we likely don't need the dacread function.
function val = dacread(inst, str, format)
if nargin < 3
    format = '%s';
end

j = 1;
while j < 10
    try
        val = query(inst, str, '%s\n', format);
        j = 10;
    catch
        fprintf('WARNING: error in DAC communication. Flushing buffer and repeating.\n');
        while inst.BytesAvailable > 0
            fprintf(fscanf(inst));
        end

        j = j+1;
        if j == 10
            error('Failed 10 times reading from DAC')
        end
    end
end