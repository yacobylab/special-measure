/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       float.h                                                       */
/* Purpose:     Include file for ANSI Standard C to determine floating type   */
/*              representations and properties.                               */
/*                                                                            */
/*============================================================================*/

#ifndef _FLOAT
#define _FLOAT

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#ifdef WIN32
    #pragma pack(push)
    #pragma pack(4)
#endif

typedef const union {
    unsigned char a[4];
    float val;
} _FloatConst_t;

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
    extern _FloatConst_t * CVIFUNC_C _GetFloatMin(void);
    extern _FloatConst_t * CVIFUNC_C _GetFloatMax(void);
    extern _FloatConst_t * CVIFUNC_C _GetFloatEps(void);
    extern _DoubleConst_t * CVIFUNC_C _GetDoubleMin(void);
    extern _DoubleConst_t * CVIFUNC_C _GetDoubleMax(void);
    extern _DoubleConst_t * CVIFUNC_C _GetDoubleEps(void);
    #define _FloatMin   (*_GetFloatMin())
    #define _FloatMax   (*_GetFloatMax())
    #define _FloatEps   (*_GetFloatEps())
    #define _DoubleMin  (*_GetDoubleMin())
    #define _DoubleMax  (*_GetDoubleMax())
    #define _DoubleEps  (*_GetDoubleEps())
#else
    extern _FloatConst_t _FloatMin;
    extern _FloatConst_t _FloatMax;
    extern _FloatConst_t _FloatEps;
    extern _DoubleConst_t _DoubleMin;
    extern _DoubleConst_t _DoubleMax;
    extern _DoubleConst_t _DoubleEps;
#endif

#define FLT_ROUNDS              1
#define FLT_RADIX               2

#define FLT_DIG                 6
#define FLT_EPSILON             _FloatEps.val
#define FLT_MANT_DIG            24
#define FLT_MAX                 _FloatMax.val
#define FLT_MAX_10_EXP          38
#define FLT_MAX_EXP             128
#define FLT_MIN                 _FloatMin.val
#define FLT_MIN_10_EXP          (-37)
#define FLT_MIN_EXP             (-125)

#define DBL_DIG                 15
#define DBL_EPSILON             _DoubleEps.val
#define DBL_MANT_DIG            53
#define DBL_MAX                 _DoubleMax.val
#define DBL_MAX_10_EXP          308
#define DBL_MAX_EXP             1024
#define DBL_MIN                 _DoubleMin.val
#define DBL_MIN_10_EXP          (-307)
#define DBL_MIN_EXP             (-1021)

#define LDBL_MANT_DIG           DBL_MANT_DIG
#define LDBL_EPSILON            DBL_EPSILON
#define LDBL_DIG                DBL_DIG
#define LDBL_MIN_EXP            DBL_MIN_EXP
#define LDBL_MIN                DBL_MIN
#define LDBL_MIN_10_EXP         DBL_MIN_10_EXP
#define LDBL_MAX_EXP            DBL_MAX_EXP
#define LDBL_MAX                DBL_MAX
#define LDBL_MAX_10_EXP         DBL_MAX_10_EXP

#ifdef __cplusplus
    }
#endif

#endif /* _FLOAT */
