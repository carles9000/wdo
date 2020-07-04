@echo off
@cls
@set    path=c:\harbour\bin
@set include=c:\harbour\include

del wdo_lib.hrb


@echo =================
@echo Building WDO Lib
@echo =================

rem harbour wdo_lib.prg /n /w /gh /owdo.hrb /dWITH_ADO
harbour wdo_lib.prg /n /w /gh /owdo.hrb

pause

