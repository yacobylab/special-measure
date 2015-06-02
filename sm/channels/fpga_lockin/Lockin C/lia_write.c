#include "ansi_c.h"
#include "NiFpga_lia_fpga_four.h"
#include "NiFpga.h"
#include "mex.h"

//typedef   signed __int32 NiFpga_Status; 
//static const NiFpga_Status NiFpga_Status_Success = 0;

//NiFpga_Status NiFpga_Initialize(void){return NiFpga_Status_Success;}


void read_fpga(double control[], int16_t value[])
{
	
	/* Create status, initialize to good */
	NiFpga_Status status = NiFpga_Status_Success;
	
	/* Create a session variable */
	NiFpga_Session session;
	
	/* Load the NiFpga library */
	NiFpga_Initialize();
	
	/* Load bitfile */
	NiFpga_Open(NiFpga_donothing_Bitfile, NiFpga_donothing_Signature, "RIO0", NiFpga_OpenAttribute_NoRun,&session);
	
	/* Run FPGA VI */	
	//NiFpga_Run(session,0);
	
	/* Set X,Y.  Get Z. */
	//NiFpga_WriteI16(session, control[0], value[0]);
	//NiFpga_WriteI16(session, NiFpga_donothing_ControlI16_Y, y[0]);
	
	NiFpga_ReadI16(session, control[0], value);
	
	/* Close */
	NiFpga_Close(session,0);
	
	NiFpga_Finalize();
	
}

/* Gateway routine */

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *control;
  int16_t *value;
  mwSize mrows,ncols;
  
  /* Check for proper number of arguments. */
  if(nrhs!=1) {
    mexErrMsgTxt("One input required.");
  } else if(nlhs>1) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
  /* The input must be a noncomplex scalar int16.*/
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !(mrows==1 && ncols==1) ) {
    mexErrMsgTxt("Write control input must be a noncomplex scalar double.");
  }
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateNumericMatrix(mrows,ncols, mxINT16_CLASS, mxREAL);
  
  /* Assign pointers to each input and output. */
  
  control = mxGetPr(prhs[0]);
  value = mxGetPr(plhs[0]);
  //z = mxGetPr(plhs[0]);
  
  /* Call the timestwo subroutine. */
  read_fpga(control,value);
}
