/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       limits.h                                                      */
/* Purpose:     Include file for ANSI Standard C for determining various      */
/*              properties of the integer type representations.               */
/*                                                                            */
/*============================================================================*/

#ifndef _LIMITS
#define _LIMITS

#define CHAR_BIT    8
#define MB_LEN_MAX  1

#define UCHAR_MAX   0xff
#define USHRT_MAX   0xffff
#define UINT_MAX    0xffffffff
#define ULONG_MAX   0xffffffffL
#define ULLONG_MAX  0xffffffffffffffffL

#define CHAR_MAX    SCHAR_MAX
#define SCHAR_MAX   0x7f
#define SHRT_MAX    0x7fff
#define INT_MAX     0x7fffffff
#define LONG_MAX    0x7fffffffL
#define LLONG_MAX   0x7fffffffffffffffL

#define CHAR_MIN    SCHAR_MIN
#define SCHAR_MIN   (-SCHAR_MAX-1)
#define SHRT_MIN    (-SHRT_MAX-1)
#define INT_MIN     (-INT_MAX-1)
#define LONG_MIN    (-LONG_MAX-1)
#define LLONG_MIN   (-LLONG_MAX-1)

#endif
