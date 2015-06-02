/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       setjmp.h                                                      */
/* Purpose:     Include file for ANSI Standard C support of non local control */
/*              transfers that bypass normal function call and return         */
/*              protocol.                                                     */
/*                                                                            */
/*============================================================================*/

#ifndef _SETJMP
#define _SETJMP

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#if defined(_NI_mswin_)  || defined(_NI_mswin16_) || defined(_NI_mswin32_)
#define _JBSIZE (204)
typedef char jmp_buf[_JBSIZE];

#elif defined(_NI_unix_) || defined(_NI_sparc_)
#define _JBSIZE (40)
typedef int jmp_buf[_JBSIZE];

#elif defined(_NI_mac_)
#define _JBSIZE (23+1)              /* MAC VALUE */
typedef int jmp_buf[_JBSIZE];
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

int CVIANSI setjmp(jmp_buf);
void CVIANSI longjmp(jmp_buf, int);

#if defined(_NI_unix_) || defined(_NI_sparc_)
extern void __longjmpFunctions(jmp_buf env);
extern void __setjmpFunctions(jmp_buf env);
#define setjmp(env) (((void) __setjmpFunctions(env)), setjmp(env))
#define longjmp(env, val)  (((void) __longjmpFunctions(env)), longjmp(env, val))
#else
#define setjmp(env) setjmp(env)
#endif

#ifdef __cplusplus
    }
#endif

#endif /* _SETJMP */
