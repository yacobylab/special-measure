function ret=lbLoadLibrary2()
% Load the lab brick driver library.  Return true on success.
ret = true;
if ~libisloaded('vnx_fsynth')  
    p=strrep(which('smcLabBrick'),'smcLabBrick.m','labbrick') ;    
    libname = '\SDK\vnx_fsynth.dll'; 
    headname = '\SDK\vnx_LSG_api.h'; 
    loadlibrary([p libname],[p headname]);        
    if ~libisloaded('vnx_fsynth')
        ret=false;
    end
end