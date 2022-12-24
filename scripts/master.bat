@echo off 

:: modify TARGET_MODEL with your swatcup project name
set TARGET_MODEL=example.Sufi2.SwatCup
echo Begining execution
echo start time: %time%
START /Wait /D %TARGET_MODEL% SUFI2_Run.bat 
echo end time: %time%
echo Complete

