#!/bin/sh
source /etc/profile.d/condor.sh

# A more detailed view of currently running pilot pool:
# Antonio Perez-Calero Yzquierdo May, Nov 2016
# Adapted for the new CERN pool, May 2018

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector_volunteer.sh)

date_s=`date -u +%s`
condor_status -pool $collector -af GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType TotalSlotCPUs CPUs TotalRepackSlots TotalIOSlots RepackSlots IOSlots Memory State Activity | sort |uniq -c >$WORKDIR/status/Volunteer_pool/cores_fresh_glideins.txt

#date_s=`date -u +%s`
#condor_status -pool $collector -const '(GLIDEIN_ToRetire-'${date_s}'<0)' -af GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType TotalSlotCPUs CPUs TotalRepackSlots TotalIOSlots RepackSlots IOSlots Memory State Activity | sort |uniq -c >$WORKDIR/status/Volunteer_pool/cores_retiring_glideins.txt

#----------------
size_part=0
size_stat=0
while read -r line; do
        if [[ $(echo $line |grep Static) != "" ]]; then let size_stat+=$(echo $line | awk '{print $1*$5}'); fi
        if [[ $(echo $line |grep Partitionable) != "" ]]; then let size_part+=$(echo $line | awk '{print $1*$5}'); fi
done<$WORKDIR/status/Volunteer_pool/cores_fresh_glideins.txt

date_all=`date -u +%s`
echo $date_all $size_part $size_stat >>$OUTDIR/out/Volunteer/pool_size
#----------------

now=$(date -u)
echo "## -------------------------------------------------------------------------"  >$OUTDIR/HTML/volunteer_pool_pilot_info.txt
echo "## INFO ON CMS VOLUNTEER (CMS@Home) POOL PILOTS UPDATED AT" $now              >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
echo "## FRESH GLIDEINS: #_slots GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType TotalSlotCPUs CPUs TotalRepackSlots TotalIOSlots RepackSlots IOSlots Memory State Activity">>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
cat $WORKDIR/status/Volunteer_pool/cores_fresh_glideins.txt                              >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
echo "## RETIRING GLIDEINS: #_slots GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType TotalSlotCPUs CPUs TotalRepackSlots TotalIOSlots RepackSlots IOSlots Memory State Activity" >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
cat $WORKDIR/status/Volunteer_pool/cores_retiring_glideins.txt                                     >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt
echo "## -------------------------------------------------------------------------" >>$OUTDIR/HTML/volunteer_pool_pilot_info.txt

#----------------------------------------------
# Current fragmentation of the pool: only claimed slots
# Get dynamic claimed slots (may be running or idle!)
cat $WORKDIR/status/Volunteer_pool/cores_fresh_glideins.txt |grep -v Partitionable > $WORKDIR/status/Volunteer_pool/claimed_glideins.txt
cat $WORKDIR/status/Volunteer_pool/cores_retiring_glideins.txt |grep -v Partitionable >> $WORKDIR/status/Volunteer_pool/claimed_glideins.txt

dyn_slots=0
for cores in {1..8}; do let slots_fresh_$cores=0; done
while read -r line; do
	let dyn_slots+=$(echo $line |awk '{print $1}')
	cores=$(echo $line |awk '{print $5}')
	let slots_fresh_$cores+=$(echo $line |awk '{print $1*$5}')
done<$WORKDIR/status/Volunteer_pool/claimed_glideins.txt

#echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8
echo $date_s $slots_fresh_1 $slots_fresh_2 $slots_fresh_3 $slots_fresh_4 $slots_fresh_5 $slots_fresh_6 $slots_fresh_7 $slots_fresh_8 >>$OUTDIR/out/Volunteer/pool_partition_fresh

# Count number of dyn slots in the pool
echo $date_s $dyn_slots >>$OUTDIR/out/Volunteer/pool_dynslots

