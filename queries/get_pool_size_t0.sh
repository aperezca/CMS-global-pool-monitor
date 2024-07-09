#!/bin/sh

# Count CPUs for multicore and single core pilots at CMS CERN pool
# Antonio Perez-Calero Yzquierdo Apr. Nov. 2022

source /data/srv/aperezca/Monitoring/env.sh 

now=$(date -u)
OUT=$HTMLDIR"/cernpool_mcore_pilots_info.txt"
condor_status -pool cmsgwms-collector-tier0.cern.ch -const '(SlotType=?="Partitionable")' -af GLIDEIN_CMSSite SlotType TotalSlotCpus-TotalRepackSlots TotalSlotMemory|sort |uniq -c >$WORKDIR/status/all_partitionable_glideins_T0.txt

# -------
echo "## ----------------------------------------------------------------------------" >>$OUT
echo "## INFO ON RUNNING PILOTS FOR CERN POOL UPDATED AT" $now >$OUT
echo "## ----------------------------------------------------------------------------" >>$OUT
echo "## MCORE GLIDEINS: #pilots CMS_Site SlotType TotalSlotCPUs TotalSlotMemory " >>$OUT
echo "## ----------------------------------------------------------------------------" >>$OUT
cat $WORKDIR/status/all_partitionable_glideins_T0.txt                                  >>$OUT
echo "## ----------------------------------------------------------------------------" >>$OUT

