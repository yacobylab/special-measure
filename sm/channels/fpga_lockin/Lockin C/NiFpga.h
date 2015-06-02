/*
 * FPGA Interface C API 1.0 header file.
 *
 * Copyright (c) 2009,
 * National Instruments Corporation.
 * All rights reserved.
 */

#ifndef __NiFpga_h__
#define __NiFpga_h__

/*
 * Determine platform details.
 */
#if defined(_M_IX86) \
 || defined(_M_X64) \
 || defined(i386) \
 || defined(__i386__) \
 || defined(__amd64__) \
 || defined(__amd64) \
 || defined(__x86_64__) \
 || defined(__x86_64) \
 || defined(__i386) \
 || defined(_X86_) \
 || defined(__THW_INTEL__) \
 || defined(__I86__) \
 || defined(__INTEL__) \
 || defined(__X86__) \
 || defined(__386__) \
 || defined(__I86__) \
 || defined(M_I386) \
 || defined(M_I86) \
 || defined(_M_I386) \
 || defined(_M_I86)
   #if defined(_WIN32) \
    || defined(_WIN64) \
    || defined(__WIN32__) \
    || defined(__TOS_WIN__) \
    || defined(__WINDOWS__) \
    || defined(_WINDOWS) \
    || defined(__WINDOWS_386__)
      #define NiFpga_Windows 1
   #else
      #error Unsupported OS.
   #endif
#elif defined(__powerpc) \
   || defined(__powerpc__) \
   || defined(__POWERPC__) \
   || defined(__ppc__) \
   || defined(__PPC) \
   || defined(_M_PPC) \
   || defined(_ARCH_PPC) \
   || defined(__PPC__) \
   || defined(__ppc)
   #if defined(__vxworks)
      #define NiFpga_VxWorks 1
   #else
      #error Unsupported OS.
   #endif
#else
   #error Unsupported architecture.
#endif

/*
 * Determine compiler.
 */
#if defined(_CVI_)
   #define NiFpga_Cvi 1
#elif defined(_MSC_VER)
   #define NiFpga_Msvc 1
#elif defined(__GNUC__)
   #define NiFpga_Gcc 1
#else
   /* Unknown compiler. */
#endif

/*
 * Determine compliance with different C/C++ language standards.
 */
#if defined(__cplusplus)
   #define NiFpga_Cpp 1
   #if __cplusplus >= 199707L
      #define NiFpga_Cpp98 1
   #endif
#endif
#if defined(__STDC__)
   #define NiFpga_C89 1
   #if defined(__STDC_VERSION__)
      #define NiFpga_C90 1
      #if __STDC_VERSION__ >= 199409L
         #define NiFpga_C94 1
         #if __STDC_VERSION__ >= 199901L
            #define NiFpga_C99 1
         #endif
      #endif
   #endif
#endif

/*
 * Determine ability to inline functions.
 */
#if NiFpga_Cpp || NiFpga_C99
   /* The inline keyword exists in C++ and C99. */
   #define NiFpga_Inline inline
#elif NiFpga_Msvc
   /* Visual C++ (at least since 6.0) also supports an alternate keyword. */
   #define NiFpga_Inline __inline
#elif NiFpga_Gcc
   /* GCC (at least since 2.95.2) also supports an alternate keyword. */
   #define NiFpga_Inline __inline__
#else
   /* Inlining disabled. */
   #define NiFpga_Inline
#endif

/*
 * Define standard integer types.
 */
#if NiFpga_C99 \
 || NiFpga_VxWorks && NiFpga_Gcc
   #include <stdint.h>
#elif NiFpga_Cvi
   typedef   signed    char int8_t;
   typedef unsigned    char uint8_t;
   typedef   signed   short int16_t;
   typedef unsigned   short uint16_t;
   typedef   signed     int int32_t;
   typedef unsigned     int uint32_t;
   typedef   signed __int64 int64_t;
   typedef unsigned __int64 uint64_t;
#elif NiFpga_Msvc
   typedef   signed __int8  int8_t;
   typedef unsigned __int8  uint8_t;
   typedef   signed __int16 int16_t;
   typedef unsigned __int16 uint16_t;
   typedef   signed __int32 int32_t;
   typedef unsigned __int32 uint32_t;
   typedef   signed __int64 int64_t;
   typedef unsigned __int64 uint64_t;
#else
   /* Integer types must be defined by the client. */
#endif

#if NiFpga_Cpp
extern "C" {
#endif

	
/*****************************************************************************************************/
/*****************************************************************************************************/
/*****************************************************************************************************/
	
/*
 * FPGA Interface C API 1.0 source file.
 *
 * Copyright (c) 2009,
 * National Instruments Corporation.
 * All rights reserved.
 */


/*
 * Platform specific includes.
 */
#if NiFpga_Windows
   #include <windows.h>
#elif NiFpga_VxWorks
   #include <vxWorks.h>
   #include <symLib.h>
   #include <loadLib.h>
   #include <sysSymTbl.h>
   MODULE_ID VxLoadLibraryFromPath(const char* path, int flags);
   STATUS VxFreeLibrary(MODULE_ID library, int flags);
#else
   #error
#endif

/*
 * Platform specific defines.
 */
#if NiFpga_Windows
   #define NiFpga_CCall __cdecl
#else
   #define NiFpga_CCall
#endif

/*
 * Global library handle, or NULL if the library isn't loaded.
 */
#if NiFpga_Windows
   static HMODULE NiFpga_library = NULL;
#elif NiFpga_VxWorks
   static MODULE_ID NiFpga_library = NULL;
#else
   #error
#endif
   
/*****************************************************************************************************/
/*****************************************************************************************************/
/*****************************************************************************************************/
   
/**
 * A boolean value; either NiFpga_False or NiFpga_True.
 */
typedef uint8_t NiFpga_Bool;

/**
 * Represents a false condition.
 */
static const NiFpga_Bool NiFpga_False = 0;

/**
 * Represents a true condition.
 */
static const NiFpga_Bool NiFpga_True = 1;

/**
 * Represents the resulting status of a function call through its return value.
 * 0 is success, negative values are errors, and positive values are warnings.
 */
typedef int32_t NiFpga_Status;

/**
 * No errors or warnings.
 */
static const NiFpga_Status NiFpga_Status_Success = 0;

/**
 * A memory allocation failed. Try again after rebooting.
 */
static const NiFpga_Status NiFpga_Status_MemoryFull = -52000;

/**
 * An unexpected software error occurred.
 */
static const NiFpga_Status NiFpga_Status_SoftwareFault = -52003;

/**
 * A parameter to a function was not valid. This could be a NULL pointer, a bad
 * value, etc.
 */
static const NiFpga_Status NiFpga_Status_InvalidParameter = -52005;

/**
 * A needed resource was not found. This could be the NiFpga.dll/NiFpga.out
 * library, the RIO resource, or some other resource.
 */
static const NiFpga_Status NiFpga_Status_ResourceNotFound = -52006;

/**
 * A needed resource was not properly initialized. This could occur if
 * NiFpga_Initialize was not called.
 */
static const NiFpga_Status NiFpga_Status_ResourceNotInitialized = -52010;

/**
 * The FPGA is already running.
 */
static const NiFpga_Status NiFpga_Status_FpgaAlreadyRunning = -61003;

/**
 * The bitfile was not compiled for the specified resource's device type.
 */
static const NiFpga_Status NiFpga_Status_DeviceTypeMismatch = -61024;

/**
 * An error was detected in the communication between the host computer and the
 * FPGA target.
 */
static const NiFpga_Status NiFpga_Status_CommunicationTimeout = -61046;

/**
 * The timeout expired while waiting for an IRQ.
 */
static const NiFpga_Status NiFpga_Status_IrqTimeout = -61060;

/**
 * The specified bitfile is invalid or corrupt.
 */
static const NiFpga_Status NiFpga_Status_CorruptBitfile = -61070;

/**
 * The FPGA is busy. Ensure no other application has an open FPGA session. For
 * CompactRIO targets, ensure that RIO Scan Interface mode is disabled.
 */
static const NiFpga_Status NiFpga_Status_FpgaBusy = -61141;

/**
 * An unexpected internal error occurred.
 */
static const NiFpga_Status NiFpga_Status_InternalError = -61499;

/**
 * Access to the remote system was denied. Use MAX to check the Remote Device
 * Access settings under Software>>NI-RIO>>NI-RIO Settings on the remote system.
 */
static const NiFpga_Status NiFpga_Status_AccessDenied = -63033;

/**
 * A connection could not be established to the specified remote device. Ensure
 * that the device is on and accessible over the network, that NI-RIO software
 * is installed, and that the RIO server is running and properly configured.
 */
static const NiFpga_Status NiFpga_Status_RpcConnectionError = -63040;

/**
 * The RPC session is invalid. The target may have reset or been rebooted. Check
 * the network connection and retry the operation.
 */
static const NiFpga_Status NiFpga_Status_RpcSessionError = -63043;

/**
 * The bitfile could not be read.
 */
static const NiFpga_Status NiFpga_Status_BitfileReadError = -63101;

/**
 * The specified signature does not match the signature of the bitfile. If the
 * bitfile has been recompiled, regenerate the C API and rebuild the
 * application.
 */
static const NiFpga_Status NiFpga_Status_SignatureMismatch = -63106;

/**
 * Either the supplied resource name is invalid as a RIO resource name, or the
 * device was not found. Use MAX to find the proper resource name for the
 * intended device.
 */
static const NiFpga_Status NiFpga_Status_InvalidResourceName = -63192;

/**
 * The requested feature is not supported.
 */
static const NiFpga_Status NiFpga_Status_FeatureNotSupported = -63193;

/**
 * The NI-RIO software on the remote system is not compatible with the local
 * NI-RIO software. Upgrade the NI-RIO software on the remote system.
 */
static const NiFpga_Status NiFpga_Status_VersionMismatch = -63194;

/**
 * The session is invalid or has been closed.
 */
static const NiFpga_Status NiFpga_Status_InvalidSession = -63195;

/**
 * The maximum number of open FPGA sessions has been reached. Close some open
 * sessions.
 */
static const NiFpga_Status NiFpga_Status_OutOfHandles = -63198;

/**
 * Tests whether a status is an error.
 *
 * @param status status to check for an error
 * @return whether the status was an error
 */
static NiFpga_Inline NiFpga_Bool NiFpga_IsError(const NiFpga_Status status)
{
   return status < NiFpga_Status_Success;
}

/**
 * Tests whether a status is not an error. Success and warnings are not errors.
 *
 * @param status status to check for an error
 * @return whether the status was a success or warning
 */
static NiFpga_Inline NiFpga_Bool NiFpga_IsNotError(const NiFpga_Status status)
{
   return status >= NiFpga_Status_Success;
}

/**
 * Conditionally sets the status to a new value. The previous status is
 * preserved unless the new status is more of an error, which means that
 * warnings and errors overwrite successes, and errors overwrite warnings. New
 * errors do not overwrite older errors, and new warnings do not overwrite
 * older warnings.
 *
 * @param status status to conditionally set
 * @param newStatus new status value that may be set
 * @return the resulting status
 */
static NiFpga_Inline NiFpga_Status NiFpga_MergeStatus(
                                                NiFpga_Status* const status,
                                                const NiFpga_Status  newStatus)
{
   if (!status)
   {
      return NiFpga_Status_InvalidParameter;
   }
   if (NiFpga_IsNotError(*status)
   &&  (*status == NiFpga_Status_Success || NiFpga_IsError(newStatus)))
   {
      *status = newStatus;
   }
   return *status;
}

/**
 * This macro evaluates the expression only if the status is not an error. The
 * expression must evaluate to an NiFpga_Status, such as a call to any NiFpga_*
 * function, because the status will be set to the returned status if the
 * expression is evaluated.
 *
 * You can use this macro to mimic status chaining in LabVIEW, where the status
 * does not have to be explicitly checked after each call. Such code may look
 * like the following example.
 *
 *    NiFpga_Status status = NiFpga_Status_Success;
 *    NiFpga_IfIsNotError(status, NiFpga_WriteU32(...));
 *    NiFpga_IfIsNotError(status, NiFpga_WriteU32(...));
 *    NiFpga_IfIsNotError(status, NiFpga_WriteU32(...));
 *
 * @param status status to check for an error
 * @param expression expression to call if the incoming status is not an error
 */
#define NiFpga_IfIsNotError(status, expression) \
   if (NiFpga_IsNotError(status)) \
   { \
      NiFpga_MergeStatus(&status, (expression)); \
   }

/**
 * A handle to an FPGA session.
 */
typedef uint32_t NiFpga_Session;

/**
 * Attributes that NiFpga_Open accepts.
 */
typedef enum
{
   NiFpga_OpenAttribute_NoRun = 1
} NiFpga_OpenAttribute;

/**
 * Opens a session to the FPGA. This call ensures that the contents of the
 * bitfile are programmed to the FPGA. The FPGA runs unless the
 * NiFpga_OpenAttribute_NoRun attribute is used.
 *
 * Because different operating systems have different default current working
 * directories for applications, you must pass an absolute path for the bitfile
 * parameter. If you pass only the filename instead of an absolute path, the
 * operating system may not be able to locate the bitfile. For example, the
 * default current working directories are C:\ni-rt\system\ for Phar Lap ETS and
 * /c/ for VxWorks. Because the generated *_Bitfile constant is a #define to a
 * string literal, you can use C/C++ string-literal concatenation to form an
 * absolute path. For example, if the bitfile is in the root directory of a
 * Phar Lap ETS system, pass the following for the bitfile parameter.
 *
 *    "C:\\" NiFpga_MyApplication_Bitfile
 *
 * @param bitfile path to the bitfile
 * @param signature signature of the bitfile
 * @param resource RIO resource string to open ("RIO0" or "rio://mysystem/RIO")
 * @param attribute bitwise OR of any NiFpga_OpenAttributes, or 0
 * @param session outputs the session handle, which must be closed when no
 *                longer needed
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_open)(
                          const char*     path,
                          const char*     signature,
                          const char*     resource,
                          uint32_t        attribute,
                          NiFpga_Session* session) = NULL;

NiFpga_Status NiFpga_Open(const char*     path,
                          const char*     signature,
                          const char*     resource,
                          uint32_t        attribute,
                          NiFpga_Session* session)
{
   return NiFpga_open
        ? NiFpga_open(path, signature, resource, attribute, session)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Attributes that NiFpga_Close accepts.
 */
typedef enum
{
   NiFpga_CloseAttribute_NoResetIfLastSession = 1
} NiFpga_CloseAttribute;

/**
 * Closes the session to the FPGA. The FPGA resets unless either another session
 * is still open or you use the NiFpga_CloseAttribute_NoResetIfLastSession
 * attribute.
 *
 * @param session handle to a currently open session
 * @param attribute bitwise OR of any NiFpga_CloseAttributes, or 0
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_close)(
                           NiFpga_Session session,
                           uint32_t       attribute) = NULL;

NiFpga_Status NiFpga_Close(NiFpga_Session session,
                           uint32_t       attribute)
{
   return NiFpga_close
        ? NiFpga_close(session, attribute)
        : NiFpga_Status_ResourceNotInitialized;
}


/**
 * Attributes that NiFpga_Run accepts.
 */
typedef enum
{
   NiFpga_RunAttribute_WaitUntilDone = 1
} NiFpga_RunAttribute;

/**
 * Runs the FPGA VI on the target. If you use NiFpga_RunAttribute_WaitUntilDone,
 * NiFpga_Run blocks the thread until the FPGA finishes running (if ever).
 *
 * @param session handle to a currently open session
 * @param attribute bitwise OR of any NiFpga_RunAttributes, or 0
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_run)(
                         NiFpga_Session session,
                         uint32_t       attribute) = NULL;

NiFpga_Status NiFpga_Run(NiFpga_Session session,
                         uint32_t       attribute)
{
   return NiFpga_run
        ? NiFpga_run(session, attribute)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Aborts the FPGA VI.
 *
 * @param session handle to a currently open session
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_abort)(
                           NiFpga_Session session) = NULL;

NiFpga_Status NiFpga_Abort(NiFpga_Session session)
{
   return NiFpga_abort
        ? NiFpga_abort(session)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Resets the FPGA VI.
 *
 * @param session handle to a currently open session
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_reset)(
                           NiFpga_Session session) = NULL;

NiFpga_Status NiFpga_Reset(NiFpga_Session session)
{
   return NiFpga_reset
        ? NiFpga_reset(session)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Re-downloads the FPGA bitstream to the target.
 *
 * @param session handle to a currently open session
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_download)(
                              NiFpga_Session session) = NULL;

NiFpga_Status NiFpga_Download(NiFpga_Session session)
{
   return NiFpga_download
        ? NiFpga_download(session)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads a boolean value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readBool)(
                              NiFpga_Session session,
                              uint32_t       indicator,
                              NiFpga_Bool*   value) = NULL;

NiFpga_Status NiFpga_ReadBool(NiFpga_Session session,
                              uint32_t       indicator,
                              NiFpga_Bool*   value)
{
   return NiFpga_readBool
        ? NiFpga_readBool(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads a signed 8-bit integer value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readI8)(
                            NiFpga_Session session,
                            uint32_t       indicator,
                            int8_t*        value) = NULL;

NiFpga_Status NiFpga_ReadI8(NiFpga_Session session,
                            uint32_t       indicator,
                            int8_t*        value)
{
   return NiFpga_readI8
        ? NiFpga_readI8(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an unsigned 8-bit integer value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readU8)(
                            NiFpga_Session session,
                            uint32_t       indicator,
                            uint8_t*       value) = NULL;

NiFpga_Status NiFpga_ReadU8(NiFpga_Session session,
                            uint32_t       indicator,
                            uint8_t*       value)
{
   return NiFpga_readU8
        ? NiFpga_readU8(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads a signed 16-bit integer value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readI16)(
                             NiFpga_Session session,
                             uint32_t       indicator,
                             int16_t*       value) = NULL;

NiFpga_Status NiFpga_ReadI16(NiFpga_Session session,
                             uint32_t       indicator,
                             int16_t*       value)
{
   return NiFpga_readI16
        ? NiFpga_readI16(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an unsigned 16-bit integer value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readU16)(
                             NiFpga_Session session,
                             uint32_t       indicator,
                             uint16_t*      value) = NULL;

NiFpga_Status NiFpga_ReadU16(NiFpga_Session session,
                             uint32_t       indicator,
                             uint16_t*      value)
{
   return NiFpga_readU16
        ? NiFpga_readU16(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads a signed 32-bit integer value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readI32)(
                             NiFpga_Session session,
                             uint32_t       indicator,
                             int32_t*       value) = NULL;

NiFpga_Status NiFpga_ReadI32(NiFpga_Session session,
                             uint32_t       indicator,
                             int32_t*       value)
{
   return NiFpga_readI32
        ? NiFpga_readI32(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an unsigned 32-bit integer value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readU32)(
                             NiFpga_Session session,
                             uint32_t       indicator,
                             uint32_t*      value) = NULL;

NiFpga_Status NiFpga_ReadU32(NiFpga_Session session,
                             uint32_t       indicator,
                             uint32_t*      value)
{
   return NiFpga_readU32
        ? NiFpga_readU32(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads a signed 64-bit integer value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readI64)(
                             NiFpga_Session session,
                             uint32_t       indicator,
                             int64_t*       value) = NULL;

NiFpga_Status NiFpga_ReadI64(NiFpga_Session session,
                             uint32_t       indicator,
                             int64_t*       value)
{
   return NiFpga_readI64
        ? NiFpga_readI64(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an unsigned 64-bit integer value from a given indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param value outputs the value that was read
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readU64)(
                             NiFpga_Session session,
                             uint32_t       indicator,
                             uint64_t*      value) = NULL;

NiFpga_Status NiFpga_ReadU64(NiFpga_Session session,
                             uint32_t       indicator,
                             uint64_t*      value)
{
   return NiFpga_readU64
        ? NiFpga_readU64(session, indicator, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes a boolean value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeBool)(
                               NiFpga_Session session,
                               uint32_t       control,
                               NiFpga_Bool    value) = NULL;

NiFpga_Status NiFpga_WriteBool(NiFpga_Session session,
                               uint32_t       control,
                               NiFpga_Bool    value)
{
   return NiFpga_writeBool
        ? NiFpga_writeBool(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes a signed 8-bit integer value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeI8)(
                             NiFpga_Session session,
                             uint32_t       control,
                             int8_t         value) = NULL;

NiFpga_Status NiFpga_WriteI8(NiFpga_Session session,
                             uint32_t       control,
                             int8_t         value)
{
   return NiFpga_writeI8
        ? NiFpga_writeI8(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an unsigned 8-bit integer value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeU8)(
                             NiFpga_Session session,
                             uint32_t       control,
                             uint8_t        value) = NULL;

NiFpga_Status NiFpga_WriteU8(NiFpga_Session session,
                             uint32_t       control,
                             uint8_t        value)
{
   return NiFpga_writeU8
        ? NiFpga_writeU8(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes a signed 16-bit integer value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeI16)(
                              NiFpga_Session session,
                              uint32_t       control,
                              int16_t        value) = NULL;

NiFpga_Status NiFpga_WriteI16(NiFpga_Session session,
                              uint32_t       control,
                              int16_t        value)
{
   return NiFpga_writeI16
        ? NiFpga_writeI16(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an unsigned 16-bit integer value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeU16)(
                              NiFpga_Session session,
                              uint32_t       control,
                              uint16_t       value) = NULL;

NiFpga_Status NiFpga_WriteU16(NiFpga_Session session,
                              uint32_t       control,
                              uint16_t       value)
{
   return NiFpga_writeU16
        ? NiFpga_writeU16(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes a signed 32-bit integer value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeI32)(
                              NiFpga_Session session,
                              uint32_t       control,
                              int32_t        value) = NULL;

NiFpga_Status NiFpga_WriteI32(NiFpga_Session session,
                              uint32_t       control,
                              int32_t        value)
{
   return NiFpga_writeI32
        ? NiFpga_writeI32(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an unsigned 32-bit integer value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeU32)(
                              NiFpga_Session session,
                              uint32_t       control,
                              uint32_t       value) = NULL;

NiFpga_Status NiFpga_WriteU32(NiFpga_Session session,
                              uint32_t       control,
                              uint32_t       value)
{
   return NiFpga_writeU32
        ? NiFpga_writeU32(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes a signed 64-bit integer value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeI64)(
                              NiFpga_Session session,
                              uint32_t       control,
                              int64_t        value) = NULL;

NiFpga_Status NiFpga_WriteI64(NiFpga_Session session,
                              uint32_t       control,
                              int64_t        value)
{
   return NiFpga_writeI64
        ? NiFpga_writeI64(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an unsigned 64-bit integer value to a given control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param value value to write
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeU64)(
                              NiFpga_Session session,
                              uint32_t       control,
                              uint64_t       value) = NULL;

NiFpga_Status NiFpga_WriteU64(NiFpga_Session session,
                              uint32_t       control,
                              uint64_t       value)
{
   return NiFpga_writeU64
        ? NiFpga_writeU64(session, control, value)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of boolean values from a given array indicator or
 * control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayBool)(
                                   NiFpga_Session session,
                                   uint32_t       indicator,
                                   NiFpga_Bool*   array,
                                   uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayBool(NiFpga_Session session,
                                   uint32_t       indicator,
                                   NiFpga_Bool*   array,
                                   uint32_t       size)
{
   return NiFpga_readArrayBool
        ? NiFpga_readArrayBool(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of signed 8-bit integer values from a given array
 * indicator or control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayI8)(
                                 NiFpga_Session session,
                                 uint32_t       indicator,
                                 int8_t*        array,
                                 uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayI8(NiFpga_Session session,
                                 uint32_t       indicator,
                                 int8_t*        array,
                                 uint32_t       size)
{
   return NiFpga_readArrayI8
        ? NiFpga_readArrayI8(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of unsigned 8-bit integer values from a given array
 * indicator or control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayU8)(
                                 NiFpga_Session session,
                                 uint32_t       indicator,
                                 uint8_t*       array,
                                 uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayU8(NiFpga_Session session,
                                 uint32_t       indicator,
                                 uint8_t*       array,
                                 uint32_t       size)
{
   return NiFpga_readArrayU8
        ? NiFpga_readArrayU8(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of signed 16-bit integer values from a given array
 * indicator or control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayI16)(
                                  NiFpga_Session session,
                                  uint32_t       indicator,
                                  int16_t*       array,
                                  uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayI16(NiFpga_Session session,
                                  uint32_t       indicator,
                                  int16_t*       array,
                                  uint32_t       size)
{
   return NiFpga_readArrayI16
        ? NiFpga_readArrayI16(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of unsigned 16-bit integer values from a given array
 * indicator or control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayU16)(
                                  NiFpga_Session session,
                                  uint32_t       indicator,
                                  uint16_t*      array,
                                  uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayU16(NiFpga_Session session,
                                  uint32_t       indicator,
                                  uint16_t*      array,
                                  uint32_t       size)
{
   return NiFpga_readArrayU16
        ? NiFpga_readArrayU16(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of signed 32-bit integer values from a given array
 * indicator or control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayI32)(
                                  NiFpga_Session session,
                                  uint32_t       indicator,
                                  int32_t*       array,
                                  uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayI32(NiFpga_Session session,
                                  uint32_t       indicator,
                                  int32_t*       array,
                                  uint32_t       size)
{
   return NiFpga_readArrayI32
        ? NiFpga_readArrayI32(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of unsigned 32-bit integer values from a given array
 * indicator or control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayU32)(
                                  NiFpga_Session session,
                                  uint32_t       indicator,
                                  uint32_t*      array,
                                  uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayU32(NiFpga_Session session,
                                  uint32_t       indicator,
                                  uint32_t*      array,
                                  uint32_t       size)
{
   return NiFpga_readArrayU32
        ? NiFpga_readArrayU32(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of signed 64-bit integer values from a given array
 * indicator or control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayI64)(
                                  NiFpga_Session session,
                                  uint32_t       indicator,
                                  int64_t*       array,
                                  uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayI64(NiFpga_Session session,
                                  uint32_t       indicator,
                                  int64_t*       array,
                                  uint32_t       size)
{
   return NiFpga_readArrayI64
        ? NiFpga_readArrayI64(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads an entire array of unsigned 64-bit integer values from a given array
 * indicator or control.
 *
 * @warning The size passed must be the exact number of elements in the
 *          indicator or control.
 *
 * @param session handle to a currently open session
 * @param indicator indicator or control from which to read
 * @param array outputs the entire array that was read
 * @param size exact number of elements in the indicator or control
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readArrayU64)(
                                  NiFpga_Session session,
                                  uint32_t       indicator,
                                  uint64_t*      array,
                                  uint32_t       size) = NULL;

NiFpga_Status NiFpga_ReadArrayU64(NiFpga_Session session,
                                  uint32_t       indicator,
                                  uint64_t*      array,
                                  uint32_t       size)
{
   return NiFpga_readArrayU64
        ? NiFpga_readArrayU64(session, indicator, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an entire array of boolean values to a given array control or
 * indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayBool)(
                                    NiFpga_Session     session,
                                    uint32_t           control,
                                    const NiFpga_Bool* array,
                                    uint32_t           size) = NULL;

NiFpga_Status NiFpga_WriteArrayBool(NiFpga_Session     session,
                                    uint32_t           control,
                                    const NiFpga_Bool* array,
                                    uint32_t           size)
{
   return NiFpga_writeArrayBool
        ? NiFpga_writeArrayBool(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an entire array of signed 8-bit integer values to a given array
 * control or indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayI8)(
                                  NiFpga_Session session,
                                  uint32_t       control,
                                  const int8_t*  array,
                                  uint32_t       size) = NULL;

NiFpga_Status NiFpga_WriteArrayI8(NiFpga_Session session,
                                  uint32_t       control,
                                  const int8_t*  array,
                                  uint32_t       size)
{
   return NiFpga_writeArrayI8
        ? NiFpga_writeArrayI8(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}


/**
 * Writes an entire array of unsigned 8-bit integer values to a given array
 * control or indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayU8)(
                                  NiFpga_Session session,
                                  uint32_t       control,
                                  const uint8_t* array,
                                  uint32_t       size) = NULL;

NiFpga_Status NiFpga_WriteArrayU8(NiFpga_Session session,
                                  uint32_t       control,
                                  const uint8_t* array,
                                  uint32_t       size)
{
   return NiFpga_writeArrayU8
        ? NiFpga_writeArrayU8(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an entire array of signed 16-bit integer values to a given array
 * control or indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayI16)(
                                   NiFpga_Session session,
                                   uint32_t       control,
                                   const int16_t* array,
                                   uint32_t       size) = NULL;

NiFpga_Status NiFpga_WriteArrayI16(NiFpga_Session session,
                                   uint32_t       control,
                                   const int16_t* array,
                                   uint32_t       size)
{
   return NiFpga_writeArrayI16
        ? NiFpga_writeArrayI16(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an entire array of unsigned 16-bit integer values to a given array
 * control or indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayU16)(
                                   NiFpga_Session  session,
                                   uint32_t        control,
                                   const uint16_t* array,
                                   uint32_t        size) = NULL;

NiFpga_Status NiFpga_WriteArrayU16(NiFpga_Session  session,
                                   uint32_t        control,
                                   const uint16_t* array,
                                   uint32_t        size)
{
   return NiFpga_writeArrayU16
        ? NiFpga_writeArrayU16(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an entire array of signed 32-bit integer values to a given array
 * control or indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayI32)(
                                   NiFpga_Session session,
                                   uint32_t       control,
                                   const int32_t* array,
                                   uint32_t       size) = NULL;

NiFpga_Status NiFpga_WriteArrayI32(NiFpga_Session session,
                                   uint32_t       control,
                                   const int32_t* array,
                                   uint32_t       size)
{
   return NiFpga_writeArrayI32
        ? NiFpga_writeArrayI32(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an entire array of unsigned 32-bit integer values to a given array
 * control or indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayU32)(
                                   NiFpga_Session  session,
                                   uint32_t        control,
                                   const uint32_t* array,
                                   uint32_t        size) = NULL;

NiFpga_Status NiFpga_WriteArrayU32(NiFpga_Session  session,
                                   uint32_t        control,
                                   const uint32_t* array,
                                   uint32_t        size)
{
   return NiFpga_writeArrayU32
        ? NiFpga_writeArrayU32(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an entire array of signed 64-bit integer values to a given array
 * control or indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayI64)(
                                   NiFpga_Session session,
                                   uint32_t       control,
                                   const int64_t* array,
                                   uint32_t       size) = NULL;

NiFpga_Status NiFpga_WriteArrayI64(NiFpga_Session session,
                                   uint32_t       control,
                                   const int64_t* array,
                                   uint32_t       size)
{
   return NiFpga_writeArrayI64
        ? NiFpga_writeArrayI64(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes an entire array of unsigned 64-bit integer values to a given array
 * control or indicator.
 *
 * @warning The size passed must be the exact number of elements in the
 *          control or indicator.
 *
 * @param session handle to a currently open session
 * @param control control or indicator to which to write
 * @param array the entire array to write
 * @param size exact number of elements in the control or indicator
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeArrayU64)(
                                   NiFpga_Session  session,
                                   uint32_t        control,
                                   const uint64_t* array,
                                   uint32_t        size) = NULL;

NiFpga_Status NiFpga_WriteArrayU64(NiFpga_Session  session,
                                   uint32_t        control,
                                   const uint64_t* array,
                                   uint32_t        size)
{
   return NiFpga_writeArrayU64
        ? NiFpga_writeArrayU64(session, control, array, size)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Enumeration of all 32 possible IRQs. Multiple IRQs can be bitwise ORed
 * together like this:
 *
 *    NiFpga_Irq_3 | NiFpga_Irq_23
 */
typedef enum
{
   NiFpga_Irq_0  = 1 << 0,
   NiFpga_Irq_1  = 1 << 1,
   NiFpga_Irq_2  = 1 << 2,
   NiFpga_Irq_3  = 1 << 3,
   NiFpga_Irq_4  = 1 << 4,
   NiFpga_Irq_5  = 1 << 5,
   NiFpga_Irq_6  = 1 << 6,
   NiFpga_Irq_7  = 1 << 7,
   NiFpga_Irq_8  = 1 << 8,
   NiFpga_Irq_9  = 1 << 9,
   NiFpga_Irq_10 = 1 << 10,
   NiFpga_Irq_11 = 1 << 11,
   NiFpga_Irq_12 = 1 << 12,
   NiFpga_Irq_13 = 1 << 13,
   NiFpga_Irq_14 = 1 << 14,
   NiFpga_Irq_15 = 1 << 15,
   NiFpga_Irq_16 = 1 << 16,
   NiFpga_Irq_17 = 1 << 17,
   NiFpga_Irq_18 = 1 << 18,
   NiFpga_Irq_19 = 1 << 19,
   NiFpga_Irq_20 = 1 << 20,
   NiFpga_Irq_21 = 1 << 21,
   NiFpga_Irq_22 = 1 << 22,
   NiFpga_Irq_23 = 1 << 23,
   NiFpga_Irq_24 = 1 << 24,
   NiFpga_Irq_25 = 1 << 25,
   NiFpga_Irq_26 = 1 << 26,
   NiFpga_Irq_27 = 1 << 27,
   NiFpga_Irq_28 = 1 << 28,
   NiFpga_Irq_29 = 1 << 29,
   NiFpga_Irq_30 = 1 << 30,
   NiFpga_Irq_31 = 1 << 31
} NiFpga_Irq;

/**
 * Represents an infinite timeout.
 */
static const uint32_t NiFpga_InfiniteTimeout = 0xFFFFFFFF;

/**
 * See NiFpga_ReserveIrqContext for more information.
 */
typedef void* NiFpga_IrqContext;

/**
 * IRQ contexts are single-threaded; only one thread can wait with a particular
 * context at any given time. Clients must reserve as many contexts as the
 * application requires.
 *
 * If a context is successfully reserved (the returned status is not an error),
 * it must be unreserved later. Otherwise a memory leak will occur.
 *
 * @param session handle to a currently open session
 * @param context outputs the IRQ context
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_reserveIrqContext)(
                                       NiFpga_Session     session,
                                       NiFpga_IrqContext* context) = NULL;


NiFpga_Status NiFpga_ReserveIrqContext(NiFpga_Session     session,
                                       NiFpga_IrqContext* context)
{
   return NiFpga_reserveIrqContext
        ? NiFpga_reserveIrqContext(session, context)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Unreserves an IRQ context obtained from NiFpga_ReserveIrqContext.
 *
 * @param session handle to a currently open session
 * @param context IRQ context to unreserve
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_unreserveIrqContext)(
                                         NiFpga_Session    session,
                                         NiFpga_IrqContext context) = NULL;


NiFpga_Status NiFpga_UnreserveIrqContext(NiFpga_Session    session,
                                         NiFpga_IrqContext context)
{
   return NiFpga_unreserveIrqContext
        ? NiFpga_unreserveIrqContext(session, context)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * This is a blocking function that stops the calling thread until the FPGA
 * asserts any IRQ in the irqs parameter, or until the function call times out.
 * Before calling this function, you must use NiFpga_ReserveIrqContext to
 * reserve an IRQ context. No other threads can use the same context when this
 * function is called.
 *
 * You can use the irqsAsserted parameter to determine which IRQs were asserted
 * for each function call.
 *
 * @param session handle to a currently open session
 * @param context IRQ context with which to wait
 * @param irqs bitwise OR of NiFpga_Irqs
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param irqsAsserted if non-NULL, outputs bitwise OR of IRQs that were
 *                     asserted
 * @param timedOut if non-NULL, outputs whether the timeout expired
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_waitOnIrqs)(
                                NiFpga_Session    session,
                                NiFpga_IrqContext context,
                                uint32_t          irqs,
                                uint32_t          timeout,
                                uint32_t*         irqsAsserted,
                                NiFpga_Bool*      timedOut) = NULL;

NiFpga_Status NiFpga_WaitOnIrqs(NiFpga_Session    session,
                                NiFpga_IrqContext context,
                                uint32_t          irqs,
                                uint32_t          timeout,
                                uint32_t*         irqsAsserted,
                                NiFpga_Bool*      timedOut)
{
   return NiFpga_waitOnIrqs
        ? NiFpga_waitOnIrqs(session,
                            context,
                            irqs,
                            timeout,
                            irqsAsserted,
                            timedOut)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Acknowledges an IRQ or set of IRQs.
 *
 * @param session handle to a currently open session
 * @param irqs bitwise OR of NiFpga_Irqs
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_acknowledgeIrqs)(
                                     NiFpga_Session session,
                                     uint32_t       irqs) = NULL;

NiFpga_Status NiFpga_AcknowledgeIrqs(NiFpga_Session session,
                                     uint32_t       irqs)
{
   return NiFpga_acknowledgeIrqs
        ? NiFpga_acknowledgeIrqs(session, irqs)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Specifies the depth of the host memory part of the DMA FIFO. This method is
 * optional.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to configure
 * @param depth the number of elements in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_configureFifo)(
                                   NiFpga_Session session,
                                   uint32_t       fifo,
                                   uint32_t       depth) = NULL;

NiFpga_Status NiFpga_ConfigureFifo(NiFpga_Session session,
                                   uint32_t       fifo,
                                   uint32_t       depth)
{
   return NiFpga_configureFifo
        ? NiFpga_configureFifo(session, fifo, depth)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Starts a FIFO.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to start
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_startFifo)(
                               NiFpga_Session session,
                               uint32_t       fifo) = NULL;

NiFpga_Status NiFpga_StartFifo(NiFpga_Session session,
                               uint32_t       fifo)
{
   return NiFpga_startFifo
        ? NiFpga_startFifo(session, fifo)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Stops a FIFO.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to stop
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_stopFifo)(
                              NiFpga_Session session,
                              uint32_t       fifo) = NULL;

NiFpga_Status NiFpga_StopFifo(NiFpga_Session session,
                              uint32_t       fifo)
{
   return NiFpga_stopFifo
        ? NiFpga_stopFifo(session, fifo)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of booleans.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoBool)(
                                  NiFpga_Session session,
                                  uint32_t       fifo,
                                  NiFpga_Bool*   data,
                                  uint32_t       numberOfElements,
                                  uint32_t       timeout,
                                  uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoBool(NiFpga_Session session,
                                  uint32_t       fifo,
                                  NiFpga_Bool*   data,
                                  uint32_t       numberOfElements,
                                  uint32_t       timeout,
                                  uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoBool
        ? NiFpga_readFifoBool(session,
                              fifo,
                              data,
                              numberOfElements,
                              timeout,
                              elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of signed 8-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoI8)(
                                NiFpga_Session session,
                                uint32_t       fifo,
                                int8_t*        data,
                                uint32_t       numberOfElements,
                                uint32_t       timeout,
                                uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoI8(NiFpga_Session session,
                                uint32_t       fifo,
                                int8_t*        data,
                                uint32_t       numberOfElements,
                                uint32_t       timeout,
                                uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoI8
        ? NiFpga_readFifoI8(session,
                            fifo,
                            data,
                            numberOfElements,
                            timeout,
                            elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of unsigned 8-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoU8)(
                                NiFpga_Session session,
                                uint32_t       fifo,
                                uint8_t*       data,
                                uint32_t       numberOfElements,
                                uint32_t       timeout,
                                uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoU8(NiFpga_Session session,
                                uint32_t       fifo,
                                uint8_t*       data,
                                uint32_t       numberOfElements,
                                uint32_t       timeout,
                                uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoU8
        ? NiFpga_readFifoU8(session,
                            fifo,
                            data,
                            numberOfElements,
                            timeout,
                            elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of signed 16-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoI16)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 int16_t*       data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoI16(NiFpga_Session session,
                                 uint32_t       fifo,
                                 int16_t*       data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoI16
        ? NiFpga_readFifoI16(session,
                             fifo,
                             data,
                             numberOfElements,
                             timeout,
                             elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of unsigned 16-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoU16)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 uint16_t*      data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoU16(NiFpga_Session session,
                                 uint32_t       fifo,
                                 uint16_t*      data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoU16
        ? NiFpga_readFifoU16(session,
                             fifo,
                             data,
                             numberOfElements,
                             timeout,
                             elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of signed 32-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoI32)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 int32_t*       data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoI32(NiFpga_Session session,
                                 uint32_t       fifo,
                                 int32_t*       data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoI32
        ? NiFpga_readFifoI32(session,
                             fifo,
                             data,
                             numberOfElements,
                             timeout,
                             elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of unsigned 32-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoU32)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 uint32_t*      data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoU32(NiFpga_Session session,
                                 uint32_t       fifo,
                                 uint32_t*      data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoU32
        ? NiFpga_readFifoU32(session,
                             fifo,
                             data,
                             numberOfElements,
                             timeout,
                             elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of signed 64-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoI64)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 int64_t*       data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoI64(NiFpga_Session session,
                                 uint32_t       fifo,
                                 int64_t*       data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoI64
        ? NiFpga_readFifoI64(session,
                             fifo,
                             data,
                             numberOfElements,
                             timeout,
                             elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Reads from a FIFO of unsigned 64-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO from which to read
 * @param data outputs the data that was read
 * @param numberOfElements number of elements to read
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param elementsRemaining if non-NULL, outputs the number of elements
 *                          remaining in the host memory part of the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_readFifoU64)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 uint64_t*      data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining) = NULL;

NiFpga_Status NiFpga_ReadFifoU64(NiFpga_Session session,
                                 uint32_t       fifo,
                                 uint64_t*      data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      elementsRemaining)
{
   return NiFpga_readFifoU64
        ? NiFpga_readFifoU64(session,
                             fifo,
                             data,
                             numberOfElements,
                             timeout,
                             elementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of booleans.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoBool)(
                             NiFpga_Session     session,
                             uint32_t           fifo,
                             const NiFpga_Bool* data,
                             uint32_t           numberOfElements,
                             uint32_t           timeout,
                             uint32_t*          emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoBool(
                             NiFpga_Session     session,
                             uint32_t           fifo,
                             const NiFpga_Bool* data,
                             uint32_t           numberOfElements,
                             uint32_t           timeout,
                             uint32_t*          emptyElementsRemaining)
{
   return NiFpga_writeFifoBool
        ? NiFpga_writeFifoBool(session,
                               fifo,
                               data,
                               numberOfElements,
                               timeout,
                               emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of signed 8-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoI8)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 const int8_t*  data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoI8(NiFpga_Session session,
                                 uint32_t       fifo,
                                 const int8_t*  data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining)
{
   return NiFpga_writeFifoI8
        ? NiFpga_writeFifoI8(session,
                             fifo,
                             data,
                             numberOfElements,
                             timeout,
                             emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of unsigned 8-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoU8)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 const uint8_t* data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoU8(NiFpga_Session session,
                                 uint32_t       fifo,
                                 const uint8_t* data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining)
{
   return NiFpga_writeFifoU8
        ? NiFpga_writeFifoU8(session,
                             fifo,
                             data,
                             numberOfElements,
                             timeout,
                             emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of signed 16-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoI16)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 const int16_t* data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoI16(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 const int16_t* data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining)
{
   return NiFpga_writeFifoI16
        ? NiFpga_writeFifoI16(session,
                              fifo,
                              data,
                              numberOfElements,
                              timeout,
                              emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of unsigned 16-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoU16)(
                                NiFpga_Session  session,
                                uint32_t        fifo,
                                const uint16_t* data,
                                uint32_t        numberOfElements,
                                uint32_t        timeout,
                                uint32_t*       emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoU16(
                                NiFpga_Session  session,
                                uint32_t        fifo,
                                const uint16_t* data,
                                uint32_t        numberOfElements,
                                uint32_t        timeout,
                                uint32_t*       emptyElementsRemaining)
{
   return NiFpga_writeFifoU16
        ? NiFpga_writeFifoU16(session,
                              fifo,
                              data,
                              numberOfElements,
                              timeout,
                              emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of signed 32-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoI32)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 const int32_t* data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoI32(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 const int32_t* data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining)
{
   return NiFpga_writeFifoI32
        ? NiFpga_writeFifoI32(session,
                              fifo,
                              data,
                              numberOfElements,
                              timeout,
                              emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of unsigned 32-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoU32)(
                                NiFpga_Session  session,
                                uint32_t        fifo,
                                const uint32_t* data,
                                uint32_t        numberOfElements,
                                uint32_t        timeout,
                                uint32_t*       emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoU32(
                                NiFpga_Session  session,
                                uint32_t        fifo,
                                const uint32_t* data,
                                uint32_t        numberOfElements,
                                uint32_t        timeout,
                                uint32_t*       emptyElementsRemaining)
{
   return NiFpga_writeFifoU32
        ? NiFpga_writeFifoU32(session,
                              fifo,
                              data,
                              numberOfElements,
                              timeout,
                              emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of signed 64-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoI64)(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 const int64_t* data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoI64(
                                 NiFpga_Session session,
                                 uint32_t       fifo,
                                 const int64_t* data,
                                 uint32_t       numberOfElements,
                                 uint32_t       timeout,
                                 uint32_t*      emptyElementsRemaining)
{
   return NiFpga_writeFifoI64
        ? NiFpga_writeFifoI64(session,
                              fifo,
                              data,
                              numberOfElements,
                              timeout,
                              emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Writes to a FIFO of unsigned 64-bit integers.
 *
 * @param session handle to a currently open session
 * @param fifo the FIFO to which to write
 * @param data data to write
 * @param numberOfElements number of elements to write
 * @param timeout timeout in milliseconds, or NiFpga_InfiniteTimeout
 * @param emptyElementsRemaining if non-NULL, outputs the number of empty
 *                               elements remaining in the host memory part of
 *                               the DMA FIFO
 * @return result of the call
 */
static NiFpga_Status (NiFpga_CCall *NiFpga_writeFifoU64)(
                                NiFpga_Session  session,
                                uint32_t        fifo,
                                const uint64_t* data,
                                uint32_t        numberOfElements,
                                uint32_t        timeout,
                                uint32_t*       emptyElementsRemaining) = NULL;

NiFpga_Status NiFpga_WriteFifoU64(
                                NiFpga_Session  session,
                                uint32_t        fifo,
                                const uint64_t* data,
                                uint32_t        numberOfElements,
                                uint32_t        timeout,
                                uint32_t*       emptyElementsRemaining)
{
   return NiFpga_writeFifoU64
        ? NiFpga_writeFifoU64(session,
                              fifo,
                              data,
                              numberOfElements,
                              timeout,
                              emptyElementsRemaining)
        : NiFpga_Status_ResourceNotInitialized;
}

/**
 * Represents an entry point function.
 */
typedef struct
{
   const char* const name;
   void** const address;
} NiFpga_Function;

/**
 * A NULL-terminated array of all entry point functions.
 */
static const NiFpga_Function NiFpga_functions[] =
{
   {"NiFpgaDll_Open",                (void**)&NiFpga_open},
   {"NiFpgaDll_Close",               (void**)&NiFpga_close},
   {"NiFpgaDll_Run",                 (void**)&NiFpga_run},
   {"NiFpgaDll_Abort",               (void**)&NiFpga_abort},
   {"NiFpgaDll_Reset",               (void**)&NiFpga_reset},
   {"NiFpgaDll_Download",            (void**)&NiFpga_download},
   {"NiFpgaDll_ReadBool",            (void**)&NiFpga_readBool},
   {"NiFpgaDll_ReadI8",              (void**)&NiFpga_readI8},
   {"NiFpgaDll_ReadU8",              (void**)&NiFpga_readU8},
   {"NiFpgaDll_ReadI16",             (void**)&NiFpga_readI16},
   {"NiFpgaDll_ReadU16",             (void**)&NiFpga_readU16},
   {"NiFpgaDll_ReadI32",             (void**)&NiFpga_readI32},
   {"NiFpgaDll_ReadU32",             (void**)&NiFpga_readU32},
   {"NiFpgaDll_ReadI64",             (void**)&NiFpga_readI64},
   {"NiFpgaDll_ReadU64",             (void**)&NiFpga_readU64},
   {"NiFpgaDll_WriteBool",           (void**)&NiFpga_writeBool},
   {"NiFpgaDll_WriteI8",             (void**)&NiFpga_writeI8},
   {"NiFpgaDll_WriteU8",             (void**)&NiFpga_writeU8},
   {"NiFpgaDll_WriteI16",            (void**)&NiFpga_writeI16},
   {"NiFpgaDll_WriteU16",            (void**)&NiFpga_writeU16},
   {"NiFpgaDll_WriteI32",            (void**)&NiFpga_writeI32},
   {"NiFpgaDll_WriteU32",            (void**)&NiFpga_writeU32},
   {"NiFpgaDll_WriteI64",            (void**)&NiFpga_writeI64},
   {"NiFpgaDll_WriteU64",            (void**)&NiFpga_writeU64},
   {"NiFpgaDll_ReadArrayBool",       (void**)&NiFpga_readArrayBool},
   {"NiFpgaDll_ReadArrayI8",         (void**)&NiFpga_readArrayI8},
   {"NiFpgaDll_ReadArrayU8",         (void**)&NiFpga_readArrayU8},
   {"NiFpgaDll_ReadArrayI16",        (void**)&NiFpga_readArrayI16},
   {"NiFpgaDll_ReadArrayU16",        (void**)&NiFpga_readArrayU16},
   {"NiFpgaDll_ReadArrayI32",        (void**)&NiFpga_readArrayI32},
   {"NiFpgaDll_ReadArrayU32",        (void**)&NiFpga_readArrayU32},
   {"NiFpgaDll_ReadArrayI64",        (void**)&NiFpga_readArrayI64},
   {"NiFpgaDll_ReadArrayU64",        (void**)&NiFpga_readArrayU64},
   {"NiFpgaDll_WriteArrayBool",      (void**)&NiFpga_writeArrayBool},
   {"NiFpgaDll_WriteArrayI8",        (void**)&NiFpga_writeArrayI8},
   {"NiFpgaDll_WriteArrayU8",        (void**)&NiFpga_writeArrayU8},
   {"NiFpgaDll_WriteArrayI16",       (void**)&NiFpga_writeArrayI16},
   {"NiFpgaDll_WriteArrayU16",       (void**)&NiFpga_writeArrayU16},
   {"NiFpgaDll_WriteArrayI32",       (void**)&NiFpga_writeArrayI32},
   {"NiFpgaDll_WriteArrayU32",       (void**)&NiFpga_writeArrayU32},
   {"NiFpgaDll_WriteArrayI64",       (void**)&NiFpga_writeArrayI64},
   {"NiFpgaDll_WriteArrayU64",       (void**)&NiFpga_writeArrayU64},
   {"NiFpgaDll_ReserveIrqContext",   (void**)&NiFpga_reserveIrqContext},
   {"NiFpgaDll_UnreserveIrqContext", (void**)&NiFpga_unreserveIrqContext},
   {"NiFpgaDll_WaitOnIrqs",          (void**)&NiFpga_waitOnIrqs},
   {"NiFpgaDll_AcknowledgeIrqs",     (void**)&NiFpga_acknowledgeIrqs},
   {"NiFpgaDll_ConfigureFifo",       (void**)&NiFpga_configureFifo},
   {"NiFpgaDll_StartFifo",           (void**)&NiFpga_startFifo},
   {"NiFpgaDll_StopFifo",            (void**)&NiFpga_stopFifo},
   {"NiFpgaDll_ReadFifoBool",        (void**)&NiFpga_readFifoBool},
   {"NiFpgaDll_ReadFifoI8",          (void**)&NiFpga_readFifoI8},
   {"NiFpgaDll_ReadFifoU8",          (void**)&NiFpga_readFifoU8},
   {"NiFpgaDll_ReadFifoI16",         (void**)&NiFpga_readFifoI16},
   {"NiFpgaDll_ReadFifoU16",         (void**)&NiFpga_readFifoU16},
   {"NiFpgaDll_ReadFifoI32",         (void**)&NiFpga_readFifoI32},
   {"NiFpgaDll_ReadFifoU32",         (void**)&NiFpga_readFifoU32},
   {"NiFpgaDll_ReadFifoI64",         (void**)&NiFpga_readFifoI64},
   {"NiFpgaDll_ReadFifoU64",         (void**)&NiFpga_readFifoU64},
   {"NiFpgaDll_WriteFifoBool",       (void**)&NiFpga_writeFifoBool},
   {"NiFpgaDll_WriteFifoI8",         (void**)&NiFpga_writeFifoI8},
   {"NiFpgaDll_WriteFifoU8",         (void**)&NiFpga_writeFifoU8},
   {"NiFpgaDll_WriteFifoI16",        (void**)&NiFpga_writeFifoI16},
   {"NiFpgaDll_WriteFifoU16",        (void**)&NiFpga_writeFifoU16},
   {"NiFpgaDll_WriteFifoI32",        (void**)&NiFpga_writeFifoI32},
   {"NiFpgaDll_WriteFifoU32",        (void**)&NiFpga_writeFifoU32},
   {"NiFpgaDll_WriteFifoI64",        (void**)&NiFpga_writeFifoI64},
   {"NiFpgaDll_WriteFifoU64",        (void**)&NiFpga_writeFifoU64},
   {NULL, NULL}
};

/**
 * You must call this function before all other function calls. This function
 * loads the NiFpga library so that all the other functions will work. If this
 * function succeeds, you must call NiFpga_Finalize after all other function
 * calls.
 *
 * @warning This function is not thread safe.
 *
 * @return result of the call
 */
NiFpga_Status NiFpga_Initialize(void)
{
   /* if the library isn't already loaded */
	 
	if (!NiFpga_library)
   {
      int i;
      /* load the library */    
      #if NiFpga_Windows
         NiFpga_library = LoadLibraryA("NiFpga.dll");
      #elif NiFpga_VxWorks
         NiFpga_library = VxLoadLibraryFromPath("NiFpga.out", 0);
      #else
         #error
      #endif
      if (!NiFpga_library)
      {
         return NiFpga_Status_ResourceNotFound;
      }
      /* get each exported function */	
      for (i = 0; NiFpga_functions[i].name; i++)
      {
         const char* const name = NiFpga_functions[i].name;
         void** const address = NiFpga_functions[i].address;
         #if NiFpga_Windows
            *address = GetProcAddress(NiFpga_library, name);
            if (!*address)
            {
               return NiFpga_Status_ResourceNotFound;
            }
         #elif NiFpga_VxWorks
            SYM_TYPE type;
            if (symFindByName(sysSymTbl,
                              (char*)name,
                              (char**)address,
                              &type) != OK)
            {
               return NiFpga_Status_ResourceNotFound;
            }
         #else
            #error
         #endif
      }	   
   }	  
   return NiFpga_Status_Success;
}

/**
 * You must call this function after all other function calls if
 * NiFpga_Initialize succeeds. This function unloads the NiFpga library.
 *
 * @warning This function is not thread safe.
 *
 * @return result of the call
 */
NiFpga_Status NiFpga_Finalize(void)
{
   /* if the library is currently loaded */
   if (NiFpga_library)
   {
      int i;
      NiFpga_Status status = NiFpga_Status_Success;
      /* unload the library */
      #if NiFpga_Windows
         if (!FreeLibrary(NiFpga_library))
         {
            status = NiFpga_Status_ResourceNotInitialized;
         }
      #elif NiFpga_VxWorks
         if (VxFreeLibrary(NiFpga_library, 0) != OK)
         {
            status = NiFpga_Status_ResourceNotInitialized;
         }
      #else
         #error
      #endif
      /* null out the library and each exported function */
      NiFpga_library = NULL;
      for (i = 0; NiFpga_functions[i].name; i++)
      {
         *NiFpga_functions[i].address = NULL;
      }
      return status;
   }
   else {
      return NiFpga_Status_ResourceNotInitialized;
   }
}

#if NiFpga_Cpp
}
#endif

#endif
