#!/bin/sh

INCLUDE=/usr/local/include/harbour

rm -f wdo_lib.hrb

harbour wdo_lib.prg -n -w -gh -i"$INCLUDE"
