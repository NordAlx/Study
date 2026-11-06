@echo off
setlocal
chcp 65001 >nul
cd /d "%~dp0"
set "IPYTHONDIR=%~dp0.jupyter\ipython"
set "JUPYTER_CONFIG_DIR=%~dp0.jupyter\config"
set "JUPYTER_RUNTIME_DIR=%~dp0.jupyter\runtime"
set "JUPYTER_DATA_DIR=%~dp0.jupyter\data"
set "MPLCONFIGDIR=%~dp0.jupyter\matplotlib"
set "PRACTICE_PYTHON=C:\Users\poliektovm\Documents\Codex\2026-09-21\new-chat\work\.venv\Scripts\python.exe"
if exist "%~dp0.venv\Scripts\python.exe" set "PRACTICE_PYTHON=%~dp0.venv\Scripts\python.exe"
if not exist "%PRACTICE_PYTHON%" (
  echo Python environment not found. See requirements.txt and notebook setup instructions.
  pause
  exit /b 1
)
"%PRACTICE_PYTHON%" -m notebook "Практика1.ipynb"
endlocal
