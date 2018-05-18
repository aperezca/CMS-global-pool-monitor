#------------------------------------------
# A detailed view of currently running pilot pools:
#------------------------------------------

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

collector=$($WORKDIR/collector.sh)
collector_t0=$($WORKDIR/collector_t0.sh)

date_s=`date -u +%s`
condor_status -pool $collector -af GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType State Activity TotalSlotCPUs TotalSlotMemory CPUs Memory TotalIOslots TotalRepackSlots IOslots RepackSlots MonitorSelfAge/3600 GLIDEIN_ToRetire/3600-$date_s/3600 GLIDEIN_ToDie/3600-$date_s/3600 | sort > $WORKDIR/status/Global_pool/all_slots_status.txt

date_s=`date -u +%s`
condor_status -pool $collector_t0 -af GLIDEIN_CMSSite GLIDEIN_Entry_Name SlotType State Activity TotalSlotCPUs TotalSlotMemory CPUs Memory TotalIOslots TotalRepackSlots IOslots RepackSlots MonitorSelfAge/3600 GLIDEIN_ToRetire/3600-$date_s/3600 GLIDEIN_ToDie/3600-$date_s/3600 | sort > $WORKDIR/status/CERN_pool/all_slots_status.txt

