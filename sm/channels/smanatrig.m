function smanatrig(xt, inst,args)
% smanatrig(xt, inst)
% Used to trigger NA if not using internal trigger. 
global smdata

obj = smdata.inst(inst).data.inst;
fprintf(obj, ':OUTP:STAT ON'); % Turn on the output

if exist('args','var') && ~isempty(args) && isopt(args{1},'trig')
    fprintf(obj, ':TRIG:SOUR BUS'); 
    fprintf(obj, ':TRIG:SEQ:SING'); % Send a single trigger
    fprintf(obj, '*OPC?');  % Wait until all the data has come in.
    ok=fscanf(obj);
    fprintf(obj, ':OUTP:STAT OFF'); % Turn off smpr the output.
else
    fprintf(obj, ':TRIG:SOUR Internal'); % Run continuous mode with no waiting for external trigger
end
end