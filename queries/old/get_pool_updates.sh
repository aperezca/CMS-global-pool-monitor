#!/bin/sh
source /etc/profile.d/condor.sh

# Analyse pilots entering and leaving the CMS global pool as a function of time
# Antonio Perez-Calero Yzquierdo Feb. 2017

collector=$(/home/aperez/collector.sh)
OUT="/home/aperez/status/"
date_s=`date -u +%s`
condor_status -pool $collector -const '(SlotType=="Partitionable")' -af GLIDEIN_CMSSite Name SlotType TotalSlotCPus |sort > $OUT/partitionable_glideins_now.txt

#look for changes in the global pool:
diff $OUT/partitionable_glideins_previous.txt $OUT/partitionable_glideins_now.txt >$OUT/partitionable_glideins_diff

pool_out_total=0
pool_in_total=0
for list in T1 T2; do
	#echo $list
	for site in `cat "/home/aperez/entries/"$list"_sites"`; do
		#echo $site
		pool_out=0
		pool_in=0
		cat $OUT/partitionable_glideins_diff |grep $site >$OUT/partitionable_glideins_diff_$site
		while read -r line; do
			#old pilots leaving the pool
			if [ $(echo $line |awk '{print $1}') == "<" ]; then let pool_out+=$(echo $line|awk '{print $5}'); fi
			#new pilots entering the pool
			if [ $(echo $line |awk '{print $1}') == ">" ]; then let pool_in+=$(echo $line|awk '{print $5}'); fi
		done<$OUT/partitionable_glideins_diff_$site
		echo $date_s $pool_out $pool_in >>/crabprod/CSstoragePath/aperez/out/pool_diff_$site
		rm $OUT/partitionable_glideins_diff_$site
		let pool_out_total+=$pool_out
		let pool_in_total+=$pool_in
	done
done
echo $date_s $pool_out_total $pool_in_total >>/crabprod/CSstoragePath/aperez/out/pool_diff_total

#only keep track of the last update:
mv $OUT/partitionable_glideins_now.txt $OUT/partitionable_glideins_previous.txt

