@echo off
call "%~dp0setall.bat"
set "BASE_DIR=%~dp0.."
if not "%BASE_DIR:~-1%"=="" set "BASE_DIR=%BASE_DIR:~0,-1%"

REM ── Build common args from environment variables ──────────────────────────
set "PY_ARGS="
if defined TESTPLAN set "PY_ARGS=%PY_ARGS% --suite %TESTPLAN%"
if defined PROFILE  set "PY_ARGS=%PY_ARGS% --env %PROFILE%"
if defined BROWSER  set "PY_ARGS=%PY_ARGS% --browser %BROWSER%"
if defined TAGS     set "PY_ARGS=%PY_ARGS% --include %TAGS%"

if defined RUNNAME (
  for /f "usebackq delims=" %%T in (`python -c "from datetime import datetime; print(datetime.now().strftime('%%Y-%%m-%%d_%%H-%%M-%%S'))"`) do set "TIMESTAMP=%%T"
  set "PY_ARGS=%PY_ARGS% --outputdir %BASE_DIR%\reports\%RUNNAME%_%TIMESTAMP%"
)

REM ── Framework mode: FRAMEWORK=1 or --framework flag → STCFramework.robot ──
set "USE_FRAMEWORK=0"
if /i "%FRAMEWORK%"=="1" set "USE_FRAMEWORK=1"
if /i "%1"=="--framework" (
  set "USE_FRAMEWORK=1"
  shift
)

if "%USE_FRAMEWORK%"=="1" (
  python "%BASE_DIR%\run_tests.py" --framework %PY_ARGS% %*
  goto :eof
)

REM ── Default mode: run_tests.py (tasks.csv / specific suite / e2e etc.) ────
if defined PY_ARGS (
  python "%BASE_DIR%\run_tests.py" %PY_ARGS% %*
) else (
  python "%BASE_DIR%\run_tests.py" %*
)
