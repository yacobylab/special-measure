function plotAgilNA(~,data,freqLim) 
data = data{1}; 
szData = size(data);

if length(szData)==3 
    data = squeeze(reshape(data,szData(1),numel(data)/szData(1))); 
else 
    fprintf('Doesn''t work for this dimension \n'); 
end

freqs = linspace(freqLim(1),freqLim(2),size(data,end));
figure(12); clf; 
plot(freqs,data) 
end