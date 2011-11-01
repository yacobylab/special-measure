This directory has the files needed to use the labbrick api from matlab.
Note that the labbrick developers are idiots and have generated a plain-C
API but used C++ linkage so it's difficult to use from outside the C++ environ.

labbrick.lib, labbrick.dll, and labbrick.h in this directory are a
plain C shim library to put in between labbrick and matlab (or any
other nice language).  The source (labbrick.cpp) can be used to generate
the .lib and .dll with free microsoft tools using the incuded batch file.

To build these, use the "visual studio" command prompt icon the free microsoft tools set up.
