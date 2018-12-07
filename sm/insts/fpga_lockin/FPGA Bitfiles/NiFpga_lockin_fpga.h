/*
 * Generated with the FPGA Interface C API Generator 1.0.
 */

#ifndef __NiFpga_lockin_fpga_h__
#define __NiFpga_lockin_fpga_h__

#ifndef NiFpga_Version
   #define NiFpga_Version 100
#endif

#include "NiFpga.h"

/**
 * The filename of the FPGA bitfile.
 *
 * This is a #define to allow for string literal concatenation. For example:
 *
 *    static const char* const Bitfile = "C:\\" NiFpga_lockin_fpga_Bitfile;
 */
#define NiFpga_lockin_fpga_Bitfile "NiFpga_lockin_fpga.lvbitx"

/**
 * The signature of the FPGA bitfile.
 */
static const char* const NiFpga_lockin_fpga_Signature = "07EE95E7C4E1708BBCE54EE6179EE7CD";

typedef enum
{
   NiFpga_lockin_fpga_IndicatorI32_X_fpga1 = 0x812C,
   NiFpga_lockin_fpga_IndicatorI32_X_fpga2 = 0x8128,
   NiFpga_lockin_fpga_IndicatorI32_X_fpga3 = 0x8124,
   NiFpga_lockin_fpga_IndicatorI32_X_fpga4 = 0x8120,
   NiFpga_lockin_fpga_IndicatorI32_Y_fpga1 = 0x811C,
   NiFpga_lockin_fpga_IndicatorI32_Y_fpga2 = 0x8118,
   NiFpga_lockin_fpga_IndicatorI32_Y_fpga3 = 0x8114,
   NiFpga_lockin_fpga_IndicatorI32_Y_fpga4 = 0x8110,
} NiFpga_lockin_fpga_IndicatorI32;

typedef enum
{
   NiFpga_lockin_fpga_IndicatorU32_ActualGenRateticks = 0x8174,
} NiFpga_lockin_fpga_IndicatorU32;

typedef enum
{
   NiFpga_lockin_fpga_ControlBool_stop = 0x816E,
} NiFpga_lockin_fpga_ControlBool;

typedef enum
{
   NiFpga_lockin_fpga_ControlU16_SignalAmplitude1 = 0x814E,
   NiFpga_lockin_fpga_ControlU16_SignalAmplitude2 = 0x814A,
   NiFpga_lockin_fpga_ControlU16_SignalAmplitude3 = 0x8146,
   NiFpga_lockin_fpga_ControlU16_SignalAmplitude4 = 0x8142,
} NiFpga_lockin_fpga_ControlU16;

typedef enum
{
   NiFpga_lockin_fpga_ControlI32_beta1 = 0x813C,
   NiFpga_lockin_fpga_ControlI32_beta2 = 0x8138,
   NiFpga_lockin_fpga_ControlI32_beta3 = 0x8134,
   NiFpga_lockin_fpga_ControlI32_beta4 = 0x8130,
} NiFpga_lockin_fpga_ControlI32;

typedef enum
{
   NiFpga_lockin_fpga_ControlU32_AccumulatorIncrement1 = 0x810C,
   NiFpga_lockin_fpga_ControlU32_AccumulatorIncrement2 = 0x8168,
   NiFpga_lockin_fpga_ControlU32_AccumulatorIncrement3 = 0x8164,
   NiFpga_lockin_fpga_ControlU32_AccumulatorIncrement4 = 0x8160,
   NiFpga_lockin_fpga_ControlU32_PhaseShift1 = 0x815C,
   NiFpga_lockin_fpga_ControlU32_PhaseShift2 = 0x8158,
   NiFpga_lockin_fpga_ControlU32_PhaseShift3 = 0x8154,
   NiFpga_lockin_fpga_ControlU32_PhaseShift4 = 0x8150,
   NiFpga_lockin_fpga_ControlU32_UpdateRateticks = 0x8170,
} NiFpga_lockin_fpga_ControlU32;

#endif
