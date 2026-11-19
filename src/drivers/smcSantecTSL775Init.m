function tsl = smcSantecTSL775Init(visa_address)
% Open a visa() GPIB connection (old VISA API, so smopen can reopen it).
tsl = visa('ni', visa_address);
tsl.Timeout = 5;
fopen(tsl);
fprintf('TSL-775 connected: %s\n', strtrim(query(tsl, '*IDN?')));
fprintf(tsl, ':WAV:SWE 0');     % stop any sweep: :WAV sets are refused while one runs
fprintf(tsl, ':POW:UNIT 0');    % power in dBm
fprintf(tsl, ':POW:ATT:AUT 1'); % auto power control: holds output power as wavelength changes
fprintf(tsl, '*CLS');
% Output state is left untouched; turn it on with smset('Output_TSL', 1).
end
