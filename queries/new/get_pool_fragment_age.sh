#----------------------------------------------
# Current fragmentation of the pool in cores and available time

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

# Format from status: 16 fields
# Site Entry Type State Activity TotalCPU TotalMemory CPU Memory TotalIO TotalRepack IO Repack Age To_retire To_die 

#----------------------------------------------
# Current fragmentation of the pool: only claimed slots
# 2017-09-15 Include the constraint that these are only dynamic slots! 
# Get dynamic claimed slots (may be running or idle!)

date_s=`date -u +%s`

#for pool in "Global_pool" "CERN_pool"; do
for pool in "CERN_pool"; do
	echo $pool
	cat $WORKDIR/status/$pool/all_slots_status.txt |grep Claimed |grep Dynamic > $WORKDIR/status/$pool/all_slots_claimed_dynamic.txt

	for cores in {1..8}; do let slots_fresh_$cores=0; done
	for cores in {1..8}; do let slots_drain_$cores=0; done

	while read -r line; do
		ioslot=$(echo $line |awk '{print $12}')
		repackslot=$(echo $line |awk '{print $13}')
		if [[ $ioslot == "undefined" ]] || [[ $ioslot == "0" ]]; then
			if [ $repackslot == "undefined" ] || [ $repackslot == "0"]; then
				cores=$(echo $line |awk '{print $8}')
                		retire=$(echo $line |awk '{print $15}')
				echo $line
				echo "found one!" $ioslot $repackslot $cores
				if [ $retire>0 ]; then
					let slots_fresh_$cores+=$cores
				else
					let slots_drain_$cores+=$cores
				fi
			fi
		fi
	done<$WORKDIR/status/$pool/all_slots_claimed_dynamic.txt
	
	
	echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8
	echo $date_s $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8

	#echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>$OUTDIR/out/$pool/pool_partition_fresh
	#echo $date_s $slots_drain_1 $slots_drain_2 $slots_drain_3 $slots_drain_4 $slots_drain_5 $slots_drain_6 $slots_drain_7 $slots_drain_8 >>$OUTDIR/out/$pool/pool_partition_drain
done

#for pool in "Global_pool" "CERN_pool"; do
#	cat $WORKDIR/status/$pool/all_slots_status.txt |grep Partitionable > $WORKDIR/status/$pool/all_slots_partitionable.txt
#done

