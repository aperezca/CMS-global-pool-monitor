#!/bin/sh
WORKDIR="/crabprod/CSstoragePath/aperez"

file="$WORKDIR/out/count_All_T1s"

time1="01/01/2016"
time2="04/01/2017"
./get_averages_CHEP.py $file $time1 $time2
