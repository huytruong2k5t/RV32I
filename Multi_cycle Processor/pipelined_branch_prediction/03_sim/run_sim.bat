@echo off
setlocal enabledelayedexpansion

:: Determine 03_sim directory and project root directory
set "SIM_DIR=%~dp0"
pushd "%SIM_DIR%.."
set "ROOT_DIR=%CD%"
popd

cd /d "%SIM_DIR%"

:: Refresh work library
if exist "work" (
    vdel -all -lib work >nul 2>&1
)
vlib work >nul 2>&1

:: Compile source files and testbench
echo ===================================================
echo [1/2] Compiling design and testbench...
echo ===================================================
vlog -sv -mfcu +incdir+../01_bench ../00_src/*.sv ../01_bench/tlib.svh ../01_bench/*.sv
if %errorlevel% neq 0 (
    echo [ERROR] Compilation failed!
    cd /d "%ROOT_DIR%"
    exit /b %errorlevel%
)

:: Check for gui argument
if /i "%1"=="gui" (
    echo ===================================================
    echo [2/2] Launching ModelSim GUI with Waveforms...
    echo ===================================================
    start vsim -gui -do "do gui.do" work.tbench
) else (
    echo ===================================================
    echo [2/2] Running ModelSim in CLI mode...
    echo ===================================================
    vsim -c -do "do sim.do" work.tbench
)

cd /d "%ROOT_DIR%"
