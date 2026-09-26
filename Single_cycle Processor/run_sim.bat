@echo off
setlocal enabledelayedexpansion

REM ========================================================
REM   COAD Milestone 2 - Single Cycle RISC-V Simulation
REM   Root Launcher for ModelSim Simulation
REM ========================================================

REM Chuyen vao thu muc 03_sim de luu toan bo file sinh ra tai do
cd /d "%~dp003_sim"

call run_sim.bat %*
