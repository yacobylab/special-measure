function smanatrig(xt, inst)
% smanatrig(xt, inst)
% Used to trigger NA if not using internal trigger. 
global smdata

obj = smdata.inst(inst).data.inst;
fprintf(obj, ':OUTP:STAT ON'); % Turn on the output

fprintf(obj, ':TRIG:SOUR BUS'); 
%fprintf(obj, ':TRIG:SOUR Internal'); %LYY 2018: run continuos mode with no waiting for external trigger

fprintf(obj, ':INIT1:CONT ON'); %I think we can remove this

fprintf(obj, ':TRIG:SEQ:SING'); % Send a single trigger 

fprintf(obj, '*OPC?');  % Wait until all the data has come in.
ok=fscanf(obj);
fprintf(obj, ':OUTP:STAT OFF'); % Turn offsmpr the output.
end