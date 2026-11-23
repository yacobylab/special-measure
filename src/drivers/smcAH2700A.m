function [val, rate] = smcAH2700A(ico, val, rate)
%SMCAH2700A  Special Measure (smdata) control function for the AH2700A bridge.
%   [VAL, RATE] = SMCAH2700A(ICO, VAL, RATE) reads from or writes to the
%   Andeen-Hagerling AH2700A ultra-precision capacitance bridge over GPIB
%   (visadev). It is registered as smdata.inst(i).cntrlfn and is invoked by
%   smget/smset/smrun; it is not normally called directly.
%
%   Inputs:
%     ICO  - 1x3 index [instrument channel operation]; operation 0 = get,
%            1 = set.
%     VAL  - value to write on a set; ignored on a get.
%     RATE - ramp rate (unused; accepted for the smdata calling convention).
%
%   Outputs:
%     VAL  - value read on a get; unchanged on a set.
%     RATE - unchanged.
%
%   The visadev object lives at smdata.inst(ICO(1)).data.inst.
%
%   Channels:
%     1  Cp         get      parallel capacitance             [F]
%     2  Rp         get      parallel resistance, = 1/Gp       [ohm]
%     3  Gp         get      parallel conductance (loss)       [S]
%     4  Tand       get      loss tangent, = Gp/(2*pi*f*Cp)    [-]
%     5  Freq       get/set  frequency used / test frequency   [Hz]
%     6  Vac        get      actual test voltage used          [V]
%     7  AverExp    get/set  averaging exponent                [0..15]
%     8  Vmax       get/set  test-voltage limit (VHighest)     [V]
%     9  Bias       get/set  DC-bias series-R path             [0=OFF 1=ILOW 2=IHIGH]
%    10  CAP_SINGLE get      capacitance, forcing a fresh SINGLE [F]
%
%   Channels 1-6 share ONE measurement. Every set (Freq, AverExp, Vmax, Bias)
%   sends its command, then fires a SINGLE and stores the parsed result in
%   smdata.inst(i).data.m; the gets return that cached reading. CAP_SINGLE also
%   forces a fresh SINGLE and refreshes the cache. A bare get takes a
%   measurement if none is cached yet.
%
%   Assumes the bridge is in UNITS NS with labels ON (configured by AddAH2700A).
%
%   See also ADDAH2700A, SMGET, SMSET, SMRUN.

global smdata;
dev_obj = smdata.inst(ico(1)).data.inst;
chan = ico(2);
op   = ico(3);

switch chan
    case 1 % Cp [F]
        switch op
            case 0
                m = ah2700_cached(ico(1),dev_obj);
                val = m.C;
            otherwise
                error('smcAH2700A: Cp is read-only');
        end

    case 2 % Rp [ohm] = 1/Gp
        switch op
            case 0
                m = ah2700_cached(ico(1),dev_obj);
                val = 1./m.G;
            otherwise
                error('smcAH2700A: Rp is read-only');
        end

    case 3 % Gp [S]
        switch op
            case 0
                m = ah2700_cached(ico(1),dev_obj);
                val = m.G;
            otherwise
                error('smcAH2700A: Gp is read-only');
        end

    case 4 % Tand
        switch op
            case 0
                m = ah2700_cached(ico(1),dev_obj);
                val = m.G./(2*pi*m.F.*m.C);
            otherwise
                error('smcAH2700A: Tand is read-only');
        end

    case 5 % Freq [Hz]
        switch op
            case 0
                m = ah2700_cached(ico(1),dev_obj);
                val = m.F;
            case 1
                writeline(dev_obj, sprintf('FREQUENCY %g', val));
                smdata.inst(ico(1)).data.m = ah2700_single(dev_obj);  % trigger + refresh cache
        end

    case 6 % Vac [V]
        switch op
            case 0
                m = ah2700_cached(ico(1),dev_obj);
                val = m.V;
            otherwise
                error('smcAH2700A: Vac is read-only');
        end

    case 7 % AverExp 0..15
        switch op
            case 0
                r = ah2700_query(dev_obj,'SHOW AVERAGE');
                val = ah2700_grab(r,'AVEREXP\s*=?\s*([0-9]+)');
            case 1
                writeline(dev_obj, sprintf('AVERAGE %d', min(max(round(val),0),15)));
                smdata.inst(ico(1)).data.m = ah2700_single(dev_obj);  % trigger + refresh cache
        end

    case 8 % Vmax [V]
        switch op
            case 0
                r = ah2700_query(dev_obj,'SHOW VOLTAGE');
                val = ah2700_grab(r,'([-+0-9.eE]+)\s*V');
            case 1
                writeline(dev_obj, sprintf('VOLTAGE %g', val));
                smdata.inst(ico(1)).data.m = ah2700_single(dev_obj);  % trigger + refresh cache
        end

    case 9 % Bias 0/1/2
        switch op
            case 0
                r = ah2700_query(dev_obj,'SHOW BIAS');
                if contains(upper(r),'ILOW')
                    val = 1;
                elseif contains(upper(r),'IHIGH')
                    val = 2;
                else
                    val = 0;
                end
            case 1
                modes = {'OFF','ILOW','IHIGH'};
                writeline(dev_obj, ['BIAS ' modes{min(max(round(val),0),2)+1}]);
                smdata.inst(ico(1)).data.m = ah2700_single(dev_obj);  % trigger + refresh cache
        end

    case 10 % CAP_SINGLE  (force a fresh SINGLE, return capacitance, refresh cache)
        switch op
            case 0
                m = ah2700_single(dev_obj);
                smdata.inst(ico(1)).data.m = m;   % overwrite the shared cache
                val = m.C;
            otherwise, error('smcAH2700A: CAP_SINGLE is read-only');
        end
end
end


function m = ah2700_cached(ind, dev_obj)
%AH2700_CACHED  Return the cached AH2700A measurement, taking one if needed.
%   M = AH2700_CACHED(IND, DEV_OBJ) returns the measurement struct cached in
%   smdata.inst(IND).data.m. If nothing is cached yet, it triggers a fresh
%   measurement with AH2700_SINGLE(DEV_OBJ) and caches it first.
%
%   Inputs:  IND     - instrument index into smdata.inst.
%            DEV_OBJ - visadev object for the bridge.
%   Output:  M       - struct with fields C [F], G [S], V [V], F [Hz].
%
%   See also AH2700_SINGLE.
global smdata;
if ~isfield(smdata.inst(ind).data,'m') || isempty(smdata.inst(ind).data.m)
    smdata.inst(ind).data.m = ah2700_single(dev_obj);
end
m = smdata.inst(ind).data.m;
end

function m = ah2700_single(dev_obj)
%AH2700_SINGLE  Trigger one measurement and read the result (blocking).
%   M = AH2700_SINGLE(DEV_OBJ) sends SINGLE and blocks on readline until the
%   bridge returns its result line, then parses it into M. Warns if no
%   capacitance is found (e.g. a timeout or a hard error line). The read must
%   complete within DEV_OBJ.Timeout, which must exceed the averaging time.
%
%   Input:   DEV_OBJ - visadev object for the bridge.
%   Output:  M       - struct with fields C [F], G [S], V [V], F [Hz].
%
%   See also AH2700_PARSE.
writeline(dev_obj, 'SINGLE');
line = readline(dev_obj);
m = ah2700_parse(char(line));
if isnan(m.C)
    warning('smcAH2700A: no capacitance in "%s"', strtrim(char(line)));
end
end

function m = ah2700_parse(line)
%AH2700_PARSE  Parse one AH2700A result line into SI quantities.
%   M = AH2700_PARSE(LINE) extracts frequency, capacitance, loss and voltage
%   from a labelled result line such as
%       F= 1000.0 HZ C= 140.42713 PF L= 0.000121 NS V=15.0 V
%   Labels may be present and '=' becomes '>' on over-range. The loss number
%   is taken as nanosiemens (UNITS NS) and returned as conductance G in S;
%   capacitance is converted pF -> F. Missing fields are returned as NaN.
%
%   Input:   LINE - result line (char).
%   Output:  M    - struct with fields C [F], G [S], V [V], F [Hz].
m.C = NaN; m.G = NaN; m.V = NaN; m.F = NaN;
num = '([-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)';
t = regexp(line,['F[=>]\s*' num],        'tokens','once'); if ~isempty(t), m.F = str2double(t{1});        end
t = regexp(line,['C[=>]\s*' num],        'tokens','once'); if ~isempty(t), m.C = str2double(t{1})*1e-12;  end
t = regexp(line,['L[=>]\s*' num],        'tokens','once'); if ~isempty(t), m.G = str2double(t{1})*1e-9;   end
t = regexp(line,['V[=>]\s*' num '\s*V'], 'tokens','once'); if ~isempty(t), m.V = str2double(t{1});        end
end

function r = ah2700_query(dev_obj, cmd)
%AH2700_QUERY  Send a command and return its single-line response.
%   R = AH2700_QUERY(DEV_OBJ, CMD) writes CMD to the bridge and returns the
%   next response line as a char row vector.
%
%   Inputs:  DEV_OBJ - visadev object for the bridge.
%            CMD     - command string (e.g. 'SHOW AVERAGE').
%   Output:  R       - response line (char).
writeline(dev_obj, cmd);
r = char(readline(dev_obj));
end

function v = ah2700_grab(r, pat)
%AH2700_GRAB  Extract the first numeric token matched by a regexp.
%   V = AH2700_GRAB(R, PAT) returns the first capture group of PAT found in R
%   as a double, or NaN if there is no match.
%
%   Inputs:  R   - text to search (char).
%            PAT - regular expression with one capture group.
%   Output:  V   - parsed number, or NaN.
t = regexp(r, pat, 'tokens', 'once');
v = NaN; if ~isempty(t), v = str2double(t{1}); end
end