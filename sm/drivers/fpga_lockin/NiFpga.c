/*
 * FPGA Interface C API 1.0 source file.
 *
 * Copyright (c) 2009,
 * National Instruments Corporation.
 * All rights reserved.
 */

#include "NiFpga.h"

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

/*
 * Session management functions.
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

/*
 * FPGA state functions.
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

static NiFpga_Status (NiFpga_CCall *NiFpga_abort)(
                           NiFpga_Session session) = NULL;

NiFpga_Status NiFpga_Abort(NiFpga_Session session)
{
   return NiFpga_abort
        ? NiFpga_abort(session)
        : NiFpga_Status_ResourceNotInitialized;
}

static NiFpga_Status (NiFpga_CCall *NiFpga_reset)(
                           NiFpga_Session session) = NULL;

NiFpga_Status NiFpga_Reset(NiFpga_Session session)
{
   return NiFpga_reset
        ? NiFpga_reset(session)
        : NiFpga_Status_ResourceNotInitialized;
}

static NiFpga_Status (NiFpga_CCall *NiFpga_download)(
                              NiFpga_Session session) = NULL;

NiFpga_Status NiFpga_Download(NiFpga_Session session)
{
   return NiFpga_download
        ? NiFpga_download(session)
        : NiFpga_Status_ResourceNotInitialized;
}

/*
 * Functions to read from scalar indicators and controls.
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

/*
 * Functions to write to scalar controls and indicators.
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

/*
 * Functions to read from array indicators and controls.
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

/*
 * Functions to write to array controls and indicators.
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

/*
 * Interrupt functions.
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

/*
 * DMA FIFO state functions.
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

/*
 * Functions to read from target-to-host DMA FIFOs.
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

/*
 * Functions to write to host-to-target DMA FIFOs.
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
