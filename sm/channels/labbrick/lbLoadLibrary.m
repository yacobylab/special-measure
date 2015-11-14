function ret=lbLoadLibrary()
% Load the lab brick driver library.  Return true on success.
ret = true;
if ~libisloaded('hidapi')
    
    p=strrep(which('smcLabBrick'),'smcLabBrick.m','labbrick') ;
    if strcmpi(computer('arch'), 'win64')
        libname='\i64\hidapi';
    else
        libname='\i32\hidapi';
    end
    loadlibrary([p libname '.dll'],[p libname '.h'],'alias','hidapi');
        
    if ~libisloaded('hidapi')
        ret=false;
    end
end