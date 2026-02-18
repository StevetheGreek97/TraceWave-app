@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "VENV=%VENV%"
if "%VENV%"=="" set "VENV=.venv"

set "PYTHON=%PYTHON%"

if "%PYTHON%"=="" (
  where py >nul 2>nul && set "PYTHON=py -3"
)
if "%PYTHON%"=="" (
  where python >nul 2>nul && set "PYTHON=python"
)
if "%PYTHON%"=="" (
  where python3 >nul 2>nul && set "PYTHON=python3"
)

if "%PYTHON%"=="" (
  echo Error: Python not found. Install Python 3.9+ and ensure it is on PATH.
  exit /b 1
)

rem ---- Ensure FFmpeg / FFprobe are available (required for video import) ----
where ffmpeg >nul 2>nul
set "HAS_FFMPEG=%errorlevel%"
where ffprobe >nul 2>nul
set "HAS_FFPROBE=%errorlevel%"

if not "%HAS_FFMPEG%"=="0" (
  echo FFmpeg not found. Attempting to install...
  where winget >nul 2>nul
  if "%errorlevel%"=="0" (
    winget install --id Gyan.FFmpeg -e
  ) else (
    where choco >nul 2>nul
    if "%errorlevel%"=="0" (
      choco install -y ffmpeg
    ) else (
      echo Error: FFmpeg not found and no supported installer ^(winget/choco^) is available.
      echo Please install FFmpeg manually and ensure ffmpeg/ffprobe are on PATH.
      exit /b 1
    )
  )
)

where ffmpeg >nul 2>nul
if not "%errorlevel%"=="0" (
  echo Error: FFmpeg install failed or not on PATH.
  echo Please install FFmpeg manually and ensure ffmpeg/ffprobe are on PATH.
  exit /b 1
)

where ffprobe >nul 2>nul
if not "%errorlevel%"=="0" (
  echo Error: FFprobe not found on PATH.
  echo Please ensure FFmpeg is installed correctly and ffprobe is on PATH.
  exit /b 1
)

if not exist "%VENV%\" (
  %PYTHON% -m venv "%VENV%"
  if errorlevel 1 exit /b 1
)

set "PY=%VENV%\Scripts\python.exe"
set "PIP=%VENV%\Scripts\pip.exe"

if not exist "%PY%" (
  echo Error: Python not found at %PY%
  echo Tip: delete "%VENV%" and re-run this script.
  exit /b 1
)

"%PIP%" install --upgrade pip
if errorlevel 1 exit /b 1

"%PIP%" install -e ".[sam2,yaml]"
if errorlevel 1 exit /b 1

set "SAM2_URL=https://huggingface.co/facebook/sam2-hiera-tiny/resolve/main/sam2_hiera_tiny.pt"
set "SAM2_WEIGHTS=src\sam2_configs\sam2_hiera_tiny.pt"

if not exist "%SAM2_WEIGHTS%" (
  powershell -NoProfile -Command "$u='%SAM2_URL%'; $o='%SAM2_WEIGHTS%'; New-Item -ItemType Directory -Force -Path (Split-Path $o) | Out-Null; Invoke-WebRequest -Uri $u -OutFile $o"
  if errorlevel 1 (
    if exist "%SAM2_WEIGHTS%" (
      rem ok
    ) else (
      echo Error: Failed to download SAM2 weights.
      exit /b 1
    )
  )
)

echo Done.
echo Activate with: %VENV%\Scripts\activate.bat
echo Run with: %VENV%\Scripts\python.exe -m src.tracewave
