/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       assert.h                                                      */
/* Purpose:     Include file for ANSI Standard C assertion handler            */
/*                                                                            */
/*============================================================================*/

#include "cvidef.h"
#include "cvirte.h"

#ifndef _ASSERT_H_
#define _ASSERT_H_

#ifdef __cplusplus
    extern "C" {
#endif

#undef assert

#ifdef NDEBUG
#define assert(exp) ((void)  0)

#else
void CVIANSI _assert(char *, char *, int);

#define assert(exp) ((exp) ? (void) 0 : _assert(#exp, __FILE__, __LINE__))
#endif

#ifdef __cplusplus
    }
#endif

#endif /* _ASSERT_H_ */
