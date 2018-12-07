echo This batch file should be run under the windows 7.1 SDK command prompt.
echo after calling setenv /x86 /Release
cl -o labbrick.dll labbrick.cpp vnx_fsynsth.lib  /link /DLL

