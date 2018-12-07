/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       stdio.h                                                       */
/* Purpose:     Include file for ANSI Standard C support of I/O operations on */
/*              files and streams.                                            */
/*                                                                            */
/*============================================================================*/

#ifndef _STDIO_H
#define _STDIO_H

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#ifndef _SIZE_T_DEFINED
#define _SIZE_T_DEFINED
typedef unsigned int size_t;
#endif

#ifdef WIN32
    #pragma pack(push)
    #pragma pack(4)
#endif

typedef struct {
    unsigned int _offset;
} fpos_t;

#ifdef WIN32
    #pragma pack(pop)
#endif

#ifndef NULL
#define NULL 0
#endif

#define _IONBF 0
#define _IOLBF 1
#define _IOFBF 2

#define BUFSIZ          512
#define EOF             -1
#define FOPEN_MAX       255

#if defined(_NI_mswin16_)
#define FILENAME_MAX    80      /* maximum path length (includes nul byte) */

#elif defined(_NI_mswin32_) || defined(_NI_mswin64_)
#define FILENAME_MAX    260

#elif defined(_NI_unix_) || defined(_NI_sparc_)
#define FILENAME_MAX    256     /* recommended buffer size for paths */

#elif defined(_NI_mac_)
#define FILENAME_MAX    256

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

#define L_tmpnam        FILENAME_MAX
#ifndef SEEK_SET
#define SEEK_SET     0
#define SEEK_CUR     1
#define SEEK_END     2
#endif
#define TMP_MAX   999

#ifdef WIN32
    #pragma pack(push)
    #pragma pack(4)
#endif

struct _mode {
    unsigned int read:1;
    unsigned int write:1;
    unsigned int append:1;
    unsigned int binary:1;
    unsigned int create:1;
    unsigned int truncate:1;
    unsigned int fdopen:1;
    unsigned int reserved:25;
};

struct _state {
    unsigned int bufalloc:1;
    unsigned int filealloc:1;
    unsigned int eof:1;
    unsigned int error:1;
    unsigned int linebuf:1;
    unsigned int nobuf:1;
    unsigned int wasread:1;
    unsigned int waswritten:1;
    unsigned int InUse:1;
    unsigned int reserved:23;
};


typedef struct {
    struct _mode mode;
    struct _state state;
    int   handle;
    unsigned char *buffer;
    unsigned char *bufferEnd;
    unsigned char *next;
    unsigned char *readEnd;
    unsigned char *writeEnd;
    unsigned char *readEndSave;
    unsigned char pushedBack[6];
    char numPushedBack;
    unsigned char defaultBuf;
    unsigned char *tmpname;
    void *lock;
    int   consoleHandle;    /* Console handle for host stdio */
} FILE;

#ifdef WIN32
    #pragma pack(pop)
#endif

#ifdef _CVI_USE_FUNCS_FOR_VARS_
    extern FILE ** CVIFUNC_C _GetFilesArray(void);
    #define _files  (_GetFilesArray())
#else
    extern FILE * _files[FOPEN_MAX];
#endif

#define stdin _files[0]
#define stdout _files[1]
#define stderr _files[2]


int CVIANSI remove(const char *);
int  CVIANSI rename(const char *, const char *);
FILE * CVIANSI tmpfile(void);
char * CVIANSI tmpnam(char *);
int  CVIANSI fclose(FILE *);
int  CVIANSI fflush(FILE *);
FILE * CVIANSI fdopen(int, const char *);
FILE * CVIANSI fopen(const char *, const char *);
FILE * CVIANSI freopen(const char *, const char *, FILE *);
void  CVIANSI setbuf(FILE *, char *);
int  CVIANSI setvbuf(FILE *, char *, int, size_t);
int  CVIANSI fgetc(FILE *);
char * CVIANSI fgets(char *, int, FILE *);
int  CVIANSI fputc(int, FILE *);
int  CVIANSI fputs(const char *, FILE *);
int  CVIANSI getc(FILE *);
int  CVIANSI getchar(void);
char * CVIANSI gets(char *);
int  CVIANSI putc(int, FILE *);
int  CVIANSI putchar(int);
int  CVIANSI puts(const char *);
/* #pragma EnableFunctionRuntimeChecking puts */
int  CVIANSI ungetc(int, FILE *);
size_t  CVIANSI fread(void *, size_t, size_t, FILE *);
size_t  CVIANSI fwrite(const void *, size_t, size_t, FILE *);
int  CVIANSI fgetpos(FILE *, fpos_t *);
int  CVIANSI fseek(FILE *, long, int);
int  CVIANSI fsetpos(FILE *, const fpos_t *);
long  CVIANSI ftell(FILE *);
void  CVIANSI rewind(FILE *);
void  CVIANSI clearerr(FILE *);
int  CVIANSI feof(FILE *);
int  CVIANSI ferror(FILE *);
void  CVIANSI perror(const char *);

int  CVIFUNC_C fscanf(FILE *, const char *, ...);
int  CVIANSI vfscanf(FILE *, const char *, char *);
int  CVIFUNC_C scanf(const char *, ...);
int  CVIANSI vscanf(const char *, char * );
int  CVIFUNC_C sscanf(const char *, const char *, ...);
int  CVIANSI vsscanf(const char *, const char *, char * );
int  CVIFUNC_C fprintf(FILE *, const char *, ...);
int  CVIANSI vfprintf(FILE *, const char *, char * );
int  CVIFUNC_C printf(const char *, ...);
int  CVIANSI vprintf(const char *, char * );
int  CVIFUNC_C sprintf(char *, const char *, ...);
int  CVIANSI vsprintf(char *, const char *, char * );
int  CVIFUNC_C snprintf(char *, size_t, const char *, ...);
int  CVIANSI vsnprintf(char *, size_t, const char *, char * );

#if !defined(_CVI_DEBUG_) && !defined(_CVI_USE_FUNCS_FOR_VARS_)
#define getc(str) ((str)->next < (str)->readEnd ? \
          *(str)->next++ : (getc)(str))

#define getchar() (_files[0]->next < _files[0]->readEnd ? \
          *_files[0]->next++ : (getchar)())

#define putc(c,str)  ((str)->next < (str)->writeEnd ? \
          (*(str)->next++ = (c)) : (putc)(c, str))

#define putchar(c)   (_files[1]->next < _files[1]->writeEnd ? \
          (*_files[1]->next++ = (c)) : (putchar)(c))
#endif

#ifdef __cplusplus
    }
#endif

#endif
