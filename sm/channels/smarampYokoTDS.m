function scan = smarampYokoTDS(scan)

global smdata;



tds = sminstlookup('TDS5014'); % assumes there is only one
yokos = smchaninst(scan.loops(1).setchan); % assumes no other ramped device


sampler = 1/abs(scan.loops(1).ramptime);

% encode as int
fprintf(smdata.inst(tds).data.inst, 'DAT:ENC SRIB');
fprintf(smdata.inst(tds).data.inst, 'HOR:MAI:SAMPLER %f', sampler);
if query(smdata.inst(tds).data.inst, 'HOR:MAI:SAMPLER?', '%s\n', '%f') < sampler;
    fprintf(smdata.inst(tds).data.inst, 'HOR:MAI:SAMPLER %f', 2* sampler);
end

sampler = query(smdata.inst(tds).data.inst, 'HOR:MAI:SAMPLER?', '%s\n', '%f');
scan.loops(1).ramptime = -1/sampler;

fprintf(smdata.inst(tds).data.inst, 'HOR:RECO %d', scan.loops(1).npoints);
if query(smdata.inst(tds).data.inst, 'HOR:RECO?', '%s\n', '%d') < scan.loops(1).npoints;
    fprintf(smdata.inst(tds).data.inst, 'HOR:RECO %d', 2*scan.loops(1).npoints);
end

scan.loops(end).npoints = query(smdata.inst(tds).data.inst, 'HOR:RECO?', '%s\n', '%d');
fprintf(smdata.inst(tds).data.inst, 'DAT:STOP %d', scan.loops(1).npoints)
fprintf(smdata.inst(tds).data.inst, 'DAT:START 1');

smdata.inst(tds).datadim(1:4, 1) = scan.loops(1).npoints;

%tds = smdata.channels(tds).instchan(1);


scan.loops(1).trigfn.fn = @smatrigYokoTDS;
scan.loops(1).trigfn.args = {tds, yokos(:, 1)};


%fprintf(TDS,'DAT:STAR 1')
%fprintf(TDS,'DAT:STOP %d', datadim)

    