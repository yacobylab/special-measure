// Shim file for interfacing to labbrick because they're doofuses
// that don't know how to use extern "C"
// (c) 2010 Oliver Dial

// include file for C shim to labbrick API

#ifdef  __cplusplus
extern "C"
{
#endif
#define LABBRICK_API __declspec(dllexport)
#ifndef VNX_FSYNSTH_API

// ----------- Global Equates ------------
#define MAXDEVICES 64
#define MAX_MODELNAME 32

// ----------- Data Types ----------------

#define DEVID unsigned int


// ----------- Mode Bit Masks ------------

#define MODE_RFON	0x00000010			// bit is 1 for RF on, 0 if RF is off
#define MODE_INTREF	0x00000020			// bit is 1 for internal osc., 0 for external reference
#define MODE_SWEEP	0x0000000F			// bottom 4 bits are used to keep the sweep control bits				


// ----------- Command Equates -----------


// Status returns for commands
#define LVSTATUS int

#define STATUS_OK 0
#define BAD_PARAMETER 0x80010000		// out of range input -- frequency outside min/max etc.
#define BAD_HID_IO    0x80020000		// a failure occurred internally during I/O to the device
#define DEVICE_NOT_READY 0x80030000		// device isn't open, no handle, etc.

// Status returns for DevStatus

#define INVALID_DEVID 0x80000000		// MSB is set if the device ID is invalid
#define DEV_CONNECTED 0x00000001		// LSB is set if a device is connected
#define DEV_OPENED	  0x00000002		// set if the device is opened
#define SWP_ACTIVE	  0x00000004		// set if the device is sweeping
#define SWP_UP		  0x00000008		// set if the device is sweeping up in frequency
#define SWP_REPEAT	  0x00000010		// set if the device is in continuous sweep mode

// Internal values in DevStatus
#define DEV_LOCKED	  0x00000020		// used internally by the dll
#define DEV_RDTHREAD  0x00000040

#endif

LABBRICK_API  void lb_SetTestMode(int testmode);
LABBRICK_API  int lb_GetNumDevices();
LABBRICK_API  int lb_GetDevInfo(DEVID *ActiveDevices);
LABBRICK_API  int lb_GetModelName(DEVID deviceID, char *ModelName);
LABBRICK_API  int lb_InitDevice(DEVID deviceID);
LABBRICK_API  int lb_CloseDevice(DEVID deviceID);
LABBRICK_API  int lb_GetSerialNumber(DEVID deviceID);
LABBRICK_API  int lb_GetDeviceStatus(DEVID deviceID);


LABBRICK_API  LVSTATUS lb_SetFrequency(DEVID deviceID, int frequency);
LABBRICK_API  LVSTATUS lb_SetStartFrequency(DEVID deviceID, int startfrequency);
LABBRICK_API  LVSTATUS lb_SetEndFrequency(DEVID deviceID, int endfrequency);
LABBRICK_API  LVSTATUS lb_SetFrequencyStep(DEVID deviceID, int frequencystep);
LABBRICK_API  LVSTATUS lb_SetDwellTime(DEVID deviceID, int dwelltime);
LABBRICK_API  LVSTATUS lb_SetPowerLevel(DEVID deviceID, int powerlevel);
LABBRICK_API  LVSTATUS lb_SetRFOn(DEVID deviceID, int on);
LABBRICK_API  LVSTATUS lb_SetUseInternalRef(DEVID deviceID, int internal);
LABBRICK_API  LVSTATUS lb_SetSweepDirection(DEVID deviceID, int up);
LABBRICK_API  LVSTATUS lb_SetSweepMode(DEVID deviceID, int mode);
LABBRICK_API  LVSTATUS lb_StartSweep(DEVID deviceID, int go);
LABBRICK_API  LVSTATUS lb_SaveSettings(DEVID deviceID);
LABBRICK_API  int lb_GetFrequency(DEVID deviceID);
LABBRICK_API  int lb_GetStartFrequency(DEVID deviceID);
LABBRICK_API  int lb_GetEndFrequency(DEVID deviceID);
LABBRICK_API  int lb_GetDwellTime(DEVID deviceID);
LABBRICK_API  int lb_GetFrequencyStep(DEVID deviceID);
LABBRICK_API  int lb_GetRF_On(DEVID deviceID);
  LABBRICK_API  int lb_GetRFOn(DEVID deviceID); // fix an inconsistency in the idiot's api.
LABBRICK_API  int lb_GetUseInternalRef(DEVID deviceID);
LABBRICK_API  int lb_GetPowerLevel(DEVID deviceID);
LABBRICK_API  int lb_GetMaxPwr(DEVID deviceID);
LABBRICK_API  int lb_GetMinPwr(DEVID deviceID);
LABBRICK_API  int lb_GetMaxFreq(DEVID deviceID);
LABBRICK_API  int lb_GetMinFreq(DEVID deviceID);

#ifdef  __cplusplus
}
#endif
