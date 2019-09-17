@Echo off

set mdate_home="%~dp0"
set PATH=%mdate_home%;%PATH%

set exiftool_home=%mdate_home%\exiftool-11.09
set PATH=%exiftool_home%\bin;%PATH%

set ffmpeg_home=%mdate_home%\ffmpeg-20190709-5a481b1-win64-static
set PATH=%ffmpeg_home%\bin;%PATH%

set nircmd_home=%mdate_home%\nircmd-2.85
set PATH=%nircmd_home%\bin;%PATH%

D:
@Echo off
cmd.exe /K "doskey ls=dir & cd D:\Videos\Home Videos\2019 & mdate --title"