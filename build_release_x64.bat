@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"
set "ERR=0"

echo.
echo === Compilar scs_telemetry_jaime.dll (SDK SCS 1.14) ===
echo Carpeta: %CD%
echo.

set "ROOT=%~dp0"
set "OUT=%ROOT%build\Release"
set "SRC=%ROOT%scs_telemetry_jaime\src"
set "INC=%ROOT%scs_telemetry_jaime\inc"
set "SDK_INC=%ROOT%scs_sdk\include"
set "DEF=%ROOT%scs_telemetry_jaime\vs2012\scs_telemetry_jaime.def"

if not exist "%SRC%\scs_telemetry.cpp" (
  echo ERROR: No se encuentra el codigo fuente en %SRC%
  set "ERR=1"
  goto :fin
)

if not exist "%SDK_INC%\scssdk.h" (
  echo ERROR: Falta el SDK SCS 1.14 en scs_sdk\include
  set "ERR=1"
  goto :fin
)

set "VSINSTALL="
set "VCVER="
set "PF86=%ProgramFiles(x86)%"
for %%P in ("%ProgramFiles%" "%PF86%") do (
  for %%Y in (18 2026 2022) do (
    for %%E in (BuildTools Community) do (
      set "CAND=%%~P\Microsoft Visual Studio\%%Y\%%E"
      if exist "!CAND!\VC\Tools\MSVC" (
        for /f "delims=" %%V in ('dir /b /ad /o-n "!CAND!\VC\Tools\MSVC" 2^>nul') do (
          if exist "!CAND!\VC\Tools\MSVC\%%V\include\excpt.h" (
            set "VSINSTALL=!CAND!"
            set "VCVER=%%V"
          )
        )
      )
    )
  )
)

if not defined VSINSTALL (
  echo ERROR: No se encontro MSVC completo ^(include\excpt.h^).
  echo Ejecuta diagnose_build_env.bat
  set "ERR=1"
  goto :fin
)

set "VCBIN=%VSINSTALL%\VC\Tools\MSVC\%VCVER%\bin\Hostx64\x64"
set "VCINC=%VSINSTALL%\VC\Tools\MSVC\%VCVER%\include"
set "VCLIB=%VSINSTALL%\VC\Tools\MSVC\%VCVER%\lib\x64"
echo Usando: %VSINSTALL%
echo MSVC: %VCVER%
echo.

set "WINKIT=%PF86%\Windows Kits\10"
set "WINVER=10.0.26100.0"
if not exist "%WINKIT%\Include\%WINVER%\um\windows.h" set "WINVER=10.0.22621.0"
if not exist "%WINKIT%\Include\%WINVER%\um\windows.h" set "WINVER=10.0.19041.0"

if not exist "%VCBIN%\cl.exe" (
  echo ERROR: No se encuentra cl.exe
  set "ERR=1"
  goto :fin
)
if not exist "%WINKIT%\Include\%WINVER%\um\windows.h" (
  echo ERROR: No se encuentra Windows SDK
  set "ERR=1"
  goto :fin
)

set "PATH=%VCBIN%;%PATH%"
mkdir "%OUT%" 2>nul
pushd "%SRC%"

echo Compilando...
"%VCBIN%\cl.exe" /nologo /EHsc /O2 /MD ^
  /DWIN32 /DNDEBUG /D_WINDOWS /D_USRDLL /DUNICODE /D_UNICODE /DTELEMETRY_EXPORTS /DTRUCKHUD_BUILT_WITH_SCS_SDK_1_14=1 ^
  /I"%VCINC%" /I"%WINKIT%\Include\%WINVER%\ucrt" /I"%WINKIT%\Include\%WINVER%\shared" /I"%WINKIT%\Include\%WINVER%\um" /I"%SDK_INC%" /I"%INC%" ^
  log.cpp scs_gameplay_event_handlers.cpp scs_telemetry.cpp scs_config_handlers.cpp sharedmemory.cpp ^
  /LD /Fe"%OUT%\scs_telemetry_jaime.dll" ^
  /link /DEF:"%DEF%" /LIBPATH:"%VCLIB%" /LIBPATH:"%WINKIT%\Lib\%WINVER%\ucrt\x64" /LIBPATH:"%WINKIT%\Lib\%WINVER%\um\x64"

set "ERR=%ERRORLEVEL%"
popd

if not "%ERR%"=="0" (
  echo ERROR de compilacion ^(codigo %ERR%^).
  goto :fin
)

mkdir "%ROOT%Win64" 2>nul
copy /Y "%OUT%\scs_telemetry_jaime.dll" "%ROOT%Win64\scs_telemetry_jaime.dll"
echo.
echo OK: %OUT%\scs_telemetry_jaime.dll
echo Copiado a Win64\scs_telemetry_jaime.dll

:fin
echo.
if "%ERR%"=="0" (echo Resultado: EXITO) else (echo Resultado: FALLO ^(codigo %ERR%^))
echo.
pause
exit /b %ERR%
