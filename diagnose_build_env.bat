@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

echo.
echo === Diagnostico compilacion plugin SDK 1.14 ===
echo.

set "OK=1"
set "PF86=%ProgramFiles(x86)%"
set "BEST_VS="
set "BEST_VER="
set "CL="

for %%P in ("%ProgramFiles%" "%PF86%") do (
  for %%Y in (18 2026 2022) do (
    for %%E in (BuildTools Community) do (
      set "BASE=%%~P\Microsoft Visual Studio\%%Y\%%E"
      if exist "!BASE!\MSBuild\Current\Bin\MSBuild.exe" (
        echo [OK] MSBuild: !BASE!
      )
      if exist "!BASE!\VC\Tools\MSVC" (
        for /f "delims=" %%V in ('dir /b /ad /o-n "!BASE!\VC\Tools\MSVC" 2^>nul') do (
          if exist "!BASE!\VC\Tools\MSVC\%%V\bin\Hostx64\x64\cl.exe" (
            set "CL=!BASE!\VC\Tools\MSVC\%%V\bin\Hostx64\x64\cl.exe"
          )
          if exist "!BASE!\VC\Tools\MSVC\%%V\include\excpt.h" (
            set "BEST_VS=!BASE!"
            set "BEST_VER=%%V"
          )
        )
      )
    )
  )
)

if defined CL (
  echo [OK] cl.exe: %CL%
) else (
  echo [FALTA] cl.exe
  set "OK=0"
)

if defined BEST_VS (
  echo [OK] Headers MSVC ^(excpt.h^): %BEST_VS% ^(MSVC %BEST_VER%^)
) else (
  echo [FALTA] Carpeta include de MSVC ^(excpt.h^)
  set "OK=0"
)

if defined BEST_VS if exist "%BEST_VS%\VC\Auxiliary\Build\vcvarsall.bat" (
  echo [OK] vcvarsall.bat
) else (
  echo [AVISO] vcvarsall.bat no encontrado ^(no impide compilar con build_release_x64.bat^)
)

set "WINSDK="
for /f "delims=" %%D in ('dir /b /ad /o-n "%PF86%\Windows Kits\10\Include" 2^>nul') do (
  echo %%D | findstr /r "^10\." >nul && if not defined WINSDK set "WINSDK=%%D"
)
if defined WINSDK (
  if exist "%PF86%\Windows Kits\10\Include\%WINSDK%\um\windows.h" (
    echo [OK] Windows SDK: %WINSDK%
  ) else (
    echo [FALTA] windows.h en Windows SDK %WINSDK%
    set "OK=0"
  )
) else (
  echo [FALTA] Windows 10/11 SDK
  set "OK=0"
)

if exist "%~dp0scs_sdk\include\scssdk.h" (
  echo [OK] SCS SDK 1.14 enlazado: %~dp0scs_sdk
) else (
  echo [FALTA] scs_sdk - mklink /J scs_sdk D:\ETS2\scs_sdk_1_14
  set "OK=0"
)

if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community" (
  if not defined BEST_VS (
    echo [AVISO] Restos de VS Community 2022 en Program Files ^(incompleto^). El script usa el MSVC bueno si existe.
  )
)

echo.
if "%OK%"=="1" (
  echo Resultado: listo para build_release_x64.bat
  echo Compilador elegido: %BEST_VS%
) else (
  echo Resultado: INCOMPLETO
)
echo.
pause
