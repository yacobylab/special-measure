// LSGTest_64.cpp : Test and Demo program for the 64 bit ANSI-C style LSG DLL
//
//	Based on LMS test program, RD 10/2013
//
//	RD 4/16/2016 LSG 64 bit DLL
//	RD 4/1/2017 V1.00 LSG 64 bit DLL release


#include "stdafx.h"

#include "vnx_LSG_api.h"

// ------------------------------- Equates -----------------------------------------------
#define VT_DWP_BIDIRECTIONAL	0x08	// MASK: bit = 1 for bi-directional sweeping
#define VT_SWP_DIRECTION		0x04	// MASK: bit = 0 for sweep up, 1 for sweep down 
#define VT_SWP_CONTINUOUS		0x02	// MASK: bit = 1 for continuous sweeping
#define VT_SWP_ONCE				0x01	// MASK: bit = 1 for single sweep


// ------------------------------- Allocations -------------------------------------------

static DEVID MyDevices[MAXDEVICES];				// I have statically allocated this array for convenience
												// It holds a list of device IDs for the connected devices
												// They are stored starting at MyDevices[0]

static char MyDeviceNameA[MAX_MODELNAME];		// NB -- this is a single byte char array for testing the ASCII name function
static wchar_t MyDeviceNameW[MAX_MODELNAME];	// NB -- this is a WCHAR array for testing the Unicode name function

static wchar_t errmsg[32];					// For the status->string converter
static char cModelName[32];					// buffer for the model name


static string sDevName = "LSG-103";			// device name string
static bool gbWantOneDevice = FALSE;

static long DevNum = 0;						// which device we should work with

static string sDevFrequency = "";
static long Frequency = 50000;				// default test frequency 5 GHz (in 100Khz units)

static string sDevFStart = "";
static long FStart = 50000;					// default test start frequency (in 100Khz units)

static string sDevFStop = "";
static long FStop = 60000;					// default test stop is 6 Ghz (in 100KHz units)

static string sDevFStep = "";
static long FStep = 100;					// default sweep step is 10 Mhz (in 100KHz units)

static string sDevDwellT = "";
static long DwellTime = 100;				// default dwell time at each frequency step is .1 second

static string sDevAtten = "";
static long Atten = 0;						// default attenuation is 0db, encoding is in .25 db steps

static string sDevPower = "";
static long Power = 4;						// sets output power level, relative to device's max calibrated power
											// it is in units of .25 db of attenuation - 00 is the largest signal

static long SerialNumber = 0;				// used to hold the serial number for the get serial number command

static int RefOsc = 0;						// really used as a bool -- if non zero, then we use the internal osc.

static int RFOnOff = 1;						// really used as a bool -- if non zero, turn on the RF output

static int Sweep_mode = 0;					// a variable to hold the user's desired sweep mode
static int GetParam = 0;					// the low byte is the GET command byte



bool gbWantSetFrequency = FALSE;
bool gbWantSetFStart = FALSE;
bool gbWantSetFStop = FALSE;
bool gbWantSetFStep = FALSE;
bool gbWantSetDwellTime = FALSE;
bool gbWantStartSweep = FALSE;
bool gbWantSetAtten = FALSE;
bool gbWantSetPower = FALSE;
bool gbWantSaveSettings = FALSE;
bool gbWantSetSerialNum = FALSE;
bool gbWantGetParam = FALSE;
bool gbGotReply = FALSE;
bool gbWantMaxPower = FALSE;
bool gbBatchMode = FALSE;
bool gbWantSetRefOsc = FALSE;
bool gbWantSetRFOnOff = FALSE;


// ------------------------------- Support Routines --------------------------------------

void PrintHelp()
{

	printf("\n");
	printf(" --- Overall modes and device selection. Defaults to first device if device not selected ---\n");
	printf("\n");
	printf("  -b        Batch mode, exit after sending commands\n");
	printf("  -d        Device Number -- 1 to NDevices\n");
	printf("\n");

	printf(" --- Commands to set parameters and start sweep --- \n");

	printf("  -f nn     Set frequency, nn is frequency in 1 Hz (1.0e9 for 1GHz) units\n");
	printf("  -s nn     Set sweep start frequency, nn is start frequency in native 100 KHz units\n");
	printf("  -e nn     Set sweep end frequency, nn is end frequency in native 100 KHz units\n");
	printf("  -i nn     Set sweep frequency step, nn is step increment in native 100 KHz units\n");
	printf("  -t nn     Set the time to dwell on each sweep step, nn is time in ms.\n");
	printf("  -p nn     Set output power, nn is output power in db ,\n");
	printf("             in .25 db steps. 1 db = 4, -10 db = -40 \n");
	printf("  -g n      Start a sweep, 1 = once upwards, 2 = continuous upwards\n");
	printf("             5 = once down, 6 = continuous down, 0 = end sweep\n");
	printf("  -o n      Select the reference oscillator to use -- 1 = internal, 0 = external\n");
	printf("  -r n      Turn the RF output on or off -- 1 = on, 0 = off\n");
	printf("\n");
	printf("  -y        Write user settings to flash\n");
	printf("            Hit CTRL+C to exit\n");
	printf("\n");
	printf("\n");


}

// --------------------- MakeLower ------------------------------

wchar_t MakeLowerW(wchar_t &wc)
{
	return wc = towlower(wc);
}

// --------------------------------------------------------------

#define MAX_MSG 32

/* A function to display the status as a Unicode string */
wchar_t* fnLSG_perror(LVSTATUS status) {
	wcscpy_s(errmsg, MAX_MSG, L"STATUS_OK");
	if (BAD_PARAMETER == status) wcscpy_s(errmsg, MAX_MSG, L"BAD_PARAMETER");
	if (BAD_HID_IO == status) wcscpy_s(errmsg, MAX_MSG, L"BAD_HID_IO");
	if (DEVICE_NOT_READY == status) wcscpy_s(errmsg, MAX_MSG, L"DEVICE_NOT_READY");

	// Status returns for DevStatus
	if (INVALID_DEVID == status) wcscpy_s(errmsg, MAX_MSG, L"INVALID_DEVID");
	if (DEV_CONNECTED == status) wcscpy_s(errmsg, MAX_MSG, L"DEV_CONNECTED");
	if (DEV_OPENED == status) wcscpy_s(errmsg, MAX_MSG, L"DEV_OPENED");
	if (SWP_ACTIVE == status) wcscpy_s(errmsg, MAX_MSG, L"SWP_ACTIVE");
	if (SWP_UP == status) wcscpy_s(errmsg, MAX_MSG, L"SWP_UP");
	if (SWP_REPEAT == status) wcscpy_s(errmsg, MAX_MSG, L"SWP_REPEAT");
	if (SWP_BIDIRECTIONAL == status) wcscpy_s(errmsg, MAX_MSG, L"SWP_BIDIRECTIONAL");

	return errmsg;

}





// ---------- ParseCommandLine ----------------------------------------------- 

// ParseCommandLine() will return FALSE to indicate that we received an invalid
// command or should abort for another reason.

bool ParseCommandLine(int argc, _TCHAR *argv[])
{
	enum {
		wantDash, wantDevNumber, wantFrequency, wantFStart, wantFStop, wantDwellT,
		wantFStep, wantAtten, wantPower, wantIndex, wantHiLo, wantSerialNum, wantSweep,
		wantGetParam, wantMaxPower, wantSetRFOnOff, wantSetRefOsc
	} state = wantDash;

	for (int i = 1; i < argc; ++i) {
		// Convert each argument to lowercase
		wstring thisParam(argv[i]);
		for_each(thisParam.begin(), thisParam.end(), MakeLowerW);

		// if we're looking for a command, handle the - before the command letter
		if (state == wantDash)
		{
			if ('-' != thisParam[0])
			{
				printf("\n *** Error in command line syntax *** \n");
				PrintHelp();
				return FALSE;
			}
			// remove the dash from the front of the string
			thisParam = wstring(thisParam.begin() + 1, thisParam.end());

			// Identify the arguments
			if (L"d" == thisParam) {
				// -d should be followed by a number
				state = wantDevNumber;
			}
			else if (L"b" == thisParam) {
				gbBatchMode = TRUE;
			}
			else if (L"f" == thisParam) {
				gbWantSetFrequency = TRUE;
				state = wantFrequency;
			}
			else if (L"s" == thisParam) {
				gbWantSetFStart = TRUE;
				state = wantFStart;
			}
			else if (L"e" == thisParam) {
				gbWantSetFStop = TRUE;
				state = wantFStop;
			}
			else if (L"t" == thisParam) {
				gbWantSetDwellTime = TRUE;
				state = wantDwellT;
			}
			else if (L"a" == thisParam) {
				gbWantSetAtten = TRUE;
				state = wantAtten;
			}
			else if (L"p" == thisParam) {
				gbWantSetPower = TRUE;
				state = wantPower;
			}
			else if (L"g" == thisParam) {
				gbWantStartSweep = TRUE;
				state = wantSweep;
			}
			else if (L"y" == thisParam) {
				gbWantSaveSettings = TRUE;
				state = wantDash;
			}
			else if (L"q" == thisParam) {
				gbWantGetParam = TRUE;
				state = wantGetParam;
			}
			else if (L"r" == thisParam) {
				gbWantSetRFOnOff = TRUE;
				state = wantSetRFOnOff;
			}
			else if (L"o" == thisParam) {
				gbWantSetRefOsc = TRUE;
				state = wantSetRefOsc;
			}
			else if (L"i" == thisParam) {
				gbWantSetFStep = TRUE;
				state = wantFStep;
			}
			else {
				// this case is for "-h" and any argument we don't recognize
				PrintHelp();
				return FALSE;	// don't continue
			}
		}
		else {
			// assert(state != wantDash);

			// save the whole substring and do conversions for each argument type

			switch (state){

			case wantDevNumber:
				DevNum = _wtoi(thisParam.c_str());
				state = wantDash;	// we always go back to the wantDash state to look for the next arg.
				break;

			case wantFrequency:
				Frequency = (int)(wcstof(thisParam.c_str(), NULL) / 100000);		// convert to a float first...
				state = wantDash;
				break;

			case wantFStart:
				FStart = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantFStop:
				FStop = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantFStep:
				FStep = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantDwellT:
				DwellTime = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantAtten:
				Atten = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantPower:
				Power = (int)(wcstof(thisParam.c_str(), NULL) * 4);		// convert to a float first...
				state = wantDash;
				break;

			case wantSerialNum:
				SerialNumber = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantSweep:
				Sweep_mode = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantSetRFOnOff:
				RFOnOff = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantSetRefOsc:
				RefOsc = _wtoi(thisParam.c_str());
				state = wantDash;
				break;

			case wantGetParam:
				GetParam = _wtoi(thisParam.c_str());
				state = wantDash;
				break;
			}


		}
	}

	if (state != wantDash) {
		// we are expecting an argument, if we didn't get one then print the help message
		PrintHelp();
		return FALSE;
	}

	// It's OK to continue
	return TRUE;
}

// -------------------------------- Program Main -----------------------------------------

int _tmain(int argc, _TCHAR* argv[])
{
	int i, j;
	int itemp;
	bool bTemp;
	float ftemp;
	float fMaxPwr;
	float fMinPwr;
	int status, result;


	float pmod_on, pmod_off, pmod_total;

	printf("Lab Brick Signal Generator Test Program\n");

	if (!ParseCommandLine(argc, argv))
		return 0;

	DevNum = DevNum - 1;
	if (DevNum < 0) DevNum = 0;


	// --- if TestMode = TRUE then the dll will fake the hardware ---
	fnLSG_SetTestMode(FALSE);

	i = fnLSG_GetNumDevices();

	if (i == 0){
		printf("No device found\n");
	}

	if (i == 1){
		printf("Found %d Device\n", i);

	}
	else {
		printf("Found %d Devices\n", i);
	}

	i = fnLSG_GetDevInfo(MyDevices);

	printf("Got Device Info for %d Device[s]\n", i);


	if (i > 0)	// do we have a device? 
	{
		for (j = 0; j < i; j++){

			// --- print out the first device's name ---
			itemp = fnLSG_GetModelNameW(MyDevices[j], MyDeviceNameW);
			wprintf(L"Device %d is an %s \n", i, MyDeviceNameW);

			// --- print out the device's serial number ---
			itemp = fnLSG_GetSerialNumber(MyDevices[j]);
			printf("Device %d has serial number %d \n", i, itemp);


			// --- We need to init the device (open it) before we can do anything else ---
			itemp = fnLSG_InitDevice(MyDevices[j]);

			if (itemp){
				printf("InitDevice returned %x\n", itemp);
			}

			// --- Lets see if we got the device's parameters ---

			itemp = fnLSG_GetStartFrequency(MyDevices[j]);
			printf("Sweep Start Frequency = %d in 100 KHz units\n", itemp);

			itemp = fnLSG_GetEndFrequency(MyDevices[j]);
			printf("Sweep End Frequency = %d in 100 KHz units\n", itemp);

			itemp = fnLSG_GetFrequencyStep(MyDevices[j]);
			printf("Sweep Step Frequency Increment = %d in 100 KHz units\n", itemp);

			itemp = fnLSG_GetDwellTime(MyDevices[j]);
			printf("Dwell Time = %d ms.\n", itemp);

			itemp = fnLSG_GetMinFreq(MyDevices[j]);
			printf("Minimum Frequency = %d in 100 KHz units\n", itemp);

			itemp = fnLSG_GetMaxFreq(MyDevices[j]);
			printf("Maximum Frequency = %d in 100 KHz units\n", itemp);

			itemp = fnLSG_GetMinPwr(MyDevices[j]);
			fMinPwr = itemp * .25;	// we represent power levels in .25db steps
			printf("Minimum Output Power Level = %.2f db\n", fMinPwr);

			itemp = fnLSG_GetMaxPwr(MyDevices[j]);
			fMaxPwr = itemp * .25;	// we represent power levels in .25db steps
			printf("Maximum Output Power Level = %.2f db\n", fMaxPwr);


			// --- Show if the RF output is on ---
			itemp = fnLSG_GetRF_On(MyDevices[j]);

			if (itemp != 0){
				printf("RF ON\n");
			}
			else{
				printf("RF OFF\n");
			}

			// --- Show Ref. Oscillator Source ---
			itemp = fnLSG_GetUseInternalRef(MyDevices[j]);

			if (itemp != 0){
				printf("Using Internal Reference Frequency\n");
			}
			else{
				printf("Using External Reference Frequency\n");
			}


			// --- Show the present output power level using the relative power level function ---
			itemp = fnLSG_GetPowerLevel(MyDevices[j]);
			ftemp = itemp * .25;	// we represent power levels in .25db steps
									// note that this function returns the power setting relative to Maximum Power
			printf("Output Power Level = %.2f db\n", (fMaxPwr - ftemp));

			// --- Show the state ofthe PLL Lock Indicator ---
			itemp = fnLSG_GetDeviceStatus(MyDevices[j]);

			if (itemp & PLL_LOCKED){
				printf("PLL Locked\n");
			}
			else{
				printf("PLL is not in lock\n");
			}


			printf(" --------------------------------- \n");

		} // end of the for loop over the devices


		// ------------- Now we'll set the requested device with new parameters -------------


		if (gbWantSetFrequency)
		{

			printf("Setting Frequency = %d in 100 KHz units\n", Frequency);
			itemp = fnLSG_SetFrequency(MyDevices[DevNum], Frequency);
		}

		// --- and then do whatever else the user requested ---

		if (gbWantSetFStart)
		{
			itemp = fnLSG_SetStartFrequency(MyDevices[DevNum], FStart);
		}

		if (gbWantSetFStop)
		{
			itemp = fnLSG_SetEndFrequency(MyDevices[DevNum], FStop);
		}

		if (gbWantSetFStep)
		{
			itemp = fnLSG_SetFrequencyStep(MyDevices[DevNum], FStep);
		}

		if (gbWantSetDwellTime)
		{
			itemp = fnLSG_SetDwellTime(MyDevices[DevNum], DwellTime);
		}

		if (gbWantSetPower)
		{
			itemp = fnLSG_SetPowerLevel(MyDevices[DevNum], Power);	// note, this function uses absolute power level!
		}

		if (gbWantStartSweep)
		{
			// --- first we'll figure out what the user wants us to do ---
			if (Sweep_mode & VT_SWP_DIRECTION)
			{
				bTemp = FALSE;
			}
			else
			{
				bTemp = TRUE;
			}	// NB -- don't confuse these similarly named VT_ constants for the API constants!!


			itemp = fnLSG_SetSweepDirection(MyDevices[DevNum], bTemp);	// TRUE means sweep upwards for the API

			// --- and now we'll do the mode - one time sweep or repeated sweep ---

			if (Sweep_mode & VT_SWP_ONCE)
			{
				bTemp = FALSE;
			}
			else
			{
				bTemp = TRUE;
			}	// NB -- the flag is the command line arg is not the same as the API constant!!

			itemp = fnLSG_SetSweepMode(MyDevices[DevNum], bTemp);		// TRUE means repeated sweep for the API



			if (!Sweep_mode)
			{
				itemp = fnLSG_StartSweep(MyDevices[DevNum], FALSE);
			}
			else
			{
				printf("Starting a Frequency Sweep\n");
				itemp = fnLSG_StartSweep(MyDevices[DevNum], TRUE);
			}
		}

		if (gbWantSetRFOnOff)
		{

			if (RFOnOff == 0)
			{
				bTemp = FALSE;
			}
			else
			{
				bTemp = TRUE;
			}

			itemp = fnLSG_SetRFOn(MyDevices[DevNum], bTemp);
		}


		if (gbWantSetRefOsc)
		{

			if (RefOsc == 0)
			{
				bTemp = FALSE;
			}
			else
			{
				bTemp = TRUE;
			}

			itemp = fnLSG_SetUseInternalRef(MyDevices[DevNum], bTemp);
		}


		// --- do this last, since the user probably wants to save what he just set ---

		if (gbWantSaveSettings)
		{
			fnLSG_SaveSettings(MyDevices[DevNum]);
		}

		// -- The user wants us to exit right away --

		if (gbBatchMode)
		{
			for (j = 0; j < i; j++)
			{
				itemp = fnLSG_CloseDevice(MyDevices[j]);

			}
			return 0;		// we're done, exit to the command prompt
		}


		// -- Lets hang around some and report on the device's operation

		j = 0;

		while (j < 20)
		{

			itemp = fnLSG_GetFrequency(MyDevices[DevNum]);
			ftemp = ((float) itemp ) / 10;					// the LSG native unit is 100KHz
			printf("Frequency = %.1f MHz\n", ftemp);

			// -- using the GetAbsPowerLevel function to read our absolute output power level ---
			itemp = fnLSG_GetPowerLevelAbs(MyDevices[DevNum]);
			ftemp = itemp * .25;	// we represent power levels in .25db steps
			printf("Output Power Level = %.2f db\n", ftemp);

			Sleep(500);		// wait for 1/2 second

			j++;

		}

		// -- we've done whatever the user wanted, time to close the devices

		printf("Closing devices...\n");

		for (j = 0; j < i; j++)
		{
			itemp = fnLSG_CloseDevice(MyDevices[j]);

		}


	} // end of if ( i > 0 ) -- "we have a device"

	return 0;
}

