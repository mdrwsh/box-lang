@echo off
setlocal EnableDelayedExpansion
set "argv=%*" & set "n=0" & for %%a in (!argv!) do set/a n+=1
set "argc=!n!"
set SYS_CHAR=/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
goto PROGRAM_MAIN

:PROGRAM_DATA
set "temp="&for /f "delims=0123456789." %%i in ("%~1") do set temp=%%i
if "!temp!" neq "%~1" (
  set "temp="&for /f "delims=+-/" %%i in ("%~1") do set "temp=%%i"
  if not "%~1" == "!temp!" (
    set str=%~1&if "!str://=!" neq "!str!" set/a str=!str://=-!*(!str://=/!^)
    set/a DATA=!str:++=^*! & exit/b
  )
)
set "DATA=%~1"
exit/b
