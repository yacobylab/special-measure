/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       ansi_c.h                                                      */
/* Purpose:     Include file for entire ANSI Standard C Library               */
/*                                                                            */
/*============================================================================*/

#ifndef _ANSI_C
#define _ANSI_C

#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <float.h>
#include <limits.h>
#include <locale.h>
#include <math.h>
#if defined (_CVI_) || (defined (_NI_linux_) && _NI_linux_)
#include <mbsupp.h>
#endif
#include <setjmp.h>
#include <signal.h>
#include <stdarg.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#if defined (_CVI_) || (defined (_NI_linux_) && _NI_linux_)
#include <stdlibex.h>
#endif
#include <string.h>
#include <time.h>

#endif /* _ANSI_C */
