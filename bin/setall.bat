@echo off
REM Set project base and env for STC Automation (call before run.bat or run_tests.py)
set BASE_DIR=%~dp0..
if not "%BASE_DIR:~-1%"=="" set BASE_DIR=%BASE_DIR:~0,-1%
set PYTHONPATH=%BASE_DIR%;%BASE_DIR%\variables;%BASE_DIR%\variables\common;%PYTHONPATH%
if exist "%BASE_DIR%\venv\Scripts\activate.bat" call "%BASE_DIR%\venv\Scripts\activate.bat"
if exist "%BASE_DIR%\.venv\Scripts\activate.bat" call "%BASE_DIR%\.venv\Scripts\activate.bat"
