@Echo off
REM setlocal EnableDelayedExpansion

REM http://patorjk.com/software/taag/#p=display&f=Ogre&t=exif

echo.
echo                _       _       
echo  _ __ ___   __^| ^| __ _^| ^|_ ___ 
echo ^| '_ ` _ \ / _` ^|/ _` ^| __/ _ \
echo ^| ^| ^| ^| ^| ^| (_^| ^| (_^| ^| ^|^|  __/
echo ^|_^| ^|_^| ^|_^|\__,_^|\__,_^|\__\___^|
echo.
echo    Mp4 Date And Title Editor
echo.

REM Exit if not at least 1 parameter
if [%1] == [] goto helpdone

REM Check if 1st parameter is for printing help
if [%1]==[--title] goto title

REM Check if 1st parameter is for printing help
if [%1]==[--help] goto help

REM Check if 1st parameter is for processing a directory
if [%1]==[--dir] (goto processdir) else (goto processfile)


:processdir
echo -- Processing current directory & echo.
for /f "tokens=*" %%f in ('dir /b .\*.mp4') do (
	call :processing "%%~nxf"
)
goto done

REM echo --- Build array of MP4 filenames
REM set "idx=-1"
REM for %%f in (.\*.mp4) do ( 
REM 	echo "%%f"
REM 	set /A "idx=!idx!+1"	
REM 	set files[!idx!]="%%~nxf"
REM )
REM for /L %%x in (0,1,%idx%) do (
REM 	echo  
REM 	call :processing !files[%%x]!
REM )
REM goto done


:processfile
call :processing %1
goto done

:processing
REM set filename
echo -- Processing file & echo.
set filename=%1
echo filename='%filename%'
echo.

REM filename exists
echo -- Filename exists? & echo.
IF NOT EXIST %filename% (
	echo ERROR^^!^^! file does not exist:  
	echo.
	goto help
) 

REM parse the filename for information
echo -- Parsing filename & echo.

REM description
set inn=%filename%
for /f "tokens=1,2 delims=(" %%a in (%inn%) do (
  set description=%%a
  set AFTER=%%b
)
for /l %%a in (1,1,1000) do if "!description:~-1!"==" " set description=!description:~0,-1!
echo description='%description%'
echo.

REM fulldate
set inn="%AFTER%"
for /f "tokens=1,2" %%a in (%inn%) do (
  set fulldate=%%a
  set AFTER=%%b
)
echo fulldate='%fulldate%'
echo.
if [%fulldate%] == [] (
	echo ERROR^^!^^! could not determine fulldate 
	echo.
	goto help
)


REM year,month,day
set inn="%fulldate%"
for /f "tokens=1,2,3 delims=-" %%a in (%inn%) do (
  set year=%%a
  set month=%%b
  set day=%%c
)
echo year='%year%'
if [%year%] == [] (
	echo ERROR^^!^^! could not determine year 
	echo.
	goto help
)

echo month='%month%'
if [%month%] == [] (
	echo ERROR^^!^^! could not determine month 
	echo.
	goto help
)

echo day='%day%'
if [%day%] == [] (
	echo ERROR^^!^^! could not determine day 
	echo.
	goto help
)
echo.

REM fulltime
set inn="%AFTER%"
for /f "tokens=1,2 delims=)" %%a in (%inn%) do (
  set fulltime=%%a
  set AFTER=%%b
)
echo fulltime='%fulltime%'
echo.
if [%fulltime%] == [] (
	echo ERROR^^!^^! could not determine fulltime 
	echo.
	goto help
)

REM hour,minute
set inn="%fulltime%"
for /f "tokens=1,2 delims=." %%a in (%inn%) do (
  set hour=%%a
  set minute=%%b
)
echo hour 1='%hour%'
set /a hour=10000%hour% %% 10000
echo hour 2='%hour%'
if [%hour%] == [] (
	echo ERROR^^!^^! could not determine hour 
	echo.
	goto help
)

echo minute 1='%minute%'
set /a minute=10000%minute% %% 10000
echo minute 2='%minute%'
if [%minute%] == [] (
	echo ERROR^^!^^! could not determine minute 
	echo.
	goto help
)
echo.

REM run exiftool
rename %filename% %filename%_original

echo -- Running ffmpeg... & echo.
ffmpeg -i %filename%_original -metadata Title="%description% (%year%-%month%-%day%)" -map_metadata 0 -codec copy %filename%

echo. & echo -- Running exiftool... & echo.
exiftool "-*Date=%year%:%month%:%day% %hour%:%minute%:00-05:00" -api QuickTimeUTC -overwrite_original -wm w %filename%

echo. & echo -- Running nircmd... & echo.
if %hour% LSS 10 (
    set hourpadded=0%hour%
) else (
    set hourpadded=%hour%
)
echo hourpadded=%hourpadded%


if %minute% LSS 10 (
    set minutepadded=0%minute%
) else (
    set minutepadded=%minute%
)
echo minutepadded=%minutepadded%

echo nircmd setfiletime %filename% "%day%-%month%-%year% %hourpadded%:%minutepadded%:00" "%day%-%month%-%year% %hourpadded%:%minutepadded%:00" "%day%-%month%-%year% %hourpadded%:%minutepadded%:00"
nircmd setfiletime %filename% "%day%-%month%-%year% %hourpadded%:%minutepadded%:00" "%day%-%month%-%year% %hourpadded%:%minutepadded%:00" "%day%-%month%-%year% %hourpadded%:%minutepadded%:00" 

exit /b

:helpdone
call :help
call :done
goto:eof

:help
echo Usage
echo.
echo    mdate.cmd --title  // Print the title of the application
echo.
echo    mdate.cmd --help   // Print the help
echo.
echo    mdate.cmd --dir  // All (*.mp4) files in current directory
echo.
echo    mdate.cmd "Video file (yyyy-mm-dd hh.mm).mp4"  // This file in current directory
echo.

exit /b

:done
echo.
echo      _                  
echo   __^| ^| ___  _ __   ___ 
echo  / _` ^|/ _ \^| '_ \ / _ \
echo ^| (_^| ^| (_) ^| ^| ^| ^|  __/
echo  \__,_^|\___/^|_^| ^|_^|\___^|
echo.

exit /b

:title
echo.
