/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       math.h                                                        */
/* Purpose:     Include file for ANSI Standard C math library functions and   */
/*              value domains.                                                */
/*                                                                            */
/*============================================================================*/

#ifndef _MATH
#define _MATH

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#ifdef WIN32
    #pragma pack(push)
    #pragma pack(4)
#endif

#ifndef _DBL_CONST_T
#define _DBL_CONST_T
typedef const union {
    unsigned char a[8];
    double val;
} _DoubleConst_t;
#endif

#ifdef WIN32
    #pragma pack(pop)
#endif

#ifdef _CVI_USE_FUNCS_FOR_VARS_
    extern _DoubleConst_t * CVIFUNC_C _GetDoubleInf(void);
    #define _DoubleInf  (*_GetDoubleInf())
#else
    extern _DoubleConst_t _DoubleInf;
#endif

#define HUGE_VAL _DoubleInf.val    /* Infinity */

extern double CVIANSI acos(double);
extern double CVIANSI asin(double);
extern double CVIANSI atan(double);
extern double CVIANSI atan2(double, double);
extern double CVIANSI cos(double);
extern double CVIANSI sin(double);
extern double CVIANSI tan(double);
extern double CVIANSI cosh(double);
extern double CVIANSI sinh(double);
extern double CVIANSI tanh(double);
extern double CVIANSI exp(double);
extern double CVIANSI frexp(double, int *);
extern double CVIANSI ldexp(double, int);
extern double CVIANSI log(double);
extern double CVIANSI log10(double);
extern double CVIANSI modf(double, double *);
extern double CVIANSI pow(double, double);
extern double CVIANSI sqrt(double);
extern double CVIANSI ceil(double);
extern double CVIANSI fabs(double);
extern double CVIANSI floor(double);
extern double CVIANSI fmod(double, double);

#ifdef __cplusplus
    }
#endif

#endif /* _MATH */
