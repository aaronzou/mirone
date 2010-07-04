/* $Revision: 1.1.8.2 $ */
/*
 * Copyright 1993-2007 The MathWorks, Inc.
 * $Revision.1 $  $Date: 2007/06/04 21:09:50 $
 */

/*
 *	intlutc.c
 *
 *   INTLUT(A,LUT) creates an array containing new values of A based on the
 *   lookup table, LUT.  For example, if A is a vector whose kth element is equal
 *   to alpha, then B(k) is equal to the LUT value corresponding to alpha, i.e.,
 *   LUT(alpha).
 *
 *    Class Support
 *     -------------
 *    A can be uint8, uint16, or int16. If A is uint8, then LUT must be a
 *    uint8 vector with 256 elements.  If A is uint16 or int16, then LUT must
 *    be a vector with 65536 elements that has the same class as A. B has the
 *    same size and class as A.
 *
 *    This is a MEX file for MATLAB.
 */

#include "mex.h"

/*----------------*/

void ValidateInputs(const mxArray *prhs[], int nrhs) {
  /*check for valid number of inputs*/
  if (nrhs > 2) {
    mexErrMsgIdAndTxt("Images:intlut:tooManyInputs",
                      "INTLUT requires two input arguments.");
  }
  if (nrhs < 2) {
    mexErrMsgIdAndTxt("Images:intlut:tooFewInputs",
                      "INTLUT requires two input arguments.");
  }

  /*Check prhs[0], which is A*/
  if (!(mxIsUint8(prhs[0]) || mxIsUint16(prhs[0])|| mxIsInt16(prhs[0]))) {
    mexErrMsgIdAndTxt("Images:intlut:invalidType",
                      "A must be a uint8, uint16, or int16 array.");
  }
  if (mxIsComplex(prhs[0])) {
    mexErrMsgIdAndTxt("Images:intlut:expectedReal",
                      "A must be a real array.");
  }

  /* Check prhs[1], which is LUT */
  if (!(mxIsUint8(prhs[1]) || mxIsUint16(prhs[1])|| mxIsInt16(prhs[1]))) {
    mexErrMsgIdAndTxt("Images:intlut:invalidType",
                      "LUT must be a uint8, uint16, or int16 array.");   
  }
  if (!(mxGetNumberOfDimensions(prhs[1])== 2 && (mxGetM(prhs[1]) == 1 || mxGetN(prhs[1]) == 1))) {
    mexErrMsgIdAndTxt("Images:intlut:expectedVector",
                      "LUT must be a vector.");
  }
  if (mxIsComplex(prhs[0])) {
    mexErrMsgIdAndTxt("Images:intlut:expectedReal",
                      "LUT must be real.");
  }

  /*A and LUT must be the same class. */
  if(mxGetClassID(prhs[0]) != mxGetClassID(prhs[1])) {
    mexErrMsgIdAndTxt("Images:intlut:inputsHaveDifferentClasses",
                      "A and LUT must be the same class.");
  }

  /*LUT must contain 256 elements if it uint8 and 65536 elements
    if it is uint16.*/
  if(mxIsUint8(prhs[1]) && mxGetNumberOfElements(prhs[1]) != 256) {
    mexErrMsgIdAndTxt("Images:intlut:wrongNumberOfElementsInLUT",
                      "LUT must contain 256 elements if it is uint8.");
  }
  if( (mxIsUint16(prhs[1]) || mxIsInt16(prhs[1])) && mxGetNumberOfElements(prhs[1]) != 65536) {
    mexErrMsgIdAndTxt("Images:intlut:wrongNumberOfElementsInLUT",
                      "LUT must contain 65536 elements if it is uint16 or int16.");
  }
}

/*----------------*/
void ApplyLUTtoUint8(uint8_T *bptr, uint8_T *aptr, uint8_T *lutptr, int numel) {
  int count = 0;         /*counter*/

  for(count=0; count < numel; count++){
    bptr[count] = lutptr[aptr[count]];
  }
}

/*----------------*/

void ApplyLUTtoUint16(uint16_T *bptr, uint16_T *aptr, uint16_T *lutptr, int numel) {
  int count = 0;         /*counter*/

  for(count=0; count < numel; count++){
    bptr[count] = lutptr[aptr[count]];
  }
}
/*----------------*/
void ApplyLUTtoInt16(int16_T *bptr, int16_T *aptr, int16_T *lutptr, int numel) {
  int count = 0;         /*counter*/

  for(count=0; count < numel; count++){
    bptr[count] = lutptr[((int32_T)aptr[count] + 32768)];
  }
}

/*----------------*/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

  mxArray *B;               /*output mexArray */
  void *Aptr;               /*pointer to data in mxArray A */
  void *LUTptr;             /*pointer to data in mxArray LUT */
  void *Bptr;               /*pointer to data in mxArray B */
  int num_elements = 0;  /*number of elements in */

  (void) nlhs;  /* unused parameter */

  /* input checking */
  ValidateInputs(prhs,nrhs);

  /* the output array, B, should be the same size and type as A
     even if A is empty.  A is prhs[0].*/
  num_elements = mxGetNumberOfElements(prhs[0]);
  B = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]),
                           mxGetDimensions(prhs[0]),mxGetClassID(prhs[0]),
                           mxREAL);

  /* Populate the data contained in B with values equal to the LUT(A).  A and
     LUT are in the prhs array.  Do this based on the class of A.*/

  Bptr = mxGetData(B);
  if (mxIsUint8(prhs[0])) {
    Aptr = (uint16_T *)mxGetData(prhs[0]);
    LUTptr = (uint16_T *)mxGetData(prhs[1]);
    ApplyLUTtoUint8((uint8_T *)Bptr, Aptr,LUTptr,num_elements);
  }
  else if (mxIsUint16(prhs[0])) {
    Aptr = (uint16_T *)mxGetData(prhs[0]);
    LUTptr = (uint16_T *)mxGetData(prhs[1]);
    ApplyLUTtoUint16((uint16_T *)Bptr, Aptr,LUTptr,num_elements);
  }
  else {
    Aptr = (int16_T *)mxGetData(prhs[0]);
    LUTptr = (int16_T *)mxGetData(prhs[1]);
    ApplyLUTtoInt16((int16_T *)Bptr, Aptr,LUTptr,num_elements);
  }

  /* Done! Give the answer back */
  plhs[0] = B;
}
