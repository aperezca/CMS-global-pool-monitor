#!/bin/bash

for i in `cat all_T2T3s`; do
	#echo $i
	if [ -a /crabprod/CSstoragePath/aperez/out/jobs_running_$i ]; then
		result=$(tail -n 10000 /crabprod/CSstoragePath/aperez/out/jobs_running_$i |grep -v '0 0 0' | awk '{ sum_prod+=$2; sum_crab+=$3; n++ } END {if(n>0){print(sum_prod/n, sum_crab/n, n)}; if(n==0){print(0, 0, 0)}}')
		echo $i $result
	else
		echo $i "file not found!!!"
	fi
done

