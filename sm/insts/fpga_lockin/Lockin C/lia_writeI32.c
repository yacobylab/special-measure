#include "ansi_c.h"
#include "NiFpga_lockin_fpga.h"
#include "NiFpga.h"
#include "mex.h"

/* Writes a signed 32-bit noncomplex scalar to control. */

void lia_writeI32(double control[], int32_t value[])
{
	
	/* Create status, initialize to good */
	NiFpga_Status status = NiFpga_Status_Success;
	
	/* Create a session variable */
	NiFpga_Session session;
	
	/* Load the NiFpga library */
	NiFpga_Initialize();
	
	/* Load bitfile */
	NiFpga_Open(NiFpga_lockin_fpga_Bitfile, NiFpga_lockin_fpga_Signature, "RIO0", NiFpga_OpenAttribute_NoRun,&session);
	
	/* Set value to control */
	NiFpga_WriteI32(session, control[0], value[0]);
	
	/* Close session */
	NiFpga_Close(session,0);
	
	NiFpga_Finalize();
}

/* MEX gateway routine */

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[] )
{
  double *control;
  int32_t *value;
  mwSize mrows,ncols;
  
  /* Check for proper number of arguments. */
  if(nrhs!=2) {
    mexErrMsgTxt("Two inputs required.");
  } else if(nlhs>0) {
    mexErrMsgTxt("Too many output arguments.");
  }
  
  /* The control input must be a noncomplex scalar double.*/
  /* The value input must be a noncomplex scalar unsigned int16.*/
  mrows = mxGetM(prhs[0]);
  ncols = mxGetN(prhs[0]);
  if( !mxIsDouble(prhs[0]) || mxIsComplex(prhs[0]) ||
      !(mrows==1 && ncols==1) ) {
    mexErrMsgTxt("Write control input must be a noncomplex scalar double.");
  }
  if( !mxIsInt32(prhs[1]) || mxIsComplex(prhs[1]) ||
      !(mrows==1 && ncols==1) ) {
    mexErrMsgTxt("Write value input must be a noncomplex scalar signed int32.");
  }
  
  /* Assign pointers to each input and output. */
  control = mxGetPr(prhs[0]);
  value = mxGetPr(prhs[1]);
  
  /* Call the write subroutine. */
  lia_writeI32(control,value);
}
