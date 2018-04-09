#!/bin/sh
source /etc/profile.d/condor.sh

# Check dropped schedds in the nego cycle at CMS global pool
# Antonio Perez-Calero Yzquierdo Nov. 2017

collector=$(/home/aperez/collector.sh)
collector_t0=$(/home/aperez/collector_t0.sh)
date_s=$(date -u +%s) 

schedds=$(condor_status -pool $collector -nego -af LastNegotiationCycleScheddsOutOfTime0)
schedds_t0=$(condor_status -pool $collector_t0 -nego -af LastNegotiationCycleScheddsOutOfTime0)

echo $schedds
echo $schedds_t0

echo $date_s $schedds $schedds_t0 >>/crabprod/CSstoragePath/aperez/out/schedds_out_time

# Get list for the last 4h and 24h (6 lines per hour, e.g. 6 * 24 = 144)
OUTDIR="/crabprod/CSstoragePath/aperez/HTML"
now=$(date -u)
echo "## INFO ON DROPPED SCHEDDS IN CMS GLOBAL AND T0 POOLS UPDATED AT" $now >$OUTDIR/globalpool_schedds_new.txt
echo "## --------------------------------------------------------------------------" >>$OUTDIR/globalpool_schedds_new.txt
echo "">>$OUTDIR/globalpool_schedds_new.txt

echo "## --------------------------------- LAST 1h --------------------------------" >>$OUTDIR/globalpool_schedds_new.txt
for i in `tail /crabprod/CSstoragePath/aperez/out/schedds_out_time -n 6 |awk '{$1=""; print $0}'`; do
        echo $i |awk -F"," '{print $1}';
done |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_schedds_new.txt
echo "">>$OUTDIR/globalpool_schedds_new.txt

echo "## --------------------------------- LAST 4h --------------------------------" >>$OUTDIR/globalpool_schedds_new.txt
for i in `tail /crabprod/CSstoragePath/aperez/out/schedds_out_time -n 24 |awk '{$1=""; print $0}'`; do 
	echo $i |awk -F"," '{print $1}'; 
done |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_schedds_new.txt
echo "">>$OUTDIR/globalpool_schedds_new.txt

echo "## --------------------------------- LAST 24h -------------------------------" >>$OUTDIR/globalpool_schedds_new.txt

for i in `tail /crabprod/CSstoragePath/aperez/out/schedds_out_time -n 144 |awk '{$1=""; print $0}'`; do
        echo $i |awk -F"," '{print $1}';
done |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_schedds_new.txt

mv $OUTDIR/globalpool_schedds_new.txt $OUTDIR/globalpool_dropped_schedds.txt
