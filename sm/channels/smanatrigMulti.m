function smanatrigMulti(xt, startFreq, stopFreq,inst,opts)
% smanatrig(xt, inst)
% Used to trigger NA if not using internal trigger. 
global smdata
obj = smdata.inst(inst).data.inst;
smset('NAstartFreq', startFreq(xt(1)));
smset('NAstopFreq', stopFreq(xt(1)));

if strfind(opts, 'int')
    fprintf(obj, ':OUTP:STAT ON');
    fprintf(obj, ':TRIG:SOUR INT');
else
    fprintf(obj, ':OUTP:STAT ON'); %turn on the output 
    fprintf(obj, ':TRIG:SOUR BUS'); %inst waits for external trigger
    fprintf(obj, ':INIT1:CONT ON'); %I think we can remove this
    fprintf(obj, ':TRIG:SEQ:SING'); % send a single trigger 
    fprintf(obj, '*OPC?');  %wait until all the data has come in.
    ok=fscanf(obj);
    fprintf(obj, ':OUTP:STAT OFF'); % Turn off the output.
end
end