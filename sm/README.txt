Quick reference
===============

Configuration display routines:
-------------------------------
smprintchannels: Print channel information
smprintinst:	 Print instrument information
smprintrange:    Print range and rate information.

Setup
-----
smaddchannel: Create a new channel
sminitdisp:   Configure  figure 1001 to display current channel values.
	      To disable this feature, close figure 1001.

Wrapper for instrument control functions:
-----------------------------------------
smopen:   Open instruments.
smclose:  Close instruments.
smprintf: Wrapper for fprintf.
smscanf:  Wrapper for fscanf.
smquery:  Wrapper for query.

Main measurement routine:
-------------------------
smrun

Setting and getting channel values:
-----------------------------------
smset:  Set channel values.
smget:  Read channel values.

Scan configuration:
-------------------
smdiagpar: Configure scan rotation
smscanpar: Set scan range and resolution
smprintscan: Print scan parameters.

Other routines, mainly used internally:
---------------------------------------
smdispchan:   update display of current values)
smchanlookup: Translation from channel name to index)
sminstlookup: Translation form device name to index)
smchaninst:   get instrument associated with a channel)
	

Auxiliary functions:
--------------------
Configuration and control of specific instruments:

smarampYokoSR830dmm: Set up linewise acquisition with dmm and/or lockin.
smarampYokoSR830:    Subset of above, no dmm support
smarampYokoTDS:      Set up linewise acquisition with TDS5104.
smaDMMsnglmode:	     Restore default sample parameters for DMM(s).
smastopYokos:	     Stop ramps on Yokos.

Trigger routines (used as trigfn's):
smatrigYokoSR830dmm 
smatrigYokoTDS
smatrigYokoSR830     (Obsolete, no longer maintained)
smatrig

smalintrafo: Set up a rotated scan.


Configuration data
------------------

scan.disp:
disp.channel (refering to channels stored for the time being)
disp.loop
disp.dim

smdata:
configch
configfn
chandisph
chanvals

smdata.channels
	instchan   [instrument index, channel index w.r.t. instrument's
		   channels]
	rangeramp: First two elements are lower and upper limit. 
		   Third element determines ramp rate (in 1/s). 
		   4th element is the conversion factor.
        name	   Channel name (string).
		   



Detailed explanations
=====================

Instruments and channels
------------------------

Each hardware device is represented by an instrument (not to be confused with
MATLAB instrument objects) that containes information about how to control it
and what channels (see below) it provides. This information roughly corresponds
to the hardcoded instrument drivers and channel array in Labview SM.


The channel concept is very similar to that of Labview SM - each channel 
represents some parameter, input or output value of an instrument.
In most cases, it will be some physical quantity.
There is currently no distinction between write and read channels. 
All channels should support a read operation, but it is 
up to the user to make sure that channels that do not support write operations
(typically acqusition devices) are not used as set channels.
Writeable channels should always accept and return a single double, but 
read-only channels can also return matrices of arbitrary dimension - e.g. 
a vector representing a complete scan line.
Writeable channels can be self ramping, in which case its variable can be 
ramped by the corresponding instrument. If available, this feature is always 
used to set channel values (function smset), and can also be used for 
measurements. 

Information about instruments, channels (i.e. the rack) and other 
configuration is stored in the global struct smdata. Channels and 
instruments are stored in the struct array smdata.channels and smdata.inst.
Major changes to smdata.inst are only required when adding new instruments 
or updating drivers, but it may occasionally be necessary to change certain
instrument parameters, such as the data dimension for read channels.



Specifying instruments and channels
-----------------------------------
Internally, channels and instruments are identified by their indices
to the struct arrays smdata.inst and smdata.channels.  These indices
(printed at the beginning of each line by smprintchannels and
smprintinst can also be used to specify channels and instruments in
function arguments, including scan definition. Alternatively, channel
and instruments names can be used. Lists of names can be given as a
char arrays or cell vectors of strings. The conversion from names to
indices is typically done with smchanlookup and sminstlookup.
Channel names should always be unique. Instruments can be called by their
instrument type identifier (smdata.inst().device, e.g. SR830) if there is only
one such instrument in the rack, or an optional name, which should be unique
amongst instrument types and names. Instruments with a name should generally
be called by that name.

Startup
-------
To set up a MATLAB session for running SM, proceed as follows:
- You need an instrument control toolbox.
- Make sure the sm and sm/channels directories are in the path.
- Make smdata accessible from the workspace by typing
"global smdata;" This is necessary only once per Matlab session, or after 
a "clear global" command.
- Load a rack from a MATLAB (.mat) file, e.g. 
  "load z:/qDots/sm_config/smdata_base".
  (At the moment, Quantum Dot racks can be found in ~ygroup/qDots/sm_config).
- Open instruments with smopen. (Assuming they follow the standard convention
  discussed in section "Writing instrument drivers".)

Occasionally, it may be necessary to close and reopen instruments, for example
in order to change certain properties such as the buffer size.
For instruments following the standard convention, this can be done with
smclose and smopen.

Adding and removing channels
----------------------------
To add a channel, use the smaddchannel function. Note that depending
on the instrument, further configuration may be necessary.
(Particularly for channels to be ramped for data taking, or matrix-valued
channels).

To remove one or several channels ch, just type "smdata.channels(ch) = [];"
Note that this will change the indices of all subsequent channels.

 
Displaying configuration
------------------------
Use the smprint* function to display the most important configuration
information.


Displaying the current channel values
-------------------------------------
The current values of all scalar channels can be displayed in figure 1001
if this figure is initialized by calling "sminitdisp". The displayed values
will be updated by every call of smget and smset for each channel.
To disable this feature, close figure 1001.


Specifying a scan
-----------------
The measurement task to be excecuted by smrun is defined by a struct passed
to smrun. For explanations of its fields, see the help of smrun.
Note that some of the parameters are optional.



Confguring the display
----------------------
What data is displayed is defined in the disp field of the scan definition 
struct. disp is a struct array with the fields listed below. Each element
of disp describes one subplot to be displayed in the data window (Figure 1000).

fields of disp:

loop: loop during which to update display.
dim: dimension of data to be disp or 2 for plot or false color image.
channel: Data channel to be shown. This is an index to all channels
	 stored (i.e. those listed in loops(l).getchan for any loop l),
	 starting with the slowest loop(?). If all channels are read in the 
	 same loop l, channel is simply the index of loops(l).getchan;


Ramping channels
----------------
A writeable channel ch on instrument inst with
smdata.inst(inst).type(ch) set to 1 is considered as a ramping
channel, i.e. smset assumes that the device can autonomously generate
ramps. This feature is always used to change the value of the channel.
The maximum and default ramp rate is stored in smdata.

Ramps are also be used for measurements if scan.loops(i).ramptime < 0
In this latter case, smrun (the main measurement routine) only sets
the channel to the initial value and programs the endpoint of a ramp
and the ramp rate and then (optionally) 
calls a trigger function to initiate a ramp. 


Transformation functions:
-------------------------

Channel transformation functions compute the channel value to be set
from the independent variables and other channel values.
Their first argument is a vector with the loop variables,
starting with the innermost loop.
the second one the current value of all channels, as stored in 
smdata.chanvals. Those values are only updated by calls to 
smset or smget. Channels returning arrays are not stored there.

Example:
scan .loops(1).trafofn{2} = @(x,y) (x(1)-2) * .2 + y(3);

The global transformation functions are applied to the independent variables
before the channel specific transformations. Currently, their only argument
is the loop variable vector.



Writing instrument drivers
---------------------------

Adding new instruments consists of two parts: writing a control function
and specifying the instrument information in smdata.inst, a struct array 
with the following fields:

cntrlfn  : Function handle of the control function
data     : instrument specific data. An open MATLAB instrument object
	   representing the instrument should be stored in data.inst,
	   if applicable.
datadim  : array with non-singleton data dimensions for each channel
	   (no entry needed for singleton dimensions)
type	 : channel type, one element for each channel.
	   set to 1 if a channel uses programmed ramps.
channels : channel names (char array)
device   : string with instrument indentifier.
name	 : optional name to distinguish different instruments of 
	   the same type.


Control functions
-----------------
All communications with an instrument occurs through calls of 
smdata.inst().cntrlfn, which has the following calling convention:

val = cntrlfn([inst, channel, operation], val, rate)

inst and channel are the instrument and channel indices. Operation
determines what the function should do.

0: read channel value. No further argument given. The return value can be 
   matrix with the  dimensions given in smdata.inst(inst).datadim(channel, :).
1: set channel value to val. Rate argument will be given for channels with ramp
   functionality. The return value val should be the expected 
   time required to complete the ramp to the set point.
2: query remaining ramp time. Ramp rate used to program the last ramp is
   given in rate. This functionality is not used by smset (or anywhere else) 
   at the time of writing.
3: trigger previously programmed ramp.
4: Arm acquisition device (optional)
5: Configure acquisition device (optional)
   See smcATS660v2.m for examples on usage of 4 and 5.

If rate < 0 for ramped channels, a ramp is used in a measurement. In this
case, the ramp should only be programmed and started later by a separate
trigger function (see "Ramping channels").

How instruments are stored and addressed by the control function 
is in principle arbitrary. However, I would recommend to follow the 
convention that GPIB, serial, VISA, and similar instruments (i.e. those
controlled via the instrument control toolbox) be represented 
by an instrument object stored in in smdata.inst().data.inst, which is
always kept open. smopen, smclose, smprintf, smscanf and smquery only 
work for instruments following this convention.

For simple examples that can be adapted see for example smcHP1000A.m
or smctemplate.m, which is intended to be a starting point for writing new 
drivers. 


Pseudocode for smrun:
---------------------

Set constant channels

Call configfn

Main loop
     for loops needing update (outer first)
     	 Set values and/or program ramps
	 call prefn
	 wait
	 trigger ramped channels if needed
     end

     for loops needing readout (inner first)
     	 read data
	 apply procfn
	 display data
	 save data if needed
	 call postfn
	 call datafn
     end
end

save data.


Specifying user functions in scan
---------------------------------
Functions lists to be exectuted at various points
(prefn, postfn, datafn, procfn, trigfn) can be specified as 
cell arrays of function handles or struct arrays with fields fn
(function handle) and args (cell array with user arguments to be passed).
For more details, see auxiliary function fncall at the end of smrun.m.





