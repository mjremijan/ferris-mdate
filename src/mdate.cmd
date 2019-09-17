@Echo off
setlocal enabledelayedexpansion

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
if [%1] == [] goto help

REM Check if 1st parameter is for printing help
if [%1]==[--title] goto title

REM Check if 1st parameter is for printing help
if [%1]==[--help] goto help

REM set filename
echo -- Setting filename & echo.
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
echo hour='%hour%'
if [%hour%] == [] (
	echo ERROR^^!^^! could not determine hour 
	echo.
	goto help
)

echo minute='%minute%'
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
rem exiftool "-*Date=%year%:%month%:%day% %hour%:%minute%:00-05:00" -overwrite_original -wm w %filename%
exiftool "-*Date=%year%:%month%:%day% %hour%:%minute%:00-05:00" -api QuickTimeUTC -overwrite_original -wm w %filename%

echo. & echo -- Running nircmd... & echo.
nircmd setfiletime %filename% "%day%-%month%-%year% %hour%:%minute%:00" "%day%-%month%-%year% %hour%:%minute%:00" 

goto done

:help
echo Usage
echo.
echo    mdate.cmd "Name of your video file (yyyy-mm-dd hh.mm).mp4"
echo.

:done
echo.
echo      _                  
echo   __^| ^| ___  _ __   ___ 
echo  / _` ^|/ _ \^| '_ \ / _ \
echo ^| (_^| ^| (_) ^| ^| ^| ^|  __/
echo  \__,_^|\___/^|_^| ^|_^|\___^|
echo.

:title
echo.