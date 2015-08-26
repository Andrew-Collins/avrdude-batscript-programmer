@echo off

set mypath=%~dp0
set mypath=%mypath:~0,-1%
: dirloop 
	set /p directory= Enter file location (folder):
	cd %directory%
	if errorlevel 1 (
		echo Invalid Directory...
		goto dirloop
	)
	goto dirend
: dirend 

: nameloop
	set /p name= Enter file name:
	if not exist %name%.c (
		echo File Not Found...
		goto nameloop
	)
	goto namend
: namend

: chiploop 
	set /p chip= Enter Avr model: 
	avr-gcc -g -Os -mmcu=%chip% -c %name%.c 
	if errorlevel 1 goto chiperror
	goto chipend

: chiperror
	echo Invalid Chip...
	cd %mypath%
	set /p answer= Would you like to see the supported chip codes? {y/n}:
	if "%answer%" == "y" type chips.txt
	cd %directory% 
	goto chiploop

: chipend

avr-gcc -g -mmcu=%chip% -o %name%.elf %name%.o
avr-objcopy -j .text -j .data -O ihex %name%.elf %name%.hex

set /p answer= Would you like to upload the file {y/n}? 
if "%answer%" == "y" goto upload
goto end

: upload 
	set /p model= Enter code for chip {if you don't know press enter}: 
	if "%model%" == "" goto modelerr
	avrdude -p %model% -P com1 -c avrisp -b 19200 -U flash:w:%name%.hex 2>&1 >nul | findstr /c:"Valid parts are:" 1>nul
	if errorlevel 1 goto port

	: modelerr
	echo Invalid code... 
	set /p answer= Would you like to see the supported chip codes {y/n}? 
	if not "%answer%" == "y" goto upload
	cd %mypath% 
	type codes.txt
	cd %directory%
	goto upload
	:port
	set /p port= Enter com port:
	if "%port%" == "" goto porterr 
	avrdude -p %model% -P com%port% -c avrisp -b 19200 -U flash:w:%name%.hex 2>error.txt
	set /p error= <error.txt
	if not "%error%" == "" (
		: porterr
		echo Invalid Port
		goto port
	) 




: end
pause	