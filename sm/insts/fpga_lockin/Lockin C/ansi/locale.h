/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       locale.h                                                      */
/* Purpose:     Include file for ANSI Standard C to alter or access prop-     */
/*              erties of the current character set locale.                   */
/*                                                                            */
/*============================================================================*/

#ifndef _LOCALE
#define _LOCALE

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#define LC_ALL      0
#define LC_COLLATE  1
#define LC_CTYPE    2
#define LC_MONETARY 3
#define LC_NUMERIC  4
#define LC_TIME     5

#ifndef NULL
#define NULL 0
#endif

#ifdef WIN32
    #pragma pack(push)
    #pragma pack(4)
#endif

struct lconv {
    char *decimal_point;
    char *thousands_sep;
    char *grouping;
    char *int_curr_symbol;
    char *currency_symbol;
    char *mon_decimal_point;
    char *mon_thousands_sep;
    char *mon_grouping;
    char *positive_sign;
    char *negative_sign;
    char int_frac_digits;
    char frac_digits;
    char p_cs_precedes;
    char p_sep_by_space;
    char n_cs_precedes;
    char n_sep_by_space;
    char p_sign_posn;
    char n_sign_posn;
};

#ifdef WIN32
    #pragma pack(pop)
#endif

char * CVIANSI setlocale(int, const char *);
struct lconv * CVIANSI localeconv(void);

#ifdef __cplusplus
    }
#endif

#endif /* _LOCALE */
