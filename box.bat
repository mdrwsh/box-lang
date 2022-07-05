@echo off
setlocal EnableDelayedExpansion
if not exist std.bat echo ERROR: could not find 'std.bat' & exit/b
set COMPILER_OP=
if "%~1" == "" goto usage
if %1 == -h goto usage
if %1 == -t goto tests
if %1 == -u goto update
if %1 == -e goto editor
if %1 == -c set COMPILER_OP=compile
if %1 == -r set COMPILER_OP=run
if not defined COMPILER_OP goto usage
if not exist "%~2" echo ERROR: %2 --^> could not find the file & exit/b
if "%~x2" neq ".box" echo ERROR: %2 --^> expected '.box' filetype & exit/b
if "%~3" == "" (set FILE_OUTPUT=out.bat) else set FILE_OUTPUT=%~3
set FILE_INPUT=%~2

:main
set SYS_COMMAND=cmd include print println printf printc set get getc getf def array append split join pop replace loop while break if ifnot else end func file clear quit
set SYS_SPLITCOM=$ cmd print set get getc getf def array append split join pop replace break else end clear quit
set SYS_TEMPVARCHAR=zyxwvutsrqponmlkjihgfedcba
set SYS_CONDITION=equ neq gtr lss geq leq in
set SYS_CONDITION_EXT=exist#c5 defined#c5 
set FUNC_COMMAND=PROGRAM_MAIN PROGRAM_DATA
set PROGRAM_MAIN_ARGC=0
set PROGRAM_DATA_ARGC=0
set FILE_INCLUDE=!FILE_INPUT!
set ERROR_RETURN=false
set START_MAIN=false
set IS_FUNC=false
set BRACKET_COUNT=0
set ERROR_COUNT=0
set INCLUDE_INC=0
set WHILE_ID=0
set SYS_LINE=0
set SYS_STACK=
set argv=defined
set argc=defined

rem TODO: separate math operation
rem (
rem   for /f "tokens=*" %%f in (!FILE_INPUT!) do (
rem     set "PREVWORD="
rem     set SYS_CALL=%%f
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:(=#c1!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:)=#c2!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:&=#c3!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:%%=#c4!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:?=#c5!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:>=#c6!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:<=#c7!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:|=#c8!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:^=#c9!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:\"=#d1!"
rem     if defined SYS_CALL set "SYS_CALL=!SYS_CALL:,=#d2!"
rem     for %%a in (!SYS_CALL!) do (
rem       for %%b in (!SYS_SPLITCOM! !FUNC_COMMAND!) do if defined PREVWORD if "!PREVWORD!" neq "$" if "!PREVWORD!" neq "else" if %%a == %%b echo.
rem       set PREVWORD=%%a
rem       echo|set/p="%%a "
rem     )
rem     echo.
rem   )
rem ) >.boxtemp

:STARTCOM
set SYS_STIME=!time!
type std.bat>!FILE_OUTPUT!
for /f "delims=" %%f in ('findstr /N "^^" "%~dp0\!FILE_INPUT!"') DO (
  set/a SYS_LINE+=1
  set TEMPCHARIND=0
  set SYS_CALL=%%f
  set "SYS_CALL=!SYS_CALL:*:=!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:(=#c1!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:)=#c2!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:&=#c3!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:%%=#c4!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:?=#c5!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:>=#c6!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:<=#c7!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:|=#c8!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:^=#c9!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:\"=#d1!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:,=#d2!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:"=#d3!"
  
  rem TODO: quote is checked until the 300th character only
  set "QUOTE_COUNT=0" & for /l %%a in (1,1,300) do (
    if "!SYS_CALL:~%%a,3!" == "#d3" (set/a QUOTE_COUNT+=1))
  set/a "QUOTE_CHECK=!QUOTE_COUNT!-2*(!QUOTE_COUNT!/2)"
  if !QUOTE_CHECK! neq 0 (call :error "unbalanced quotation") else (
    if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#d3="!"
    call :sys !SYS_CALL!
  )
  if !ERROR_COUNT! gtr 100 goto ENDCOM
)
set SYS_ETIME=!time!
call :timed !SYS_STIME! !SYS_ETIME!
:ENDCOM
if !BRACKET_COUNT! neq 0 echo ERROR: Unbalanced bracket (-!BRACKET_COUNT!)& set ERROR_RETURN=true& set/a ERROR_COUNT+=1
if !ERROR_COUNT! gtr 100 echo STOPPED: Too many errors
if !START_MAIN! == false echo :PROGRAM_MAIN>>!FILE_OUTPUT!
if !FROM_INCLUDE! == false echo exit/b>>!FILE_OUTPUT!
if !ERROR_RETURN! == false (
  echo SUCCESS: !FILE_INPUT! --^> !FILE_OUTPUT! ^(!TIMED_RETURN!^)
  if !COMPILER_OP! == run !FILE_OUTPUT!
  exit/b 0
) else (
  echo FAILED: !FILE_INPUT! --^> !FILE_OUTPUT!
  del !FILE_OUTPUT!
  exit/b 1
)

:sys
for %%a in (%*) do (
  if %%a equ $ exit/b
  for %%b in (!SYS_COMMAND!) do if %%a == %%b (
    if !START_MAIN! == false if !IS_FUNC! == false if not %%a == func (set START_MAIN=true& echo :PROGRAM_MAIN>>!FILE_OUTPUT!)
    call :%*
    exit/b
  )
  for %%b in (!FUNC_COMMAND!) do if %%a == %%b (
    set FUNC_TEMP=
    if !START_MAIN! == false if !IS_FUNC! == false set START_MAIN=true& echo :PROGRAM_MAIN>>!FILE_OUTPUT!
    set "n=-1" & for %%c in (%*) do set/a n+=1& if !n! == 0 (set FUNC_NAMETEMP=%%a) else set FUNC_TEMP=!FUNC_TEMP! %%c
    if !IS_FUNC! == true if !FUNC_NAMETEMP! == !FUNC_NAME! call :error "recursion detected" & exit/b
    call :datatypef !FUNC_TEMP!
    for %%c in (!FUNC_NAMETEMP!) do if !n! neq !%%c_ARGC! call :error "'!FUNC_NAMETEMP!' expects !%%c_ARGC! argument, but got !n!" & exit/b
    (
      echo call :!FUNC_NAMETEMP! !DATATYPE_RETURN!
      echo if ^^!PROGRAM_EXIT^^! == true exit/b
    ) >>!FILE_OUTPUT!
    exit/b
  )
  call :error "unknown command or function" & exit/b
)
exit/b

:cmd
call :datatype %*
echo !DATATYPE_RETURN!>>!FILE_OUTPUT!
exit/b

:include
if "%~2" neq "" call :error "include only accepts one argument"
if %1 equ %~1 call :error "expected string type" & exit/b
if not exist "%~1" call :error "the file does not exist" & exit/b
if "%~x1" neq ".box" call :error "expected '.box' filetype" & exit/b
rem TODO: normalize path
for %%a in (!FILE_INCLUDE!) do if "%%~a" equ "%~1" call :error "include recursion detected" & exit/b
echo INCLUDING: %~1
set FILE_INPUT!INCLUDE_INC!=!FILE_INPUT!
set FILE_LINE!INCLUDE_INC!=!SYS_LINE!
set/a INCLUDE_INC+=1
set FILE_INPUT=%~1
set SYS_LINE=0
for /f "delims=" %%f in ('findstr /N "^^" "%~dp0\!FILE_INPUT!"') DO (
  set/a SYS_LINE+=1
  set TEMPCHARIND=0
  set SYS_CALL=%%f
  set "SYS_CALL=!SYS_CALL:*:=!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:(=#c1!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:)=#c2!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:&=#c3!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:%%=#c4!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:?=#c5!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:>=#c6!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:<=#c7!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:|=#c8!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:^=#c9!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:\"=#d1!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:,=#d2!"
  if defined SYS_CALL set "SYS_CALL=!SYS_CALL:"=#d3!"
  
  rem TODO: quote is checked until the 300th character only
  set "QUOTE_COUNT=0" & for /l %%a in (1,1,300) do (
    if "!SYS_CALL:~%%a,3!" == "#d3" (set/a QUOTE_COUNT+=1))
  set/a "QUOTE_CHECK=!QUOTE_COUNT!-2*(!QUOTE_COUNT!/2)"
  if !QUOTE_CHECK! neq 0 (call :error "unbalanced quotation") else (
    if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#d3="!"
    call :sys !SYS_CALL!
  )
  if !ERROR_COUNT! gtr 100 goto ENDCOM
)
set/a INCLUDE_INC-=1
for %%a in (!INCLUDE_INC!) do (
  set FILE_INPUT=!FILE_INPUT%%a!
  set SYS_LINE=!SYS_LINE%%a!
)
set FILE_INCLUDE=!FILE_INCLUDE! "%~1"
exit/b

:print
call :datatype %*
if !ERROR_RETURN! == true exit/b
if defined DATATYPE_RETURN (
  if !DATA_OP! == true (
    echo call :PROGRAM_DATA "!DATATYPE_RETURN!" ^& echo ^^!DATA^^!>>!FILE_OUTPUT!
  ) else echo echo !DATATYPE_RETURN!>>!FILE_OUTPUT!
) else echo echo.>>!FILE_OUTPUT!
exit/b

:println
call :datatype %*
if !ERROR_RETURN! == true exit/b
if defined DATATYPE_RETURN (
  if !DATA_OP! == true (
    echo call :PROGRAM_DATA "!DATATYPE_RETURN!" ^& echo^|set/p=^^!DATA^^!>>!FILE_OUTPUT!
  ) else echo echo^|set/p=!DATATYPE_RETURN!>>!FILE_OUTPUT!
)
exit/b

:printf
if !IS_FUNC! == false if not defined FILE_OP call :error "no file specified, use 'file' command" & exit/b
call :datatype %*
echo ^(echo !DATATYPE_RETURN!^) ^>^>!FILE_OP!>>!FILE_OUTPUT!
exit/b

:printc
call :datatypef %*
echo|set/p="echo ">>!FILE_OUTPUT!
for %%a in (!DATATYPE_RETURN!) do (
  echo|set/p="^!char_%%~a^!">>!FILE_OUTPUT!
)
echo.>>!FILE_OUTPUT!
exit/b

:set
if "%~1" == "" call :error "not enough argument" & exit/b
set FROM_SET=
set SET_TEMP=
set SET_VARNAME=
for %%a in (%*) do (
  if not defined SET_VARNAME (
    call :ischar %%a
    if !ISCHAR_RETURN! == true (set SET_VARNAME=%%a) else (
      call :error "variable name must be character type"
      exit/b
    )
  ) else set SET_TEMP=!SET_TEMP! %%a
)
if "!SET_VARNAME:_= !" neq "!SET_VARNAME!" (
  set FROM_SET=true
  call :arraytype !SET_VARNAME:_= !
  rem TODO: make 'replace' and 'set' work together when processing array
  if defined TYPE_RET set SET_VARNAME=!TYPE_RET!
)
call :datatype !SET_TEMP!
(
  if !ISGET_BOOL! == true (
    echo set/p !SET_VARNAME!=!DATATYPE_RETURN!
    echo|set/p=call :PROGRAM_DATA "^!!SET_VARNAME!^!"
    echo ^& set !SET_VARNAME!=^^!DATA^^!
  ) else (
    if !DATA_OP! == true (
      echo|set/p=call :PROGRAM_DATA "!DATATYPE_RETURN!"
      echo ^& set !SET_VARNAME!=^^!DATA^^!
    ) else echo set !SET_VARNAME!=!DATATYPE_RETURN!
  )
) >>!FILE_OUTPUT!
set !SET_VARNAME!=defined
set ISGET_BOOL=false
exit/b

:get
set ISGET_BOOL=true
goto set

:getc
set SET_TEMP=
set SET_VARNAME=
for %%a in (%*) do (
  if not defined SET_VARNAME (
    call :ischar %%a
    if !ISCHAR_RETURN! == true (set SET_VARNAME=%%a) else (
      call :error "variable name must be character type"
      exit/b
    )
  ) else set SET_TEMP=!SET_TEMP! %%a
)
if not defined SET_VARNAME call :error "not enough argument" & exit/b
(
  if defined SET_TEMP (
    call :datatype !SET_TEMP!
    echo choice /c:^^!SYS_CHAR:~1^^! /n /cs /m "!DATATYPE_RETURN!"
  ) else echo choice /c:^^!SYS_CHAR:~1^^! /n /cs
  echo set "!SET_VARNAME!=^!SYS_CHAR:~%%errorlevel%%,1^!"
) >>!FILE_OUTPUT!
set !SET_VARNAME!=defined
exit/b

:getf
if "%1" equ "" call :error "no variable specified" & exit/b
if not defined FILE_OP call :error "no file specified, use 'file' command" & exit/b
echo set "n=0"^&set "%1="^&for /f "tokens=*" %%%%a in (!FILE_OP!) do set/a n+=1^& set "%1_^!n^!=%%%%a"^& set %1=^^!%1^^!"%%%%a" >>!FILE_OUTPUT!
echo set "%1_len=^!n^!">>!FILE_OUTPUT!
set %1_len=defined
set "%1_1=defined"
set %1=defined
exit/b

:def
if !IS_FUNC! == false call :error "def can only be used in functions" & exit/b
for %%a in (%*) do set %%a=defined
exit/b

:array
set ARRAY_NAME=
set ARRAY_DATA=
set SYS_COUNT=-1
for %%a in (%*) do (
  set/a SYS_COUNT+=1
  if !SYS_COUNT! == 0 (set ARRAY_NAME=%%a) else (
    call :datatype %%a
    if !DATA_OP! == true (
      echo call :PROGRAM_DATA "!DATATYPE_RETURN!">>!FILE_OUTPUT!
      echo set !ARRAY_NAME!_!SYS_COUNT!=^^!DATA^^!>>!FILE_OUTPUT!
    ) else echo set !ARRAY_NAME!_!SYS_COUNT!=!DATATYPE_RETURN!>>!FILE_OUTPUT!
    set !ARRAY_NAME!_!SYS_COUNT!=defined
    set ARRAY_DATA=!ARRAY_DATA!"!DATATYPE_RETURN!" 
  )
)
if not defined ARRAY_NAME call :error "no argument specified" & exit/b
if !SYS_COUNT! neq 0 echo set !ARRAY_NAME!=!ARRAY_DATA:~0,-1!>>!FILE_OUTPUT!
echo set !ARRAY_NAME!_len=!SYS_COUNT!>>!FILE_OUTPUT!
set !ARRAY_NAME!=defined
set !ARRAY_NAME!_len=defined
exit/b

:append
if !IS_FUNC! == false if not defined %1_len call :error "'%1' is not an array" & exit/b
set APPEND_TEMP=
set "n=0" & for %%a in (%*) do (
  set/a "n+=1" & if !n! neq 1 (
    call :datatype %%a
    set APPEND_TEMP=!APPEND_TEMP! !DATATYPE_RETURN!
  )
)
(
  echo set %1_temp=
  echo set "n=^!%1_len^!" ^& for %%%%a in ^(!APPEND_TEMP!^) do ^(
  echo   set/a n+=1
  echo   set %1_^^!n^^!=%%%%a
  echo   set %1_temp=^^!%1_temp^^!"%%%%a" 
  echo ^)
  echo if defined %1_temp set "%1_temp=^!%1_temp:~0,-1^!"
  echo set %1=^^!%1^^! ^^!%1_temp^^!
  echo set %1_len=^^!n^^!
) >>!FILE_OUTPUT!
exit/b

:split
call :datatypes %1
if not defined !DATATYPE_RETURN! call :error "invalid variable or array '%1'" & exit/b
(
echo set "temp_%1=" ^& set "n=0" ^& for %%%%a in ^(^^!%1^^!^) do ^(
echo set/a "n+=1" ^& set %1_^^!n^^!=%%%%a
echo set temp_%1=^^!temp_%1^^!"%%%%a" 
echo ^)
echo set "%1=^!temp_%1:~0,-1^!"
echo set %1_len=^^!n^^!
) >>!FILE_OUTPUT!
set %1_len=defined
set %1_n=defined
exit/b

:join
if !IS_FUNC! == false if not defined %1_len call :error "'%1' is not an array"
set joinwith=
if "%2" == "with" (
  if "%~3" == "" call :error "missing argument" & exit/b
  call :datatype %3
  set "joinwith=!DATATYPE_RETURN!"
)
(
echo set %1=
echo for /l %%%%a in ^(1,1,^^!%1_len^^!^) do ^(
echo   if %%%%a == 1 ^(set %1=^^!%1^^!^^!%1_%%%%a^^!
echo   ^) else set %1=^^!%1^^!!joinwith!^^!%1_%%%%a^^!
echo ^)
echo set %1_len=
) >>!FILE_OUTPUT!
set %1_len=
exit/b

:pop
if !IS_FUNC! == false if not defined %1_len call :error "'%1' is not an array"
(
echo set %1=
echo set SYS_COUNT=0
echo for /l %%%%a in ^(1,1,^^!%1_len^^!^) do if %%%%a neq 1 ^(
echo   set/a SYS_COUNT+=1
echo   set %1_^^!SYS_COUNT^^!=^^!%1_%%%%a^^!
echo   set %1=^^!%1^^!"^!%1_%%%%a^!" 
echo ^)
echo set/a %1_len-=1
) >>!FILE_OUTPUT!
exit/b

:replace
call :datatypes %1
if not defined DATATYPE_RETURN call :error "invalid variable or array '%1'" & exit/b
set data1=
set data2=
set REP_OP=
set SYS_COUNT=0
for %%a in (%*) do (
  set/a SYS_COUNT+=1
  if !SYS_COUNT! neq 1 (
    if defined REP_OP (set data2=!data2! %%a) else (
      if %%a == with set REP_OP=%%a
      if not defined REP_OP set data1=!data1! %%a
    )
  )
)
if not defined data1 call :error "not enough argument"
if not defined REP_OP call :error "missing 'with' keyword"
echo rem !SYS_CALL!>>!FILE_OUTPUT!
if defined %1_len (
  rem call :set !data1! !data2!
  call :datatype !data1!
  echo set "data1=!DATATYPE_RETURN!">>!FILE_OUTPUT!
  call :datatype !data2!
  echo set "data2=!DATATYPE_RETURN!">>!FILE_OUTPUT!
  (
    echo set %1=
    echo for /l %%%%a in ^(1,1,^^!%1_len^^!^) do ^(
    echo   if "^!%1_%%%%a^!" == "^!data1^!" set %1_%%%%a=^^!data2^^!
    echo   set %1=^^!%1^^!"^!%1_%%%%a^!" 
    echo ^)
  ) >>!FILE_OUTPUT!
) else (
  call :datatype !data1!
  (
    if !DATA_OP! == true (
      echo|set/p="call :PROGRAM_DATA !DATATYPE_RETURN! & set ^"DATA1=^^!DATA^^!^""
    ) else echo|set/p="set ^"DATA1=!DATATYPE_RETURN!^""
  ) >>!FILE_OUTPUT!
  call :datatype !data2!
  (
    if !DATA_OP! == true (
      echo|set/p="& call :PROGRAM_DATA !DATATYPE_RETURN! & set ^"DATA2=^^!DATA^^!^""
    ) else echo|set/p="& set ^"DATA2=!DATATYPE_RETURN!^""
    echo|set/p="& for %%%%a in ("^^!DATA1^^!") do for %%%%b in ("^^!DATA2^^!") do set %1=^!%1:%%%%~a=%%%%~b^!"
    echo.
  ) >>!FILE_OUTPUT!
)
exit/b

:func
set SYS_COUNT=0
set FUNC_ARGS=
for %%a in (%*) do (
  if !SYS_COUNT! == 0 (
    set FUNC_NAME=%%a
    echo :%%a>>!FILE_OUTPUT!
  ) else (
    if %%a neq %%~a call :error "function argument cannot be string type" & exit/b
    echo set %%a=%%~!SYS_COUNT!>>!FILE_OUTPUT!
    set FUNC_ARGS=!FUNC_ARGS! %%a
    set %%a=defined
  )
  set/a SYS_COUNT+=1
)
echo set PROGRAM_EXIT=false>>!FILE_OUTPUT!
if !START_MAIN! == true call :error "functions must be declared at the top of the program"
for %%a in (!SYS_STACK!) do if %%a == FUNC call :error "functions cannot be declared inside another function"
for %%a in (!SYS_COMMAND! !FUNC_COMMAND!) do if %%a == !FUNC_NAME! call :error "similar function exist"
set FUNC_COMMAND=!FUNC_COMMAND! !FUNC_NAME!
set/a !FUNC_NAME!_ARGC=!SYS_COUNT!-1
set SYS_STACK=FUNC !SYS_STACK!
set IS_FUNC=true
set/a BRACKET_COUNT+=1
exit/b

:loop
set LOOP_VARNAME=
set LOOP_COUNT=
for %%a in (%*) do if not defined LOOP_VARNAME (set LOOP_VARNAME=%%a) else set LOOP_COUNT=!LOOP_COUNT!%%a 
call :ischar !LOOP_VARNAME!
if !ISCHAR_RETURN! == false call :error "variable name must be character type"
call :datatype !LOOP_COUNT!
call :ischar !DATATYPE_RETURN!
rem if !ISCHAR_RETURN! == true call :warning "'!LOOP_COUNT!' is expected to return number"
(
  if !DATA_OP! == true (
    echo|set/p="call :PROGRAM_DATA !DATATYPE_RETURN! &"
    set DATATYPE_RETURN=^^!DATA^^!
  )
  echo for /l %%%%i in ^(1,1,!DATATYPE_RETURN!^) do ^(
  echo set !LOOP_VARNAME!=%%%%i
) >>!FILE_OUTPUT!
set !LOOP_VARNAME!=defined
set/a BRACKET_COUNT+=1
set SYS_STACK=LOOP !SYS_STACK!
exit/b

:if
call :booltype %*
(
  if !COND_OP! == in (
    echo|set/p="& for %%%%a in (^!DATA1^!) do if "^^!DATA2^^!" neq "^^!DATA2:%%%%a=^^!" ^("
    echo.
  ) else if !COND_OP! == exist#c5 (
    echo ^& if exist "^!DATA1^!" ^(
  ) else if !COND_OP! == defined#c5 (
    echo ^& if defined !DATA1! ^(
  ) else echo ^& if ^^!DATA1^^! !COND_OP! ^^!DATA2^^! ^(
) >>!FILE_OUTPUT!
set SYS_STACK=IF !SYS_STACK!
set/a BRACKET_COUNT+=1
exit/b

:ifnot
call :booltype %*
(
  if !COND_OP! == in (
    echo|set/p="& for %%%%a in (^!DATA1^!) do if not "^^!DATA2^^!" neq "^^!DATA2:%%%%a=^^!" ^("
    echo.
  ) else if !COND_OP! == exist#c5 (
    echo ^& if not exist "^!DATA1^!" ^(
  ) else if !COND_OP! == defined#c5 (
    echo ^& if not defined !DATA1! ^(
  ) else echo ^& if not ^^!DATA1^^! !COND_OP! ^^!DATA2^^! ^(
) >>!FILE_OUTPUT!
set SYS_STACK=IF !SYS_STACK!
set/a BRACKET_COUNT+=1
exit/b

:while
set/a BRACKET_COUNT+=1
set/a WHILE_ID+=1
set SYS_STACK=WHILE_!WHILE_ID! !SYS_STACK!
echo :WHILE_!WHILE_ID!>>!FILE_OUTPUT!
call :booltype %*
for %%a in (!COND_OP!) do if "!SYS_CONDITION_EXT!" neq "!SYS_CONDITION_EXT:%%a =!" call :error "Invalid keyword '%%a'" & exit/b
(
  if !COND_OP! == in (
    echo|set/p="& for %%%%a in (^!DATA1^!) do if not "^^!DATA2^^!" neq "^^!DATA2:%%%%a=^^!" goto END_WHILE_!WHILE_ID!"
    echo.
  ) else echo ^& if not ^^!DATA1^^! !COND_OP! ^^!DATA2^^! goto END_WHILE_!WHILE_ID!
) >>!FILE_OUTPUT!
exit/b

:break
rem TODO: implement break for 'loop'
set ISBREAK=false
for %%a in (!SYS_STACK!) do set BREAK_TEMP=%%a& if "!BREAK_TEMP:~0,5!" == "WHILE" if !ISBREAK! == false (
  echo goto :END_%%a>>!FILE_OUTPUT!
  set ISBREAK=true
)
if !ISBREAK! == false call :error "no 'while' to assign to"
exit/b

:else
set ELSE_TEMP=%*
set ELSE_BOOL=false& for %%a in (!SYS_STACK!) do if %%a == IF set ELSE_BOOL=true
if !ELSE_BOOL! == false call :error "no if statement declared"
if not defined ELSE_TEMP (echo ^) else ^(>>!FILE_OUTPUT!) else (
  echo|set/p=") else ">>!FILE_OUTPUT!
  set TEMP_STACK=
  set SYS_COUNT=0
  for %%a in (!SYS_STACK!) do set/a SYS_COUNT+=1& if !SYS_COUNT! neq 1 set TEMP_STACK=!TEMP_STACK! %%a
  set SYS_STACK=!TEMP_STACK!
  set/a BRACKET_COUNT-=1
  call :sys %*
)
exit/b

:end
if "%1" neq "" call :error "unexpected argument"
set TEMP_STACK=
set SYS_COUNT=0
for %%a in (!SYS_STACK!) do (
  set END_TEMP=%%a
  set/a SYS_COUNT+=1
  if !SYS_COUNT! == 1 (
    if %%a == FUNC (
      for %%b in (!FUNC_ARGS!) do set %%b=
      echo exit/b>>!FILE_OUTPUT!
      set IS_FUNC=false
    ) else if "!END_TEMP:~0,5!" == "WHILE" (
      (
      echo goto :!END_TEMP!
      echo :END_!END_TEMP!
      ) >>!FILE_OUTPUT!
    ) else echo ^)>>!FILE_OUTPUT!
  ) else set TEMP_STACK=!TEMP_STACK! %%a
)
if !SYS_COUNT! neq 0 (
  set SYS_STACK=!TEMP_STACK!
  set/a BRACKET_COUNT-=1
) else call :error "nothing to end"
exit/b

:file
set SYS_COUNT=0
for %%a in (%*) do set/a SYS_COUNT+=1
if !SYS_COUNT! == 0 call :error "no file-path argument" & exit/b
if !SYS_COUNT! neq 1 call :error "expected one file-path argument, got !SYS_COUNT!" & exit/b
call :datatype %*
set FILE_OP=!DATATYPE_RETURN!
exit/b

:clear
echo cls>>!FILE_OUTPUT!
exit/b

:quit
if !IS_FUNC! == true (echo set PROGRAM_EXIT=true) >>!FILE_OUTPUT!
echo exit/b>>!FILE_OUTPUT!
exit/b

:datatype
set TYPE_RET=
set DATA_OP=false
set DATATYPE_RETURN=
for %%a in (%*) do (
  if "%%a" == "%%~a" (
    set "DATATYPE_TEMP="&for /f "delims=0123456789.+-/" %%i in ("%%a") do set "DATATYPE_TEMP=%%i"
    if defined DATATYPE_TEMP (
      if defined %%a (set DATATYPE_RETURN=!DATATYPE_RETURN!^^!%%a^^!) else (
        set "DATATYPE_TEMP=%%a"
        if "!DATATYPE_TEMP:_= !" neq "%%a" (call :arraytype !DATATYPE_TEMP:_= !
        ) else if "!DATATYPE_TEMP::= !" neq "%%a" call :indextype !DATATYPE_TEMP::= !
        if defined TYPE_RET (set DATATYPE_RETURN=!DATATYPE_RETURN!!TYPE_RET!) else (
          if !IS_FUNC! == true (
            set DATATYPE_RETURN=!DATATYPE_RETURN!^^!%%a^^!
            call :warning "unknown variable '%%a'"
          ) else call :error "undefined variable '%%a'"
        )
      )
    ) else (
      set "temp="&for /f "delims=+-/" %%i in ("%~1") do set "temp=%%i"
      if not "%%a" == "!temp!" set DATA_OP=true
      set DATATYPE_RETURN=!DATATYPE_RETURN!%%a
    )
  ) else set DATATYPE_RETURN=!DATATYPE_RETURN!%%~a
)
rem if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#1#=^^!!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c1=^(!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c2=^)!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c3=^&!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c4=%%%%!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c5=?!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c6=^>!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c7=^<!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c8=^|!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c9=^^!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#d1="!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#d2=,!"
exit/b

:datatypes
set TYPE_RET=
set DATA_OP=false
set FROM_SET=true
set DATATYPE_RETURN=
for %%a in (%*) do (
  if "%%a" == "%%~a" (
    set "DATATYPE_TEMP="&for /f "delims=0123456789.+-/" %%i in ("%%a") do set "DATATYPE_TEMP=%%i"
    if defined DATATYPE_TEMP (
      if defined %%a (set DATATYPE_RETURN=!DATATYPE_RETURN!%%a) else (
        set "DATATYPE_TEMP=%%a"
        if "!DATATYPE_TEMP:_= !" neq "%%a" (call :arraytype !DATATYPE_TEMP:_= !
        ) else if "!DATATYPE_TEMP::= !" neq "%%a" call :indextype !DATATYPE_TEMP::= !
        if defined TYPE_RET (set DATATYPE_RETURN=!DATATYPE_RETURN!!TYPE_RET!) else (
          if !IS_FUNC! == true (
            set DATATYPE_RETURN=!DATATYPE_RETURN!%%a
            call :warning "unknown variable '%%a'"
          ) else call :error "undefined variable '%%a'"
        )
      )
    ) else (
      set "temp="&for /f "delims=+-/" %%i in ("%~1") do set "temp=%%i"
      if not "%%a" == "!temp!" set DATA_OP=true
      set DATATYPE_RETURN=!DATATYPE_RETURN!%%a
    )
  ) else set DATATYPE_RETURN=!DATATYPE_RETURN!%%~a
)
rem if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#1#=^^!!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c1=^(!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c2=^)!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c3=^&!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c4=%%%%!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c5=?!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c6=^>!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c7=^<!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c8=^|!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c9=^^!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#d1="!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#d2=,!"
set FROM_SET=
exit/b

:datatypef
set TYPE_RET=
set DATATYPE_RETURN=
for %%a in (%*) do (
  if "%%a" == "%%~a" (
    set "DATATYPE_TEMP="&for /f "delims=0123456789.+-/" %%i in ("%%a") do set "DATATYPE_TEMP=%%i"
    if defined DATATYPE_TEMP (
      if defined %%a (set DATATYPE_RETURN=!DATATYPE_RETURN! "^!%%a^!") else (
        set "DATATYPE_TEMP=%%a"
        if "!DATATYPE_TEMP:_= !" neq "%%a" (call :arraytype !DATATYPE_TEMP:_= !
        ) else if "!DATATYPE_TEMP::= !" neq "%%a" call :indextype !DATATYPE_TEMP::= !
        if defined TYPE_RET (set DATATYPE_RETURN=!DATATYPE_RETURN! "!TYPE_RET!") else (
          if !IS_FUNC! == true (
            set DATATYPE_RETURN=!DATATYPE_RETURN! "^!%%a^!"
            call :warning "unknown variable '%%a'"
          ) else call :error "undefined variable '%%a'"
        )
      )
    ) else (
      set "temp="&for /f "delims=+-/" %%i in ("%~1") do set "temp=%%i"
      if not "%%a" == "!temp!" set DATA_OP=true
      set DATATYPE_RETURN=!DATATYPE_RETURN! "%%~a"
    )
  ) else set DATATYPE_RETURN=!DATATYPE_RETURN! "%%~a"
)
rem if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#1#=^^!!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c1=^(!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c2=^)!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c3=^&!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c4=%%%%!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c5=?!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c6=^>!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c7=^<!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c8=^|!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#c9=^^!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#d1="!"
if defined DATATYPE_RETURN set "DATATYPE_RETURN=!DATATYPE_RETURN:#d2=,!"
exit/b

:booltype
set data1=
set data2=
set COND_OP=
for %%a in (%*) do (
  if defined COND_OP (set data2=!data2! %%a) else (
    for %%b in (!SYS_CONDITION! !SYS_CONDITION_EXT!) do (if %%a == %%b set COND_OP=%%a)
    if not defined COND_OP set data1=!data1! %%a
  )
)
if not defined data1 call :error "not enough argument"
if not defined COND_OP call :error "Invalid comparison"
rem if not defined data2 call :error "not enough argument"
call :datatype !data1!
(
  if !DATA_OP! == true (
    echo|set/p="call :PROGRAM_DATA !DATATYPE_RETURN! & set ^"DATA1=^^!DATA^^!^""
  ) else echo|set/p="set ^"DATA1=!DATATYPE_RETURN!^""
) >>!FILE_OUTPUT!
call :datatype !data2!
(
  if !DATA_OP! == true (
    echo|set/p="& call :PROGRAM_DATA !DATATYPE_RETURN! & set ^"DATA2=^^!DATA^^!^""
  ) else echo|set/p="& set ^"DATA2=!DATATYPE_RETURN!^""
) >>!FILE_OUTPUT!
exit/b

:arraytype
call :datatype
set TYPE_RET=
if !IS_FUNC! == false if not defined %1_len exit/b
if "%2" equ "len" (
  if !FROM_SET! == true (set TYPE_RET=%1_len) else (set TYPE_RET=^^!%1_len^^!)
) else (
  call :ischar %2
  if !ISCHAR_RETURN! == true (
    if !IS_FUNC! == false if not defined %2 exit/b
    for %%a in (!TEMPCHARIND!) do (
      if !FROM_SET! == true (
        set TYPE_RET=%1_%%%%!SYS_TEMPVARCHAR:~%%a,1!
      ) else set TYPE_RET=^^!%1_%%%%!SYS_TEMPVARCHAR:~%%a,1!^^!
      echo|set/p="for %%%%!SYS_TEMPVARCHAR:~%%a,1! in (^!%2^!) do ">>!FILE_OUTPUT!
    )
    set/a TEMPCHARIND+=1
  ) else if "%2" neq "" set TYPE_RET=^^!%1_%2^^!
)
exit/b

:indextype
if not defined %1 exit/b
set "INDEXTYPE_TEMP=%*" & set "INDEXTYPE_TEMP=!INDEXTYPE_TEMP:#d2= !"
set SYS_COUNT=0
set INDTEMP=
set INDVAL=
for %%a in (!INDEXTYPE_TEMP!) do (
  if not defined INDTEMP (set INDTEMP=%%a) else (
    set/a SYS_COUNT+=1
    call :ischar %%a & if !ISCHAR_RETURN! == true (
      if defined %%a (
        for %%b in (!TEMPCHARIND!) do (
          echo|set/p="for %%%%!SYS_TEMPVARCHAR:~%%b,1! in (^!%%a^!) do ">>!FILE_OUTPUT!
          set INDVAL=!INDVAL!%%%%!SYS_TEMPVARCHAR:~%%b,1!,
          set/a TEMPCHARIND+=1
        )
      ) else if !IS_FUNC! == true (
        for %%b in (!TEMPCHARIND!) do (
          echo|set/p="for %%%%!SYS_TEMPVARCHAR:~%%b,1! in (^!%%a^!) do ">>!FILE_OUTPUT!
          set INDVAL=!INDVAL!%%%%!SYS_TEMPVARCHAR:~%%b,1!,
          set/a TEMPCHARIND+=1
        )
      ) else call :error "undefined variable '%%a'"
    ) else set INDVAL=!INDVAL!%%a,
  )
)
if !SYS_COUNT! neq 0 if !SYS_COUNT! leq 2 set "TYPE_RET=^!!INDTEMP!:~!INDVAL:~0,-1!^!"
exit/b

:ischar
SET "ISCHAR_TEMP="&for /f "delims=0123456789.+-/" %%i in ("%*") do set ISCHAR_TEMP=%%i
if defined ISCHAR_TEMP (set ISCHAR_RETURN=true) else (set ISCHAR_RETURN=false)
exit/b

:error
set/a ERROR_COUNT+=1
set ERROR_MSG=%~1
rem if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#1#=^^!!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c1=^(!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c2=^)!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c3=^&!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c4=%%%%!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c5=?!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c6=^>!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c7=^<!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c8=^|!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c9=^^!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#d1="!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#d2=,!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#d3="!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c1=^(!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c2=^)!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c3=^&!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c4=%%%%!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c5=?!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c6=^>!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c7=^<!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c8=^|!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c9=^^!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#d1="!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#d2=,!"
echo   !FILE_INPUT!:!SYS_LINE!: !SYS_CALL! --^> ERROR: !ERROR_MSG!
set ERROR_RETURN=true
exit/b

:warning
set ERROR_MSG=%~1
rem if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#1#=^^!!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c1=^(!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c2=^)!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c3=^&!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c4=%%%%!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c5=?!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c6=^>!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c7=^<!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c8=^|!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#c9=^^!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#d1="!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#d2=,!"
if defined SYS_CALL set "SYS_CALL=!SYS_CALL:#d3="!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c1=^(!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c2=^)!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c3=^&!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c4=%%%%!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c5=?!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c6=^>!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c7=^<!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c8=^|!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#c9=^^!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#d1="!"
if defined ERROR_MSG set "ERROR_MSG=!ERROR_MSG:#d2=,!"
echo   !FILE_INPUT!:!SYS_LINE!: !SYS_CALL! --^> WARNING: !ERROR_MSG!
exit/b

:timed
set "time1=%~1" & set "time1=!time1::= !" & set "time1=!time1:.= !"
set "time2=%~2" & set "time2=!time2::= !" & set "time2=!time2:.= !"
set "cc=0" & for %%a in (!time1!) do (
  set/a cc+=1
  if !cc! == 1 set h1=%%a
  if !cc! == 2 set m1=%%a
  if !cc! == 3 set s1=%%a
  if !cc! == 4 set ms1=%%a
)
set "cc=0" & for %%a in (!time2!) do (
  set/a cc+=1
  if !cc! == 1 set h2=%%a
  if !cc! == 2 set m2=%%a
  if !cc! == 3 set s2=%%a
  if !cc! == 4 set ms2=%%a
)
set/a h=(h2-h1)*360000
set/a m=(m2-m1)*6000
set/a s=(s2-s1)*100
set/a ms=ms2-ms1
set/a TIMED_RETURN=!h!+!m!+!s!+!ms!
if "!TIMED_RETURN:~1,1!" == "" set TIMED_RETURN=00!TIMED_RETURN!
if "!TIMED_RETURN:~2,1!" == "" set TIMED_RETURN=0!TIMED_RETURN!
set "TIMED_RETURN=!TIMED_RETURN:~0,-2!.!TIMED_RETURN:~-2!s"
exit/b

:usage
echo Usage: box ^<option^> ^<file-path^>
echo.
echo ^<option^>
echo     -c    compilation mode
echo     -r    compilation mode + run
echo     -e    quickly write and compile program
echo     -t    compile specified folder and check
echo     -u    update specified testcase output
echo     -h    show this message
echo.
for /l %%a in (1,1,3) do echo|set/p="." & (timeout 1 /nobreak >nul)
echo.
exit/b

:tests
if "%~2" == "" echo usage: %~n0 -t folder & exit/b
if not exist "%~2" echo ERROR: could not find the folder '%~2' & exit/b
for %%a in (%~2\*.box) do @(
  box -c %%a %~2\out.bat
  %~2\out>%~2\out.txt
  if not exist %~2\%%~na.txt echo ERROR: update the output first using -u command & exit/b
  fc %~2\out.txt %~2\%%~na.txt>nul
  if errorlevel 1 fc %~2\out.txt %~2\%%~na.txt
)
rem TODO: del does not work here
del "%~2\out.bat" "%~2\out.txt"
exit/b

:update
if "%~2" == "" echo usage: %n0 -u folder & exit/b
if not exist "%~2" echo ERROR: could not find the folder '%~2' & exit/b
for %%a in (%~2\*.box) do @(
  box -c %%a %~2\out.bat
  %~2\out>%~2\%%~na.txt
)
rem TODO: del does not work here
del "%~2\out.bat" "%~2\out.txt"
exit/b

:editor
echo Editor mode (press ctrl+z and enter when done)
echo.
copy con .boxtemp >nul
echo.
set FILE_INPUT=.boxtemp
set FILE_OUTPUT=out.bat
set COMPILER_OP=run
call :main
del .boxtemp
exit/b
