@echo off
setlocal EnableDelayedExpansion
set "argv=%*" & set "n=0" & for %%a in (!argv!) do set/a n+=1
set "argc=!n!"
set SYS_CHAR=/abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789

set char_33=^^!
set char_34="
set char_35=#
set char_36=$
set char_37=%%
set char_38=^&
set char_39='
set char_40=^(
set char_41=^)
set char_42=^*
set char_43=+
set char_44=,
set char_45=-
set char_46=.
set char_47=/
set char_48=0
set char_49=1
set char_50=2
set char_51=3
set char_52=4
set char_53=5
set char_54=6
set char_55=7
set char_56=8
set char_57=9
set char_58=:
set char_59=;
set "char_60=^<"
set char_61=/=
set "char_62=^>"
set char_63=?
set char_64=@
set char_65=A
set char_66=B
set char_67=C
set char_68=D
set char_69=E
set char_70=F
set char_71=G
set char_72=H
set char_73=I
set char_74=J
set char_75=K
set char_76=L
set char_77=M
set char_78=N
set char_79=O
set char_80=P
set char_81=Q
set char_82=R
set char_83=S
set char_84=T
set char_85=U
set char_86=V
set char_87=W
set char_88=X
set char_89=Y
set char_90=Z
set char_91=[
set char_92=\
set char_93=]
set char_94=^^
set char_95=_
set char_96=`
set char_97=a
set char_98=b
set char_99=c
set char_100=d
set char_101=e
set char_102=f
set char_103=g
set char_104=h
set char_105=i
set char_106=j
set char_107=k
set char_108=l
set char_109=m
set char_110=n
set char_111=o
set char_112=p
set char_113=q
set char_114=r
set char_115=s
set char_116=t
set char_117=u
set char_118=v
set char_119=w
set char_120=x
set char_121=y
set char_122=z
set char_123={
set "char_124=^|"
set char_125=}
set char_126=~

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
:string
set name=%~1
set gender=%~2
set adjective=%~3
set PROGRAM_EXIT=false
set "DATA1=!gender!"& set "DATA2=M"& if !DATA1! equ !DATA2! (
) else set "DATA1=!gender!"& set "DATA2=F"& if !DATA1! equ !DATA2! (
) else exit/b
:PROGRAM_MAIN
set "DATA1="& set "DATA2=M"& if !DATA1! equ !DATA2! (
set x=He
) else set "DATA1="& set "DATA2=F"& if !DATA1! equ !DATA2! (
set "DATA1="& set "DATA2=F"& if !DATA1! equ !DATA2! (
set x=She
) else set x=Someone
set x=Someone
)
call :string  "Ali Gatie" "M" "smart"
if !PROGRAM_EXIT! == true exit/b
set "DATA1="& set "DATA2=M"& if !DATA1! equ !DATA2! (
set x=He
) else set "DATA1="& set "DATA2=F"& if !DATA1! equ !DATA2! (
set "DATA1="& set "DATA2=F"& if !DATA1! equ !DATA2! (
set x=She
) else set x=Someone
set x=Someone
)
call :string  "Andrea Andromeda" "F" "diligent"
if !PROGRAM_EXIT! == true exit/b
set "DATA1="& set "DATA2=M"& if !DATA1! equ !DATA2! (
set x=He
) else set "DATA1="& set "DATA2=F"& if !DATA1! equ !DATA2! (
set "DATA1="& set "DATA2=F"& if !DATA1! equ !DATA2! (
set x=She
) else set x=Someone
set x=Someone
)
call :string  "box-lang" "L" "powerful"
if !PROGRAM_EXIT! == true exit/b
