/*============================================================================*/
/*                    L a b W i n d o w s / C V I                             */
/*----------------------------------------------------------------------------*/
/*        Copyright (c) National Instruments 1987-1999.  All Rights Reserved. */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:    stdarg.h                                                         */
/* Purpose:  Include file for ANSI Standard C support of access to unnamed    */
/*              additional arguments of a function that accepts a varying     */
/*              number of arguments.                                          */
/*                                                                            */
/*============================================================================*/

#ifndef _STDARG
#define _STDARG

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

typedef char *va_list;

#if !defined(_CVI_) && defined(_NI_sparc_) && (_NI_sparc_ == 2)
#define va_start(list, name) (void) (list = (va_list) &__builtin_va_alist)
#else
#define va_start(list, start) \
  ((list) = (char*)(((unsigned)&(start) + ((sizeof(start) + 0x3)& ~0x3))))
#endif /* _NI_sparc_ */

#define va_end(list)

#define __va_arg(list, type, n, m) \
  (*(type *)((list += ((sizeof(type)+n)&~n))- ((sizeof(type)+m)&~m)))

#define va_copy(dest_list, src_list) \
    ((dest_list) = (src_list))

#if defined(_NI_mswin_) || defined(_NI_mswin16_) || defined(_NI_mswin32_)
#define va_arg(list, mode) __va_arg(list, mode, 0x3, 0x3)

#elif defined(_NI_unix_) || defined(_NI_sparc_) || defined(_NI_mac_)
#if !defined(_CVI_) && defined(_NI_sparc_) && (_NI_sparc_ == 2)
#define va_arg(list, mode) ((mode *)__builtin_va_arg_incr((mode *)list))[0]
#else
#define va_arg(list, mode) __va_arg(list, mode, 0x3, 0x0)
#endif /* NI_sparc_ */

#else
#error Undefined Platform. You need to add one of the
#error following to your compiler defines:
#error     Platform                      Preprocessor directive
#error Microsoft Windows 3.1           #define _NI_mswin16_
#error Windows 95/NT                   #define _NI_mswin32_
#error Solaris 1                       #define _NI_sparc_       1
#error Solaris 2                       #define _NI_sparc_       2
#error
#error _NI_i386_ has been replaced with _NI_mswin16_.
#error See Programmers Reference Manual for more information.

#endif

#ifdef __cplusplus
    }
#endif

#endif /* _STDARG */




