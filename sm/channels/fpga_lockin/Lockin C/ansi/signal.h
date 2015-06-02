/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       signal.h                                                      */
/* Purpose:     Include file for ANSI Standard C support of asynchronous      */
/*              signal event handling.                                        */
/*                                                                            */
/*============================================================================*/

#ifndef _CVI_SIGNAL_H
#define _CVI_SIGNAL_H

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#ifndef _SIG_ATOMIC_T
#define _SIG_ATOMIC_T
typedef int sig_atomic_t;
#endif


#define SIG_DFL (void (CVIANSI *)(int))0
#define SIG_ERR (void (CVIANSI *)(int))-1
#define SIG_IGN (void (CVIANSI *)(int))1

#if defined(_NI_sparc_)

#if _NI_sparc_ == 1     /* SunOS 4.x */

#define SIGHUP  1       /* hangup */
#define SIGINT  2       /* interrupt */
#define SIGQUIT 3       /* quit */
#define SIGILL  4       /* illegal instruction (not reset when caught) */
#define SIGTRAP 5       /* trace trap (not reset when caught) */
#define SIGIOT  6       /* IOT instruction */
#define SIGABRT 6       /* used by abort, replace SIGIOT in the future */
#define SIGEMT  7       /* EMT instruction */
#define SIGFPE  8       /* floating point exception */
#define SIGKILL 9       /* kill (cannot be caught or ignored) */
#define SIGBUS  10      /* bus error */
#define SIGSEGV 11      /* segmentation violation */
#define SIGSYS  12      /* bad argument to system call */
#define SIGPIPE 13      /* write on a pipe with no one to read it */
#define SIGALRM 14      /* alarm clock */
#define SIGTERM 15      /* software termination signal from kill */
#define SIGURG  16      /* urgent condition on IO channel */
#define SIGSTOP 17      /* sendable stop signal not from tty */
#define SIGTSTP 18      /* stop signal from tty */
#define SIGCONT 19      /* continue a stopped process */
#define SIGCHLD 20      /* to parent on child stop or exit */
#define SIGCLD  20      /* System V name for SIGCHLD */
#define SIGTTIN 21      /* to readers pgrp upon background tty read */
#define SIGTTOU 22      /* like TTIN for output if (tp->t_local&LTOSTOP) */
#define SIGIO   23      /* input/output possible signal */
#define SIGPOLL SIGIO   /* System V name for SIGIO */
#define SIGXCPU 24      /* exceeded CPU time limit */
#define SIGXFSZ 25      /* exceeded file size limit */
#define SIGVTALRM 26    /* virtual time alarm */
#define SIGPROF 27      /* profiling time alarm */
#define SIGWINCH 28     /* window changed */
#define SIGLOST 29      /* resource lost (eg, record-lock lost) */
#define SIGUSR1 30      /* user defined signal 1 */
#define SIGUSR2 31      /* user defined signal 2 */

#elif _NI_sparc_ == 2   /* SunOS 5.x */

#define SIGHUP  1       /* hangup */
#define SIGINT  2       /* interrupt (rubout) */
#define SIGQUIT 3       /* quit (ASCII FS) */
#define SIGILL  4       /* illegal instruction (not reset when caught) */
#define SIGTRAP 5       /* trace trap (not reset when caught) */
#define SIGIOT  6       /* IOT instruction */
#define SIGABRT 6       /* used by abort, replace SIGIOT in the future */
#define SIGEMT  7       /* EMT instruction */
#define SIGFPE  8       /* floating point exception */
#define SIGKILL 9       /* kill (cannot be caught or ignored) */
#define SIGBUS  10      /* bus error */
#define SIGSEGV 11      /* segmentation violation */
#define SIGSYS  12      /* bad argument to system call */
#define SIGPIPE 13      /* write on a pipe with no one to read it */
#define SIGALRM 14      /* alarm clock */
#define SIGTERM 15      /* software termination signal from kill */
#define SIGUSR1 16      /* user defined signal 1 */
#define SIGUSR2 17      /* user defined signal 2 */
#define SIGCLD  18      /* child status change */
#define SIGCHLD 18      /* child status change alias (POSIX) */
#define SIGPWR  19      /* power-fail restart */
#define SIGWINCH 20     /* window size change */
#define SIGURG  21      /* urgent socket condition */
#define SIGPOLL 22      /* pollable event occured */
#define SIGIO   SIGPOLL /* socket I/O possible (SIGPOLL alias) */
#define SIGSTOP 23      /* stop (cannot be caught or ignored) */
#define SIGTSTP 24      /* user stop requested from tty */
#define SIGCONT 25      /* stopped process has been continued */
#define SIGTTIN 26      /* background tty read attempted */
#define SIGTTOU 27      /* background tty write attempted */
#define SIGVTALRM 28    /* virtual timer expired */
#define SIGPROF 29      /* profiling timer expired */
#define SIGXCPU 30      /* exceeded cpu limit */
#define SIGXFSZ 31      /* exceeded file size limit */
#define SIGWAITING 32   /* process's lwps are blocked */
#define SIGLWP  33      /* special signal used by thread library */
#define SIGFREEZE 34    /* special signal used by CPR */
#define SIGTHAW 35      /* special signal used by CPR */

#else
#error Illegal value for _NI_sparc_ [must be 1 (SunOS4) or 2 (SunOS5)]
#endif

#elif defined(_NI_unix_)
/* Unknown Unix platform */

#else
#define SIGINT  1
#define SIGILL  2
#define SIGABRT 3
#define SIGFPE  4
#define SIGSEGV 5
#define SIGTERM 6
#endif

extern void (CVIANSI * CVIANSI signal(int, void (CVIANSI *)(int)))(int);
extern int CVIANSI raise(int);

#ifdef __cplusplus
    }
#endif

#endif
