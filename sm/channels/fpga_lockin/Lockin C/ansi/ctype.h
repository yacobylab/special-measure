/*============================================================================*/
/*                        L a b W i n d o w s / C V I                         */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 1987-1999.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       ctype.h                                                       */
/* Purpose:     Include file for ANSI Standard C function declarations and    */
/*              macros useful for classifying and mapping codes from the      */
/*              target character set.                                         */
/*                                                                            */
/*============================================================================*/

#ifndef _CTYPE
#define _CTYPE

#include "cvidef.h"
#include "cvirte.h"

#ifdef __cplusplus
    extern "C" {
#endif

#ifndef _WCHAR_T_DEFINED
#define _WCHAR_T_DEFINED
#define _WCHAR_T
typedef unsigned short wchar_t;
typedef unsigned short sdk_wchar_t;
#endif

int CVIANSI isalnum(int);
int CVIANSI isalpha(int);
int CVIANSI iscntrl(int);
int CVIANSI isdigit(int);
int CVIANSI isgraph(int);
int CVIANSI islower(int);
int CVIANSI isprint(int);
int CVIANSI ispunct(int);
int CVIANSI isspace(int);
int CVIANSI isupper(int);
int CVIANSI isxdigit(int);
int CVIANSI tolower(int);
int CVIANSI toupper(int);

#if !defined(_NI_mswin_) && !defined(_NI_mswin16_) && !defined(_NI_mswin32_)
#ifndef _CVI_DEBUG_
extern const short *const _AsciiMaskTab;
extern const short *const _ToLowerTab;
extern const short *const _ToUpperTab;

#define _XTRA_SPC               0x200
#define _XTRA_ALPH              0x100
#define _CTRL_AND_SPC           0x080
#define _CTRL                   0x040
#define _XDIGIT                 0x020
#define _DIGIT                  0x010
#define _U_CASE                 0x008
#define _L_CASE                 0x004
#define _PUNCT                  0x002
#define _SPACE                  0x001

#define _0_TO_9                 (_DIGIT | _XDIGIT)
#define _A_TO_F                 (_U_CASE | _XDIGIT)
#define _a_to_f                 (_L_CASE | _XDIGIT)

#define isalnum(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & (_DIGIT | _L_CASE | _U_CASE | _XTRA_ALPH))

#define isalpha(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & (_L_CASE | _U_CASE | _XTRA_ALPH))

#define iscntrl(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & (_CTRL | _CTRL_AND_SPC))

#define isdigit(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & _DIGIT)

#define isgraph(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & (_DIGIT | _L_CASE | _U_CASE | _PUNCT | _XTRA_ALPH))

#define islower(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & _L_CASE)

#define isprint(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & (_DIGIT | _L_CASE | _U_CASE | _PUNCT | _SPACE | _XTRA_ALPH))

#define ispunct(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & _PUNCT)

#define isspace(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & (_SPACE | _CTRL_AND_SPC | _XTRA_SPC))

#define isupper(ch)             (_AsciiMaskTab[(int)(unsigned char)(ch)] & _U_CASE)

#define isxdigit(ch)            (_AsciiMaskTab[(int)(unsigned char)(ch)] & _XDIGIT)

#define tolower(ch)             (_ToLowerTab[(int)(unsigned char)(ch)])

#define toupper(ch)             (_ToUpperTab[(int)(unsigned char)(ch)])

#endif
#endif /* _NI_mswin_ */

#ifdef __cplusplus
    }
#endif

#endif

