/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       stddef.h                                                      */
/* Purpose:     Include file for ANSI Standard C that defines several types   */
/*              and macros that are of general use in a program.              */
/*                                                                            */
/*============================================================================*/

#ifndef _STDDEF
#define _STDDEF

#ifdef __cplusplus
    extern "C" {
#endif

#ifndef NULL
#define NULL 0
#endif

#define offsetof(t, mem) ((size_t) ((char *)&(((t *)8)->mem) - (char *)8))

#ifdef _NI_mswin64_
typedef __int64 ptrdiff_t;
#else
typedef long ptrdiff_t;
#endif

#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
#ifdef _NI_mswin64_
typedef unsigned __int64 size_t;
#else
typedef unsigned int size_t;
#endif
#endif

#ifndef _WCHAR_T_DEFINED
#define _WCHAR_T_DEFINED
#define _WCHAR_T
typedef unsigned short wchar_t;
typedef unsigned short sdk_wchar_t;
#endif

#ifdef __cplusplus
    }
#endif

#endif  /* ndef _STDDEF */
