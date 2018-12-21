function [ret,warnings]=labBrickLoadLibrary
% Load the lab brick driver library.  Return true on success.
ret = true;
if ~libisloaded('vnx_fsynth')  
    p=strrep(which('smcLabBrick'),'smcLabBrick.m','labbrick') ;    
    libname = '\SDK\vnx_fsynth.dll'; 
    headname = '\SDK\vnx_LSG_api.h'; 
    [notFound,warnings] = loadlibrary([p libname],[p headname]); % notFound is list of functions not found, useful for debugging. 
    if ~libisloaded('vnx_fsynth')
        ret=false;
    end
end