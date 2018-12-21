#include "ansi_c.h"
#include "NiFpga_lockin_fpga.h"
#include "NiFpga.h"
#include "mex.h"

/* Reads an unsigned 16-bit noncomplex scalar to control. */

void lia_readU16(double control[], uint16_t value[])
{
	
	/* Create status, initialize to good */
	NiFpga_Status status = NiFpga_Status_Success;
	
	/* Create a session variable */
	NiFpga_Session session;
	
	/* Load the NiFpga library */
	NiFpga_Initialize();
	
	/* Load bitfile */
	NiFpga_Open(NiFpga_lockin_fpga_Bitfile, NiFpga_lockin_fpga_Signature, "RIO0", NiFpga_OpenAttribute_NoRun,&session);
	
	/* Read value from control */
	NiFpga_ReadU16(session, control[0], value);
	
	/* Close session */
	NiFpga_Close(session,0);
	
	NiFpga_Finalize();
}

/* MEX gateway routine */

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *control;
  uint16_t *value;
  mwSize mrows,ncols;
  
  /* Check for proper number of arguments. */
  if(nrhs!=1) {
    mexErrMsgTxt("One input required.");
  } else if(nlhs>1) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
  /* The control input must be a noncomplex scalar double.*/
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !(mrows==1 && ncols==1) ) {
    mexErrMsgTxt("Write control input must be a noncomplex scalar double.");
  }
  
  /* Create matrix for the return argument. */
  plhs[0] = mxCreateNumericMatrix(mrows,ncols, mxUINT16_CLASS, mxREAL);
  
  /* Assign pointers to each input and output. */
  control = mxGetPr(prhs[0]);
  value = mxGetPr(plhs[0]);
  
  /* Call the write subroutine. */
  lia_readU16(control,value);
}
