/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       time.h                                                        */
/* Purpose:     Include file for ANSI Standard C Library support of functions */
/*              to access the system clock, perform timing operations, and    */
/*              specify time domain constants.                                */
/*                                                                            */
/*============================================================================*/

#ifndef _TIME
#define _TIME

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif


#ifndef NULL
#define NULL 0
#endif

#if defined(_NI_unix_) || defined(_NI_sparc_)
#define CLOCKS_PER_SEC 1000000
#elif defined(_NI_mswin16_) || defined(_NI_mswin32_) || defined(_NI_mswin64_)
#define CLOCKS_PER_SEC 1000
#elif defined(_NI_mac_)
#define CLOCKS_PER_SEC 1
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

#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
#ifdef _NI_mswin64_
typedef unsigned __int64 size_t;
#else
typedef unsigned int size_t;
#endif
#endif

#ifndef _CLOCK_T
#define _CLOCK_T
typedef unsigned int clock_t;
#endif

#ifndef _TIME_T_DEFINED
#define _TIME_T_DEFINED
#ifdef _NI_mswin64_
typedef __int64 time_t;
#else
typedef unsigned int time_t;
#endif
#endif

#ifdef WIN32
    #pragma pack(push)
    #pragma pack(4)
#endif

struct tm {
    int tm_sec;
    int tm_min;
    int tm_hour;
    int tm_mday;
    int tm_mon;
    int tm_year;
    int tm_wday;
    int tm_yday;
    int tm_isdst;
};

#ifdef WIN32
    #pragma pack(pop)
#endif

char * CVIANSI asctime(const struct tm *);
char * CVIANSI ctime(const time_t *);
double  CVIANSI difftime(time_t, time_t);
struct tm * CVIANSI gmtime(const time_t *);
struct tm * CVIANSI localtime(const time_t *);
time_t  CVIANSI mktime(struct tm *);
size_t  CVIANSI strftime(char *, size_t, const char *, const struct tm *);
time_t  CVIANSI time(time_t *);
clock_t  CVIANSI clock(void);

#ifdef __cplusplus
    }
#endif

#endif /* _TIME */
