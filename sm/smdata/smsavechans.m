function smsavechans(file)
% Save all channels from smdata to file.
% function smsavechans(file)


global smdata;
channels = smdata.channels;
save(['smchan_', file], 'channels');
end

   