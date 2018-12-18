/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       string.h                                                      */
/* Purpose:     Include file for ANSI Standard C Library support of functions */
/*              to manipulate strings and array of characters.                */
/*                                                                            */
/*============================================================================*/

#ifndef _STRING
#define _STRING

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#ifndef NULL
#define NULL 0
#endif

#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
#ifdef _NI_mswin64_
typedef unsigned __int64 size_t;
#else
typedef unsigned int size_t;
#endif
#endif

void * CVIANSI memchr(const void *, int, size_t);
int  CVIANSI memcmp(const void *, const void *, size_t);
void * CVIANSI memcpy(void *, const void *, size_t);
void * CVIANSI memmove(void *, const void *, size_t);
void * CVIANSI memset(void *, int, size_t);
char * CVIANSI strcat(char *, const char *);
char * CVIANSI strchr(const char *, int);
int  CVIANSI strcmp(const char *, const char *);
int  CVIANSI stricmp(const char *, const char *);
char * CVIANSI strcpy(char *, const char *);
size_t  CVIANSI strcspn(const char *, const char *);
size_t  CVIANSI strlen(const char *);
char * CVIANSI strncat(char *s1, const char *, size_t);
int  CVIANSI strncmp(const char *, const char *, size_t);
int  CVIANSI strnicmp(const char *, const char *, size_t);
char * CVIANSI strncpy(char *, const char *, size_t);
char * CVIANSI strpbrk(const char *, const char *);
char * CVIANSI strrchr(const char *, int);
size_t  CVIANSI strspn(const char *, const char *);
char * CVIANSI strstr(const char *, const char *);
char * CVIANSI strtok(char *, const char *);
int  CVIANSI strcoll(const char *, const char *);
size_t  CVIANSI strxfrm(char *, const char *, size_t);
char * CVIANSI strerror(int);

#ifdef __cplusplus
    }
#endif

#endif


