@echo off
cd /d "%~dp0"
echo [INFO] Cleaning simulation output files...
if exist work rd /s /q work
if exist wave.shm rd /s /q wave.shm
if exist transcript del /f /q transcript
if exist vsim.wlf del /f /q vsim.wlf
if exist *.log del /f /q *.log
if exist *.vcd del /f /q *.vcd
if exist xrun.* del /f /q xrun.*
if exist .simvision rd /s /q .simvision
echo [INFO] Done cleaning!
pause
