/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       stdlib.h                                                      */
/* Purpose:     Include file for ANSI Standard C library of functions and     */
/*              macros of general purpose utility.                            */
/*                                                                            */
/*============================================================================*/

#ifndef _STDLIB
#define _STDLIB

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#define EXIT_FAILURE 1
#define EXIT_SUCCESS 0

#define RAND_MAX 32767
#define MB_CUR_MAX 1


#ifndef NULL
#define NULL 0
#endif

#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
typedef unsigned int size_t;
#endif

#ifndef _WCHAR_T_DEFINED
#define _WCHAR_T_DEFINED
#define _WCHAR_T
typedef unsigned short wchar_t;
typedef unsigned short sdk_wchar_t;
#endif

#ifdef WIN32
    #pragma pack(push)
    #pragma pack(4)
#endif

typedef struct {
    int quot;
    int rem;
} div_t;

typedef struct {
    long quot;
    long rem;
} ldiv_t;

#ifdef WIN32
    #pragma pack(pop)
#endif

int CVIANSI abs(int);
long  CVIANSI labs(long);
div_t  CVIANSI div(int, int);
ldiv_t  CVIANSI ldiv(long, long);
int  CVIANSI atexit(void (CVIANSI *)(void));
void  CVIANSI exit(int);
void  CVIANSI abort(void);
void * CVIANSI bsearch(const void *, const void *, size_t, size_t,
              int (CVIANSI *)(const void *, const void *));
void  CVIANSI qsort(void *, size_t, size_t,
           int (CVIANSI *)(const void *, const void *));
int  CVIANSI rand(void);
void  CVIANSI srand(unsigned int);

double  CVIANSI atof(const char *);

int  CVIANSI atoi(const char *);
long  CVIANSI atol(const char *);

double  CVIANSI strtod(const char *, char **);

long  CVIANSI strtol(const char *, char **, int);
unsigned long  CVIANSI strtoul(const char *, char **, int);

void * CVIANSI calloc(size_t, size_t);
void  CVIANSI free(void *);
void * CVIANSI malloc(size_t);
void * CVIANSI realloc(void *, size_t);

char * CVIANSI getenv(const char *);
int  CVIANSI system(const char *);
int  CVIANSI mblen(const char *, size_t);
int  CVIANSI mbtowc(wchar_t *, const char *, size_t);
int  CVIANSI wctomb(char *, wchar_t);
size_t  CVIANSI mbstowcs(wchar_t *, const char *, size_t);
size_t  CVIANSI wcstombs(char *, const wchar_t *, size_t);
size_t  CVIANSI wcslen(const wchar_t *);

#ifdef __cplusplus
    }
#endif

#endif

