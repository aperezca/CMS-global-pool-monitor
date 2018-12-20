#!/bin/sh

for timestamp in `cat /crabprod/CSstoragePath/aperez/out/timestamps`; do
	#echo $timestamp
	T0_prod=$(cat /crabprod/CSstoragePath/aperez/out/jobs_running_T0_CH_CERN| grep $timestamp| awk '{print $2}')
	T0_crab=$(cat /crabprod/CSstoragePath/aperez/out/jobs_running_T0_CH_CERN| grep $timestamp| awk '{print $3}')
	T1_prod=$(cat /crabprod/CSstoragePath/aperez/out/jobs_running_AllT1s| grep $timestamp| awk '{print $2}')
	T1_crab=$(cat /crabprod/CSstoragePath/aperez/out/jobs_running_AllT1s| grep $timestamp| awk '{print $3}')
	T2_prod=$(cat /crabprod/CSstoragePath/aperez/out/jobs_running_AllT2s| grep $timestamp| awk '{print $2}')
	T2_crab=$(cat /crabprod/CSstoragePath/aperez/out/jobs_running_AllT2s| grep $timestamp| awk '{print $3}')
	#echo $timestamp $T0_prod $T0_crab $T1_prod $T1_crab $T2_prod $T2_crab
	echo $timestamp $T0_prod $T0_crab $T1_prod $T1_crab $T2_prod $T2_crab >>/crabprod/CSstoragePath/aperez/out/jobs_running_T0AndGlobalPool_TMP
done
