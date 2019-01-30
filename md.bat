@echo off
:: call root.bat
set a=%Date:~0,4%%Date:~5,2%%Date:~8,2%_
set b=%TIME:~0,2%
if %TIME:~0,2% leq 9 (set b=0%TIME:~1,1%)else set b=%TIME:~0,2%
set c=%TIME:~3,2%%TIME:~6,2%
echo "%a%%b%%c%"
md "%a%%b%%c%"
rem dir /ad /b /o-d e:\
rem dir /ad /b e:\
rem Adb pull /data/anr/  
::Adb pull /sdcard/360sicheck.txt  