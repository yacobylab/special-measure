// Shim file for interfacing to labbrick because they're doofuses
// that don't know how to use extern "C"

// (c) 2010 Oliver Dial
#include "labbrick.h"
#include "vnx_fsynsth.h"

void lb_SetTestMode(int t) { fnLSG_SetTestMode(t); };
int lb_GetNumDevices() { return fnLSG_GetNumDevices(); };

// This file sorely abuses the C preprocessor to write shim functions.
// never look at it.
#define IDF(name) int lb_##name(DEVID d) { return fnLSG_##name(d);};

int lb_GetDevInfo(DEVID *d) { return fnLSG_GetDevInfo(d); };
IDF(InitDevice);
IDF(CloseDevice);
IDF(GetSerialNumber);
IDF(GetDeviceStatus);

int lb_GetModelName(DEVID d, char *m) { return fnLSG_GetModelName(d,m); };


#define LDF(name) LVSTATUS lb_##name(DEVID d) { return fnLSG_##name(d);};

#define LDIF(name) LVSTATUS lb_##name(DEVID d, int i) { return fnLSG_##name(d,i);};

LDIF(SetFrequency);
LDIF(SetStartFrequency);
LDIF(SetEndFrequency);
LDIF(SetFrequencyStep);
LDIF(SetDwellTime);
LDIF(SetRFOn);
LDIF(SetUseInternalRef);
LDIF(SetSweepDirection);
LDIF(SetSweepMode);
LDIF(StartSweep);

LDF(SaveSettings);
IDF(GetFrequency);
IDF(GetStartFrequency);
IDF(GetEndFrequency);
IDF(GetDwellTime);
IDF(GetFrequencyStep);
IDF(GetRF_On);
int lb_GetRFOn(DEVID d) { return lb_GetRF_On(d); };
IDF(GetUseInternalRef);
IDF(GetPowerLevel);
IDF(GetMaxPwr);
IDF(GetMinPwr);
IDF(GetMaxFreq);
IDF(GetMinFreq);

LDIF(SetPowerLevel);
