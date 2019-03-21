function [ret,warnings]=labBrickLoadLibrary
% Load the lab brick driver library.  Return true on success.
ret = true;
if ~libisloaded('vnx_fsynth')  
    libraryPath=strrep(which('smcLabBrick'),'smcLabBrick.m','labbrick') ;    
    dirEnd = strfind(libraryPath,'\'); 
    libraryPath = libraryPath(1:dirEnd(end-1)); 
    libname = 'labbrick\SDK\vnx_fsynth.dll'; 
    headname = 'labbrick\SDK\vnx_LSG_api.h'; 
    [notFound,warnings] = loadlibrary([libraryPath libname],[libraryPath headname]); % notFound is list of functions not found, useful for debugging. 
    if ~libisloaded('vnx_fsynth')
        ret=false;
    end
else
    warnings = ''; 
end