@echo off
@cls
@set    path=../../bin/harbour
@set include=../../bin/harbour/include

del wdo.hrb


@echo =================
@echo Building WDO Lib
@echo =================

rem harbour wdo.prg /n /w /gh /owdo.hrb /dWITH_ADO
harbour wdo_lib.prg /n /w /gh /owdo.hrb



pause

