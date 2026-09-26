@echo off
setlocal enabledelayedexpansion

echo ========================================================
echo   COAD Milestone 2 - Single Cycle RISC-V Simulation
echo   Simulator: Mentor ModelSim
echo ========================================================

REM Chuyen den thu muc chua script (03_sim)
cd /d "%~dp0"

REM 1. Tao thu vien work neu chua ton tai
if not exist work (
    echo [INFO] Creating library 'work'...
    vlib work
)

REM 2. Bien dich source code tu 00_src
echo [INFO] Compiling design source files (*.sv) in 00_src...
vlog -sv ../00_src/*.sv
if %errorlevel% neq 0 (
    echo [ERROR] Failed to compile design files in 00_src!
    goto :end
)

REM 3. Bien dich testbench tu 01_bench
echo [INFO] Compiling testbench files in 01_bench...
vlog -sv -mfcu ../01_bench/tlib.svh ../01_bench/driver.sv ../01_bench/scoreboard.sv ../01_bench/tbench.sv
if %errorlevel% neq 0 (
    echo [ERROR] Failed to compile testbench files in 01_bench!
    goto :end
)

REM 4. Chay mo phong
if /i "%1"=="gui" (
    echo [INFO] Launching ModelSim GUI with waveform...
    vsim -gui -do "do wave.do; run -all;" tbench
) else (
    echo [INFO] Running simulation in console mode...
    vsim -c -do "run -all; quit" tbench
)

:end
echo.
echo ========================================================
echo Simulation script finished.
echo ========================================================
if /i "%1"=="pause" pause
if /i "%2"=="pause" pause
