@ECHO OFF
SETLOCAL ENABLEEXTENSIONS
SET /A errno=0

set builder=ninja
set section=all
set cmake_build_type=Release

:args_loop
IF [%1] == [] GOTO continue_after_args
REM echo aaa %1 

IF [%1] == [-b] (
  set builder=%2
  SHIFT
)
IF [%1] == [-s] (
  set section=%2
  SHIFT
)
IF [%1] == [-t] (
  set cmake_build_type=%2
  SHIFT
)
SHIFT
GOTO args_loop

:continue_after_args

echo ##### BUILD PARAMS #####
echo builder : %builder%
echo section : %section%
echo cmake_build_type : %cmake_build_type%
echo ########################

set source_dir=%CD%
set build_dir=build\%builder%

:mkdir_base
mkdir %build_dir%
pushd %build_dir%
IF %ERRORLEVEL% NEQ 0 GOTO end

REM If doing just a part of this batch goto it directly
GOTO %section%

:all

:gen
ECHO ***** GENERATE CMAKE *****
IF "%builder%"=="nmake" cmake -G "NMake Makefiles" -DTOOLCHAIN_DIR=C:/NXP/S32DS.3.5/S32DS/build_tools/gcc_v10.2/gcc-10.2-arm32-eabi -DCMAKE_TOOLCHAIN_FILE=%source_dir%/cmake/r2_cortex_m7.cmake %source_dir%
IF "%builder%"=="mingw" cmake -G "MinGW Makefiles" -DTOOLCHAIN_DIR=C:/NXP/S32DS.3.5/S32DS/build_tools/gcc_v10.2/gcc-10.2-arm32-eabi -DCMAKE_TOOLCHAIN_FILE=%source_dir%/cmake/r2_cortex_m7.cmake -DCMAKE_MAKE_PROGRAM=C:/Users/cmercier/Downloads/w64devkit-1.23.0/w64devkit/bin/make.exe %source_dir%
IF "%builder%"=="ninja" cmake -G Ninja -DTOOLCHAIN_DIR=C:/NXP/S32DS.3.5/S32DS/build_tools/gcc_v10.2/gcc-10.2-arm32-eabi -DCMAKE_TOOLCHAIN_FILE=%source_dir%/cmake/r2_cortex_m7.cmake %source_dir%
IF NOT "%section%"=="all" GOTO end_pop  REM end if partial


:build
ECHO "***** BUILD WITH CMAKE *****"
cmake --build . 
IF %ERRORLEVEL% NEQ 0 GOTO end_pop
IF NOT "%section%"=="all" GOTO end_pop  REM end if partial

:install
ECHO "***** install WITH CMAKE *****"
cmake --install . --verbose
IF %ERRORLEVEL% NEQ 0 GOTO end_pop
IF NOT "%section%"=="all" GOTO end_pop  REM end if partial


REM :test
REM ECHO "***** TEST WITH CMAKE *****"
REM ctest -C %cmake_build_type% -VV -L T_UNIT_SHORT
REM IF %ERRORLEVEL% NEQ 0 GOTO end_pop
REM IF NOT "%section%"=="all" GOTO end_pop  REM end if partial


:end_pop
popd

:end
IF %ERRORLEVEL% NEQ 0 (
  SET /A errno=%ERRORLEVEL%
)

EXIT /B %errno%

@ECHO ON