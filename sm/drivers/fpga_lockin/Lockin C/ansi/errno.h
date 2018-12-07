/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       errno.h                                                       */
/* Purpose:     Include file for ANSI Standard C Library error interface.     */
/*                                                                            */
/*============================================================================*/

#ifndef _ERRNO
#define _ERRNO

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

/***************************************************************/
/* In Windows 3.1, the error reporting is limited.             */
/* When a call to the operating system fails,                  */
/* errno is always set to EIO.                                 */
/***************************************************************/

/***************************************************************/
/* Although the ANSI standard specifically states that the     */
/* type of the global variable errno must be int, CVI          */
/* defines errno with an enumeration type so that the          */
/* function panels and variable display show error names       */
/* instead of integer values.  If you require that errno be    */
/* declared with int type, define the preprocessor symbol      */
/* DISABLE_ERRNO_ENUM before including this file.              */
/***************************************************************/
#ifdef DISABLE_ERRNO_ENUM
#define _errnoType int

#else

typedef enum {
    ENOERR  =  0,   /* no error */
    EPERM   =  1,
    ENOENT  =  2,   /* No such file or directory */
    ESRCH   =  3,
    EINTR   =  4,
    EIO     =  5,   /* I/O error */
    ENXIO   =  6,
    E2BIG   =  7,
    ENOEXEC =  8,
    EBADF   =  9,   /* Bad file handle */
    ECHILD  = 10,
    EAGAIN  = 11,
    ENOMEM  = 12,   /* Insufficient memory */
    EACCES  = 13,   /* Access denied */
    EFAULT  = 14,
    ENOTBLK = 15,
    EBUSY   = 16,
    EEXIST  = 17,   /* File exists */
    EXDEV   = 18,
    ENODEV  = 19,
    ENOTDIR = 20,
    EISDIR  = 21,
    EINVAL  = 22,   /* Invalid argument */
    ENFILE  = 23,
    EMFILE  = 24,   /* Too many open files */
    ENOTTY  = 25,
    ETXTBSY = 26,
    EFBIG   = 27,
    ENOSPC  = 28,   /* No space left on device */
    ESPIPE  = 29,
    EROFS   = 30,
    EMLINK  = 31,
    EPIPE   = 32,
    EDOM    = 33,   /* domain error */
    ERANGE  = 34,   /* range error */

#ifndef _NI_sparc_
    ENAMETOOLONG = 35,  /* File name too long */
#endif

#ifdef _NI_sparc_

#if _NI_sparc_ == 1

    EWOULDBLOCK     = 35,       /* Operation would block */
    EINPROGRESS     = 36,       /* Operation now in progress */
    EALREADY        = 37,       /* Operation already in progress */
    ENOTSOCK        = 38,       /* Socket operation on non-socket */
    EDESTADDRREQ    = 39,       /* Destination address required */
    EMSGSIZE        = 40,       /* Message too long */
    EPROTOTYPE      = 41,       /* Protocol wrong type for socket */
    ENOPROTOOPT     = 42,       /* Protocol not available */
    EPROTONOSUPPORT = 43,       /* Protocol not supported */
    ESOCKTNOSUPPORT = 44,       /* Socket type not supported */
    EOPNOTSUPP      = 45,       /* Operation not supported on socket */
    EPFNOSUPPORT    = 46,       /* Protocol family not supported */
    EAFNOSUPPORT    = 47,       /* Address family not supported by protocol family */
    EADDRINUSE      = 48,       /* Address already in use */
    EADDRNOTAVAIL   = 49,       /* Can't assign requested address */
    ENETDOWN        = 50,       /* Network is down */
    ENETUNREACH     = 51,       /* Network is unreachable */
    ENETRESET       = 52,       /* Network dropped connection on reset */
    ECONNABORTED    = 53,       /* Software caused connection abort */
    ECONNRESET      = 54,       /* Connection reset by peer */
    ENOBUFS         = 55,       /* No buffer space available */
    EISCONN         = 56,       /* Socket is already connected */
    ENOTCONN        = 57,       /* Socket is not connected */
    ESHUTDOWN       = 58,       /* Can't send after socket shutdown */
    ETOOMANYREFS    = 59,       /* Too many references: can't splice */
    ETIMEDOUT       = 60,       /* Connection timed out */
    ECONNREFUSED    = 61,       /* Connection refused */
    ELOOP           = 62,       /* Too many levels of symbolic links */
    ENAMETOOLONG    = 63,       /* File name too long */
    EHOSTDOWN       = 64,       /* Host is down */
    EHOSTUNREACH    = 65,       /* No route to host */
    ENOTEMPTY       = 66,       /* Directory not empty */
    EPROCLIM        = 67,       /* Too many processes */
    EUSERS          = 68,       /* Too many users */
    EDQUOT          = 69,       /* Disc quota exceeded */
    ESTALE          = 70,       /* Stale NFS file handle */
    EREMOTE         = 71,       /* Too many levels of remote in path */
    ENOSTR          = 72,       /* Device is not a stream */
    ETIME           = 73,       /* Timer expired */
    ENOSR           = 74,       /* Out of streams resources */
    ENOMSG          = 75,       /* No message of desired type */
    EBADMSG         = 76,       /* Trying to read unreadable message */
    EIDRM           = 77,       /* Identifier removed */
    EDEADLK         = 78,       /* Deadlock condition. */
    ENOLCK          = 79,       /* No record locks available. */
    ENONET          = 80,       /* Machine is not on the network */
    ERREMOTE        = 81,       /* Object is remote */
    ENOLINK         = 82,       /* the link has been severed */
    EADV            = 83,       /* advertise error */
    ESRMNT          = 84,       /* srmount error */
    ECOMM           = 85,       /* Communication error on send */
    EPROTO          = 86,       /* Protocol error */
    EMULTIHOP       = 87,       /* multihop attempted */
    EDOTDOT         = 88,       /* Cross mount point (not an error) */
    EREMCHG         = 89,       /* Remote address changed */
    ENOSYS          = 90,       /* function not implemented */

#elif _NI_sparc_ == 2

    ENOMSG          = 35,   /* No message of desired type       */
    EIDRM           = 36,   /* Identifier removed           */
    ECHRNG          = 37,   /* Channel number out of range      */
    EL2NSYNC        = 38,   /* Level 2 not synchronized     */
    EL3HLT          = 39,   /* Level 3 halted           */
    EL3RST          = 40,   /* Level 3 reset            */
    ELNRNG          = 41,   /* Link number out of range     */
    EUNATCH         = 42,   /* Protocol driver not attached     */
    ENOCSI          = 43,   /* No CSI structure available       */
    EL2HLT          = 44,   /* Level 2 halted           */
    EDEADLK         = 45,   /* Deadlock condition.          */
    ENOLCK          = 46,   /* No record locks available.       */
    ECANCELED       = 47,   /* Operation canceled           */
    ENOTSUP         = 48,   /* Operation not supported      */
    EBADE           = 50,   /* invalid exchange         */
    EBADR           = 51,   /* invalid request descriptor       */
    EXFULL          = 52,   /* exchange full            */
    ENOANO          = 53,   /* no anode             */
    EBADRQC         = 54,   /* invalid request code         */
    EBADSLT         = 55,   /* invalid slot             */
    EDEADLOCK       = 56,   /* file locking deadlock error      */
    EBFONT          = 57,   /* bad font file fmt            */
    ENOSTR          = 60,   /* Device not a stream          */
    ENODATA         = 61,   /* no data (for no delay io)        */
    ETIME           = 62,   /* timer expired            */
    ENOSR           = 63,   /* out of streams resources     */
    ENONET          = 64,   /* Machine is not on the network    */
    ENOPKG          = 65,   /* Package not installed        */
    EREMOTE         = 66,   /* The object is remote         */
    ENOLINK         = 67,   /* the link has been severed        */
    EADV            = 68,   /* advertise error          */
    ESRMNT          = 69,   /* srmount error            */
    ECOMM           = 70,   /* Communication error on send      */
    EPROTO          = 71,   /* Protocol error           */
    EMULTIHOP       = 74,   /* multihop attempted           */
    EBADMSG         = 77,   /* trying to read unreadable message    */
    ENAMETOOLONG    = 78,   /* path name is too long        */
    EOVERFLOW       = 79,   /* value too large to be stored in data type */
    ENOTUNIQ        = 80,   /* given log. name not unique       */
    EBADFD          = 81,   /* f.d. invalid for this operation  */
    EREMCHG         = 82,   /* Remote address changed       */
    ELIBACC         = 83,   /* Can't access a needed shared lib.    */
    ELIBBAD         = 84,   /* Accessing a corrupted shared lib.    */
    ELIBSCN         = 85,   /* .lib section in a.out corrupted. */
    ELIBMAX         = 86,   /* Attempting to link in too many libs. */
    ELIBEXEC        = 87,   /* Attempting to exec a shared library. */
    EILSEQ          = 88,   /* Illegal byte sequence.       */
    ENOSYS          = 89,   /* Unsupported file system operation    */
    ELOOP           = 90,   /* Symbolic link loop           */
    ERESTART        = 91,   /* Restartable system call      */
    ESTRPIPE        = 92,   /* if pipe/FIFO, don't sleep in stream head */
    ENOTEMPTY       = 93,   /* directory not empty          */
    EUSERS          = 94,   /* Too many users (for UFS)     */
    ENOTSOCK        = 95,   /* Socket operation on non-socket */
    EDESTADDRREQ    = 96,   /* Destination address required */
    EMSGSIZE        = 97,   /* Message too long */
    EPROTOTYPE      = 98,   /* Protocol wrong type for socket */
    ENOPROTOOPT     = 99,   /* Protocol not available */
    EPROTONOSUPPORT = 120,  /* Protocol not supported */
    ESOCKTNOSUPPORT = 121,  /* Socket type not supported */
    EOPNOTSUPP      = 122,  /* Operation not supported on socket */
    EPFNOSUPPORT    = 123,  /* Protocol family not supported */
    EAFNOSUPPORT    = 124,  /* Address family not supported by */
    EADDRINUSE      = 125,  /* Address already in use */
    EADDRNOTAVAIL   = 126,  /* Can't assign requested address */
    ENETDOWN        = 127,  /* Network is down */
    ENETUNREACH     = 128,  /* Network is unreachable */
    ENETRESET       = 129,  /* Network dropped connection because */
                            /* of reset */
    ECONNABORTED    = 130,  /* Software caused connection abort */
    ECONNRESET      = 131,  /* Connection reset by peer */
    ENOBUFS         = 132,  /* No buffer space available */
    EISCONN         = 133,  /* Socket is already connected */
    ENOTCONN        = 134,  /* Socket is not connected */
    ESHUTDOWN       = 143,  /* Can't send after socket shutdown */
    ETOOMANYREFS    = 144,  /* Too many references: can't splice */
    ETIMEDOUT       = 145,  /* Connection timed out */
    ECONNREFUSED    = 146,  /* Connection refused */
    EHOSTDOWN       = 147,  /* Host is down */
    EHOSTUNREACH    = 148,  /* No route to host */
    EALREADY        = 149,  /* operation already in progress */
    EINPROGRESS     = 150,  /* operation now in progress */
    ESTALE          = 151,  /* Stale NFS file handle */


#else
#error Illegal value for _NI_sparc_ [must be 1 (SunOS4) or 2 (SunOS5)

#endif /* _NI_sparc_ == ?? */

#endif /* def _NI_sparc_ */

    _errnoTypeUnused = 0x7fffffff   /* makes _errnoType an int */

} _errnoType;

#endif /* !DISABLE_ERRNO_ENUM */

#define EPERM   1
#define ENOENT  2
#define ESRCH   3
#define EINTR   4
#define EIO     5
#define ENXIO   6
#define E2BIG   7
#define ENOEXEC 8
#define EBADF   9
#define ECHILD  10
#define EAGAIN  11
#define ENOMEM  12
#define EACCES  13
#define EFAULT  14
#define ENOTBLK 15
#define EBUSY   16
#define EEXIST  17
#define EXDEV   18
#define ENODEV  19
#define ENOTDIR 20
#define EISDIR  21
#define EINVAL  22
#define ENFILE  23
#define EMFILE  24
#define ENOTTY  25
#define ETXTBSY 26
#define EFBIG   27
#define ENOSPC  28
#define ESPIPE  29
#define EROFS   30
#define EMLINK  31
#define EPIPE   32
#define EDOM    33
#define ERANGE  34

#ifndef _NI_sparc_
#define ENAMETOOLONG    35
#endif

#ifdef _NI_sparc_

/* This section taken from SunOS /usr/include/sys/errno.h */

#if _NI_sparc_ == 1

/* non-blocking and interrupt i/o */
#define EWOULDBLOCK     35      /* Operation would block */
#define EINPROGRESS     36      /* Operation now in progress */
#define EALREADY        37      /* Operation already in progress */
/* ipc/network software */

    /* argument errors */
#define ENOTSOCK        38      /* Socket operation on non-socket */
#define EDESTADDRREQ    39      /* Destination address required */
#define EMSGSIZE        40      /* Message too long */
#define EPROTOTYPE      41      /* Protocol wrong type for socket */
#define ENOPROTOOPT     42      /* Protocol not available */
#define EPROTONOSUPPORT 43      /* Protocol not supported */
#define ESOCKTNOSUPPORT 44      /* Socket type not supported */
#define EOPNOTSUPP      45      /* Operation not supported on socket */
#define EPFNOSUPPORT    46      /* Protocol family not supported */
#define EAFNOSUPPORT    47      /* Address family not supported by protocol family */
#define EADDRINUSE      48      /* Address already in use */
#define EADDRNOTAVAIL   49      /* Can't assign requested address */

    /* operational errors */
#define ENETDOWN        50      /* Network is down */
#define ENETUNREACH     51      /* Network is unreachable */
#define ENETRESET       52      /* Network dropped connection on reset */
#define ECONNABORTED    53      /* Software caused connection abort */
#define ECONNRESET      54      /* Connection reset by peer */
#define ENOBUFS         55      /* No buffer space available */
#define EISCONN         56      /* Socket is already connected */
#define ENOTCONN        57      /* Socket is not connected */
#define ESHUTDOWN       58      /* Can't send after socket shutdown */
#define ETOOMANYREFS    59      /* Too many references: can't splice */
#define ETIMEDOUT       60      /* Connection timed out */
#define ECONNREFUSED    61      /* Connection refused */

    /* */
#define ELOOP           62      /* Too many levels of symbolic links */
#define ENAMETOOLONG    63      /* File name too long */

/* should be rearranged */
#define EHOSTDOWN       64      /* Host is down */
#define EHOSTUNREACH    65      /* No route to host */
#define ENOTEMPTY       66      /* Directory not empty */

/* quotas & mush */
#define EPROCLIM        67      /* Too many processes */
#define EUSERS          68      /* Too many users */
#define EDQUOT          69      /* Disc quota exceeded */

/* Network File System */
#define ESTALE          70      /* Stale NFS file handle */
#define EREMOTE         71      /* Too many levels of remote in path */

/* streams */
#define ENOSTR          72      /* Device is not a stream */
#define ETIME           73      /* Timer expired */
#define ENOSR           74      /* Out of streams resources */
#define ENOMSG          75      /* No message of desired type */
#define EBADMSG         76      /* Trying to read unreadable message */

/* SystemV IPC */
#define EIDRM           77      /* Identifier removed */

/* SystemV Record Locking */
#define EDEADLK         78      /* Deadlock condition. */
#define ENOLCK          79      /* No record locks available. */

/* RFS */
#define ENONET          80      /* Machine is not on the network */
#define ERREMOTE        81      /* Object is remote */
#define ENOLINK         82      /* the link has been severed */
#define EADV            83      /* advertise error */
#define ESRMNT          84      /* srmount error */
#define ECOMM           85      /* Communication error on send */
#define EPROTO          86      /* Protocol error */
#define EMULTIHOP       87      /* multihop attempted */
#define EDOTDOT         88      /* Cross mount point (not an error) */
#define EREMCHG         89      /* Remote address changed */

/* POSIX */
#define ENOSYS          90      /* function not implemented */

#elif _NI_sparc_ == 2

#define ENOMSG      35  /* No message of desired type       */
#define EIDRM       36  /* Identifier removed           */
#define ECHRNG      37  /* Channel number out of range      */
#define EL2NSYNC    38  /* Level 2 not synchronized     */
#define EL3HLT      39  /* Level 3 halted           */
#define EL3RST      40  /* Level 3 reset            */
#define ELNRNG      41  /* Link number out of range     */
#define EUNATCH     42  /* Protocol driver not attached     */
#define ENOCSI      43  /* No CSI structure available       */
#define EL2HLT      44  /* Level 2 halted           */
#define EDEADLK     45  /* Deadlock condition.          */
#define ENOLCK      46  /* No record locks available.       */
#define ECANCELED   47  /* Operation canceled           */
#define ENOTSUP     48  /* Operation not supported      */

/* Convergent Error Returns */
#define EBADE       50  /* invalid exchange         */
#define EBADR       51  /* invalid request descriptor       */
#define EXFULL      52  /* exchange full            */
#define ENOANO      53  /* no anode             */
#define EBADRQC     54  /* invalid request code         */
#define EBADSLT     55  /* invalid slot             */
#define EDEADLOCK   56  /* file locking deadlock error      */

#define EBFONT      57  /* bad font file fmt            */

/* stream proble    ms */
#define ENOSTR      60  /* Device not a stream          */
#define ENODATA     61  /* no data (for no delay io)        */
#define ETIME       62  /* timer expired            */
#define ENOSR       63  /* out of streams resources     */

#define ENONET      64  /* Machine is not on the network    */
#define ENOPKG      65  /* Package not installed        */
#define EREMOTE     66  /* The object is remote         */
#define ENOLINK     67  /* the link has been severed        */
#define EADV        68  /* advertise error          */
#define ESRMNT      69  /* srmount error            */

#define ECOMM       70  /* Communication error on send      */
#define EPROTO      71  /* Protocol error           */
#define EMULTIHOP   74  /* multihop attempted           */
#define EBADMSG     77  /* trying to read unreadable message    */
#define ENAMETOOLONG 78 /* path name is too long        */
#define EOVERFLOW   79  /* value too large to be stored in data type */
#define ENOTUNIQ    80  /* given log. name not unique       */
#define EBADFD      81  /* f.d. invalid for this operation  */
#define EREMCHG     82  /* Remote address changed       */

/* shared library problems */
#define ELIBACC     83  /* Can't access a needed shared lib.    */
#define ELIBBAD     84  /* Accessing a corrupted shared lib.    */
#define ELIBSCN     85  /* .lib section in a.out corrupted. */
#define ELIBMAX     86  /* Attempting to link in too many libs. */
#define ELIBEXEC    87  /* Attempting to exec a shared library. */
#define EILSEQ      88  /* Illegal byte sequence.       */
#define ENOSYS      89  /* Unsupported file system operation    */
#define ELOOP       90  /* Symbolic link loop           */
#define ERESTART    91  /* Restartable system call      */
#define ESTRPIPE    92  /* if pipe/FIFO, don't sleep in stream head */
#define ENOTEMPTY   93  /* directory not empty          */
#define EUSERS      94  /* Too many users (for UFS)     */

/* BSD Networking Software */
    /* argument errors */
#define ENOTSOCK        95  /* Socket operation on non-socket */
#define EDESTADDRREQ    96  /* Destination address required */
#define EMSGSIZE        97  /* Message too long */
#define EPROTOTYPE      98  /* Protocol wrong type for socket */
#define ENOPROTOOPT     99  /* Protocol not available */
#define EPROTONOSUPPORT 120 /* Protocol not supported */
#define ESOCKTNOSUPPORT 121 /* Socket type not supported */
#define EOPNOTSUPP      122 /* Operation not supported on socket */
#define EPFNOSUPPORT    123 /* Protocol family not supported */
#define EAFNOSUPPORT    124 /* Address family not supported by */
                /* protocol family */
#define EADDRINUSE      125 /* Address already in use */
#define EADDRNOTAVAIL   126 /* Can't assign requested address */
    /* operational errors */
#define ENETDOWN        127 /* Network is down */
#define ENETUNREACH     128 /* Network is unreachable */
#define ENETRESET       129 /* Network dropped connection because */
                            /* of reset */
#define ECONNABORTED    130 /* Software caused connection abort */
#define ECONNRESET      131 /* Connection reset by peer */
#define ENOBUFS         132 /* No buffer space available */
#define EISCONN         133 /* Socket is already connected */
#define ENOTCONN        134 /* Socket is not connected */
/* XENIX has 135 - 142 */
#define ESHUTDOWN       143 /* Can't send after socket shutdown */
#define ETOOMANYREFS    144 /* Too many references: can't splice */
#define ETIMEDOUT       145 /* Connection timed out */
#define ECONNREFUSED    146 /* Connection refused */
#define EHOSTDOWN       147 /* Host is down */
#define EHOSTUNREACH    148 /* No route to host */
#define EWOULDBLOCK     EAGAIN
#define EALREADY        149 /* operation already in progress */
#define EINPROGRESS     150 /* operation now in progress */

/* SUN Network File System */
#define ESTALE          151 /* Stale NFS file handle */


#else
#error Illegal value for _NI_sparc_ [must be 1 (SunOS4) or 2 (SunOS5)

#endif /* _NI_sparc_ == ?? */

#endif /* def _NI_sparc_ */


#ifdef _CVI_USE_FUNCS_FOR_VARS_
    extern _errnoType * CVIFUNC_C _GetErrno(void);
    #define errno (*_GetErrno())
#else
    extern _errnoType errno;
#endif

#ifdef __cplusplus
    }
#endif

#endif /* ndef _ERRNO */
