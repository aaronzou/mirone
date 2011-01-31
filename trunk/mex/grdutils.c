/*
 * Compute min/max OR mean/std OR add a constant OR muliply by a factor.
 * I wrote this mex due to the ML supreme stupidity of only performing math
 * operations on double precision variables.
 *
 * NOTE: If adding or multiplying the input array is also modified on matlab memory.
 * This happens because what is transmited is only the pointer to the array, and I
 * don't do a copy of it here.
 *
 * Author:	Joaquim Luis
 * Date:	31-OCT-2004
 * Revised:	31-MAR-2005
 * 		08-OCT-2005  -> Added -H option
 * 		11-OCT-2007  -> Added -C option  - casts uint8 to int8 and [0 255] to [-128 127]
 * 		29-Nov-2007  -> Search for NaNs stops at first occurrence and returns its index +1
 * 		02-Mar-2008  -> Only want above when -N. Otherwise count also the NaNs
 * 
 */

#define TRUE	1
#define FALSE	0

#include "mex.h"
#include <float.h>
#include <math.h>

/* --------------------------------------------------------------------------- */
/* Matlab Gateway routine */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {

	int i, j, nxy, nx, ny, nfound = 0, ngood, argc = 0, n_arg_no_char = 0;
	int error = FALSE, ADD = FALSE, MUL = FALSE, do_min_max = FALSE, do_std = FALSE;
	int is_double = FALSE, is_single = FALSE, is_int32 = FALSE, is_int16 = FALSE, is_uint8 = FALSE;
	int is_uint16 = FALSE, report_nans = FALSE, only_report_nans = FALSE, do_cast = FALSE;
	int i_min = 0, i_max = 0, do_min_max_loc = FALSE, report_min_max_loc_nan_mean_std = FALSE;
	int do_shift_int8 = FALSE, insitu = FALSE, is_int8 = FALSE; 
	char	**argv;
	float	*zdata, fact;
	double	*z, min_limit = FLT_MAX, max_limit = -FLT_MAX, mean = 0., sd = 0., rms = 0., tmp;

	argc = nrhs;
	for (i = 0; i < nrhs; i++) {		/* Check input to find how many arguments are of type char */
		if(!mxIsChar(prhs[i])) {
			argc--;
			n_arg_no_char++;	/* Number of arguments that have a type other than char */
		}
	}
	argc++;			/* to account for the program's name to be inserted in argv[0] */

	/* get the length of the input string */
	argv = (char **)mxCalloc(argc, sizeof(char *));
	argv[0] = "grdutils";
	for (i = 1; i < argc; i++) {
		argv[i] = (char *)mxArrayToString(prhs[i+n_arg_no_char-1]);
	}

	for (i = 1; !error && i < argc; i++) {
		if (argv[i][0] == '-') {
			switch (argv[i][1]) {
			
				case 'A':
					if (sscanf(&argv[i][2], "%f", &fact) != 1) {
						mexPrintf("GRDUTILS ERROR: -A option. Cannot decode value\n");
						error++;
					}
					ADD = TRUE;
					break;
				case 'C':
					do_cast = TRUE;
					break;
				case 'c':
					do_shift_int8 = TRUE;
					if (nlhs == 0) insitu = TRUE;	/* Only allowed case */
					break;
				case 'H':
					do_min_max_loc = TRUE;
					do_std = TRUE;
					report_min_max_loc_nan_mean_std = TRUE;
					break;
				case 'M':
					if (sscanf(&argv[i][2], "%f", &fact) != 1) {
						mexPrintf("GRDUTILS ERROR: -M option. Cannot decode value\n");
						error++;
					}
					MUL = TRUE;
					break;
				case 'L':
					do_min_max = TRUE;
					if (argv[i][2] == '+')
						report_nans = TRUE;
					break;
				case 'N':
					only_report_nans = TRUE;
					break;
				case 'S':
					do_std = TRUE;
					break;
				default:
					error = TRUE;
					break;
			}
		}
	}
	
	if (n_arg_no_char == 0 || error) {
		mexPrintf ("grdutils - Do some usefull things on arrays that are in single precision\n\n");
		mexPrintf ("usage: [out] = grdutils(infile, ['-A<const>'], ['-L[+]'], [-H], [-M<fact>], [-S], [-C]\n");
		
		mexPrintf ("\t<out> is a two line vector with [min,max] or [mean,std] if -L OR -S\n");
		mexPrintf ("\t Do not use <out> with -A or -M because infile is a pointer and no copy of it is made here\n");
		mexPrintf ("\t<infile> is name of input array\n");
		mexPrintf ("\n\tOPTIONS (but must choose only one):\n");
		mexPrintf ("\t   ---------------------------------\n");
		mexPrintf ("\t-A constant adds constant to array.\n");
		mexPrintf ("\t-C casts array uint8 to int8 and subtracts 128. That is [0 255] to [-128 127].\n");
		mexPrintf ("\t-c Shift int8 arrays by -128. That is [0 .. 0 127] to [-128 127].\n");
		mexPrintf ("\t   Without output do operation insitu.\n");
		mexPrintf ("\t-L Compute min and max. Apend + (-L+) to check also for NaNs\n");
		mexPrintf ("\t-H outputs [z_min z_max i_zmin i_zmax firstNaNind mean std]\n");
		mexPrintf ("\t-M factor multiplies array by factor.\n");
		mexPrintf ("\t-N See if grid has NaNs and if yes returns its index + 1 and exit.\n");
		mexPrintf ("\t-S Compute mean and standard deviation.\n");
		mexErrMsgTxt("\n");
	}
	
	if (nlhs == 0 && !(ADD + MUL) && !insitu) {
		mexPrintf("GRDUTILS ERROR: Must provide an output.\n");
		return;
	}
	if (report_min_max_loc_nan_mean_std) {	/* Just in case */
		do_min_max = FALSE;
		only_report_nans = FALSE;
	}

	/* Find out in which data type was given the input array. Doubles are excluded */
	if (mxIsSingle(prhs[0])) {
		is_single = TRUE;
	}
	else if (mxIsInt32(prhs[0])) {
		is_int32 = TRUE;
	}
	else if (mxIsInt16(prhs[0])) {
		is_int16 = TRUE;
	}
	else if (mxIsUint16(prhs[0])) {
		is_uint16 = TRUE;
	}
	else if (mxIsUint8(prhs[0])) {
		is_uint8 = TRUE;
	}
	else if (mxIsInt8(prhs[0])) {
		is_int8 = TRUE;
	}
	else {
		mexPrintf("GRDUTILS ERROR: Unknown input data type.\n");
		mexErrMsgTxt("Valid type is: single, int, short or unsigned short and uint8\n");
	}

	nx = mxGetN (prhs[0]);
	ny = mxGetM (prhs[0]);
	if (!mxIsNumeric(prhs[0]) || ny < 2 || nx < 2)
		mexErrMsgTxt("GRDUTILS ERROR: First argument must contain a decent array\n");

	nxy = nx * ny;

	if (do_cast && is_uint8) {	/* Case where we only want to cast a uint8 to int8 */
		unsigned char *Udata8;
		char	*data8;
		Udata8 = (unsigned char *)(mxGetData(prhs[0]));
		plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]),
			mxGetDimensions(prhs[0]), mxINT8_CLASS, mxREAL);
		data8 = (char *)(mxGetData(plhs[0]));
		for (i = 0; i < nxy; i++)
			data8[i] = (char)(Udata8[i] - 128);
		return;
	}
	else if (do_shift_int8 && is_int8) {	/* Shift int8 from [0 127] to [0 127] - 128 */
		char	*data8_in, *data8_out;
		data8_in = (char *)(mxGetData(prhs[0]));

		if (!insitu) {
			plhs[0] = mxCreateNumericArray(mxGetNumberOfDimensions(prhs[0]),
				mxGetDimensions(prhs[0]), mxINT8_CLASS, mxREAL);
			data8_out = (char *)(mxGetData(plhs[0]));

			for (i = 0; i < nxy; i++)
				data8_out[i] = data8_in[i] - 128;
		}
		else
			for (i = 0; i < nxy; i++) data8_in[i] -= 128;

		return;
	}
	else {
		if (!mxIsSingle(prhs[0]))
			mexErrMsgTxt("GRDUTILS ERROR: Invalid input data type. Only valid type is: Single.\n");
		zdata = (float *)mxGetData(prhs[0]);
	}


	if (only_report_nans) {
		/* Loop over the file and find if we have NaNs. Stop at first NaN occurence. */
		for (i = 0; i < nxy; i++) {
			if (mxIsNaN(zdata[i])) {
				nfound = i + 1;		/* + 1 becuse ML is 1 based */
				break;
			}
		}

		plhs[0] = mxCreateDoubleMatrix (1,1, mxREAL);
		z = mxGetPr(plhs[0]);
		z[0] = nfound;
		return;
	}

	for (i = 0; i < nxy; i++) {
		tmp = (double)zdata[i];
		if (!mxIsNaN(tmp)) {
			if (do_min_max) {
				if (tmp < min_limit) min_limit = tmp;
				if (tmp > max_limit) max_limit = tmp;
			}
			else if (do_min_max_loc) {
				if (tmp < min_limit) {
					min_limit = tmp;
					i_min = i;
				}
				if (tmp > max_limit) {
					max_limit = tmp;
					i_max = i;
				}
			}
			else if (MUL)
				zdata[i] *= fact;
			else if (ADD)
				zdata[i] += fact;
			if (do_std) {
				mean += tmp;
				sd += tmp * tmp;
			}
		}
		else
			nfound++;
	}

	ngood = nxy - nfound;	/* This is the number of non-NaN points  */
	mean /= ngood;
	rms = sqrt(sd / (double)ngood);
	sd /= (double)(ngood - 1);
	sd = sqrt(sd - mean*mean);

	if (nlhs == 1) {	/* Otherwise we have a MULL or ADD and those don't require an output */
		if ((do_min_max && !report_nans) || do_std && !report_min_max_loc_nan_mean_std) {
			plhs[0] = mxCreateDoubleMatrix (2,1, mxREAL);
			z = mxGetPr(plhs[0]);
		}
		else if (do_min_max && report_nans) {
			plhs[0] = mxCreateDoubleMatrix (3,1, mxREAL);
			z = mxGetPr(plhs[0]);
		}
		else if (report_min_max_loc_nan_mean_std) {
			plhs[0] = mxCreateDoubleMatrix (7,1, mxREAL);
			z = mxGetPr(plhs[0]);
			z[0] = min_limit;	z[1] = max_limit;
			z[2] = (double)i_min;	z[3] = (double)i_max;
			z[4] = (double)nfound;	z[5] = mean;	z[6] = sd;
			return;
		}

		if (do_min_max) {
			z[0] = min_limit;
			z[1] = max_limit;
			if (report_nans) z[2] = nfound;
		}
		else if (do_std) {
			z[0] = mean;
			z[1] = sd;
		}
	}
}

