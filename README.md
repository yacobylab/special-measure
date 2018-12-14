# special-measure
Yacoby Lab Special Measure
Currently information on running the program is in the Wiki. 
We will try to get a better readme up soon. 

Note that we overhauled things in commit e3dd925 (6/21/2018), so if your codes have broken, you will want to revert to before that. 
This has a pretty big set of changes. We have removed a number of old versions of drivers in order to make it clear which codes are the current "active" version. We have also changed some names to not use acronyms if the full words aren't too long. The main change is the labbricks, where the standard driver uses the lab brick SDK, referred to as labBrick. The old driver using hid is now labeled with labBrickHID. 
We are trying to add more "sma" files (auxiliary) that let you change the instrument settings without use of smrun. 
We are in the process of adding information to each driver about how to create an instrument in smdata for each driver. 
We have begun adding a list of drivers to the wiki, which will eventually list the files that are being actively used in the Yacoby group (and hence effort is made to keep them running, and to keep improving them) and those which are not. 
