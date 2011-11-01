#include "vnx_fsynsth.h"
#include <stdio.h>

int main()
{
  char buf[1024];
  int power;
  DEVID bricks[8];

  printf("Hello, microsofty world!\n");
  printf("I have %d lab bricks\n",fnLSG_GetNumDevices());
  printf("Leaving test mode\n");
  fnLSG_SetTestMode(0);
  printf("I have %d lab bricks\n",fnLSG_GetNumDevices());
  if(fnLSG_GetNumDevices() == 0)
    return 1;
  fnLSG_GetDevInfo(bricks);
  fnLSG_InitDevice(bricks[0]);
  while(1)
    {
      gets(buf);
      
      if(sscanf(buf,"%d",&power) == 0)
	break;
      printf("Setting power to %d\n",power);
      fnLSG_SetPowerLevel(bricks[0],power);
      printf("Power is %d\n",fnLSG_GetPowerLevel(bricks[0]));      
    }
  fnLSG_CloseDevice(bricks[0]);
  return 0;
}
