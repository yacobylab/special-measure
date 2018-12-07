/* lowlvlio.h : These defines are usually in fcntl.h, sys/types.h, and
           sys/stat.h */

#ifndef LOWLVLIO_H
#define LOWLVLIO_H

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

/* some systems prepend underscores */

/********************************************************/
/* mode flags for oflag parameter to open() and sopen() */
/********************************************************/
#define O_RDONLY        0x0
#define O_WRONLY        0x1
#define O_RDWR          0x2
#define O_APPEND        0x4     /* all writes append to file */
#define O_CREAT         0x8     /* if file does not exist, create it */
#define O_TRUNC         0x10    /* if file exists, truncate it to 0 bytes */
#define O_BINARY        0x20    /* do not translate newline/carriage returns */
#define O_TEXT          0x40    /* translate newline/carriage returns to newlines */
#define O_EXCL          0x80    /* if O_CREAT, report error if file exists */
#define O_TEMPORARY     0x100   /* win32 only */
#define O_RANDOM        0x200   /* win32 only */
#define O_SEQUENTIAL    0x400   /* win32 only */

#define _O_RDONLY       O_RDONLY
#define _O_WRONLY       O_WRONLY
#define _O_RDWR         O_RDWR
#define _O_APPEND       O_APPEND
#define _O_CREAT        O_CREAT
#define _O_TRUNC        O_TRUNC
#define _O_BINARY       O_BINARY
#define _O_TEXT         O_TEXT
#define _O_EXCL         O_EXCL
#define _O_TEMPORARY    O_TEMPORARY
#define _O_RANDOM       O_RANDOM
#define _O_SEQUENTIAL   O_SEQUENTIAL


/************************************************************/
/* sharing flags, for shflag parameter to sopen()           */
/* These flags determine whether other applications can     */
/* open the file while your application has it open.        */
/* When you use open(), it acts as if you set shflag to     */
/* SH_COMPAT.                                               */
/************************************************************/
#define SH_DENYRW   0       /* deny read and write permission to other apps*/
#define SH_DENYWR   1       /* deny write permission to other apps */
#define SH_DENYRD   2       /* deny read permission to other apps */
#define SH_DENYNO   3       /* do not deny permission */
#define SH_COMPAT   4       /* Windows 3.1: allows other apps to open with any      */
                            /*      permissions if they use the SH_COMPAT sharing   */
                            /*      flag.  Prevents other apps from opening with    */
                            /*      different share flags.                          */
                            /* Windows NT/95: Same as SH_DENYNO                     */
#define _SH_DENYRW  SH_DENYRW
#define _SH_DENYWR  SH_DENYWR
#define _SH_DENYRD  SH_DENYRD
#define _SH_DENYNO  SH_DENYNO
#define _SH_COMPAT  SH_COMPAT

/*************************************************************************/
/* permission flags for last (optional) parameter to open() and sopen()  */
/* These flags are used only when you are creating a file.               */
/* All of these flags are defined in this file to be compatible with     */
/* the POSIX standard.  However, under Windows, they really affect only  */
/* whether the file is a read-only file.  In Windows,                    */
/*   -  there is no distinction between "owner", "group", or, "others"   */
/*      (if a permission is set of any of the three, it is set for all). */
/*   -  the read and execute permissions are ignored.                    */
/*   -  a file cannot be created write-only permissions.                 */
/*   -  the sticky bits are ignored.                                     */
/*************************************************************************/

/* Owner permissions */
#define S_IRUSR      0x1       /* ignored in Windows */
#define S_IWUSR      0x2
#define S_IXUSR      0x4       /* ignored in Windows */
#define S_IRWXU      0x7
#define _S_IRUSR     S_IRUSR
#define _S_IWUSR     S_IWUSR
#define _S_IXUSR     S_IXUSR
#define _S_IRWXU     S_IRWXU


/* group permissions */
#define S_IRGRP      0x10     /* ignored in Windows */
#define S_IWGRP      0x20
#define S_IXGRP      0x40     /* ignored in Windows */
#define S_IRWXG      0x70
#define _S_IRGRP     S_IRGRP
#define _S_IWGRP     S_IWGRP
#define _S_IXGRP     S_IXGRP
#define _S_IRWXG     S_IRWXG


/* other permissions */
#define S_IROTH      0x100       /* ignored in Windows */
#define S_IWOTH      0x200
#define S_IXOTH      0x400       /* ignored in Windows */
#define S_IRWXO      0x700
#define _S_IROTH     S_IROTH
#define _S_IWOTH     S_IWOTH
#define _S_IXOTH     S_IXOTH
#define _S_IRWXO     S_IRWXO


/************************************/
/* sticky bits - ignored in Windows */
/************************************/
#define S_ISUID      0x1000
#define S_IGUIS      0x2000
#define _S_ISUID     S_ISUID
#define _S_IGUIS     S_IGUIS


/**************************************/
/* summaries across owner/group/other */
/**************************************/
#define S_IREAD      (S_IRUSR | S_IRGRP | S_IROTH)    /* ignored in Windows */
#define S_IWRITE     (S_IWUSR | S_IWGRP | S_IWOTH)
#define S_IEXEC      (S_IXUSR | S_IXGRP | S_IXOTH)    /* ignored in Windows */
#define _S_IREAD     S_IREAD
#define _S_IWRITE    S_IWRITE
#define _S_IEXEC     S_IEXEC


/*******************************/
/* whence parameter to lseek() */
/*******************************/
#ifndef SEEK_SET
#define SEEK_SET    0
#define SEEK_CUR    1
#define SEEK_END    2
#endif

int CVIFUNC eof(int filedes);
long CVIFUNC lseek(int filedes, long offset, int whence);
int CVIFUNC write(int filedes, const void *buf, unsigned int nbytes);
int CVIFUNC read(int filedes, void *buf, unsigned int nbytes);
int CVIFUNC close(int filedes);
int CVIFUNC_C open(const char *filename, int oflag, ... /* int permissions */);
int CVIFUNC_C sopen(const char *filename, int oflag, int shflag, ... /* int permissions */);

#ifdef __cplusplus
    }
#endif

#endif /* LOWLVLIO_H */




