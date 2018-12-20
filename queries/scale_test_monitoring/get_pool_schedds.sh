#!/bin/sh
source /etc/profile.d/condor.sh

# Check dropped schedds in the nego cycle at CMS global pool
# Antonio Perez-Calero Yzquierdo Nov. 2017

WORKDIR="/home/aperez/scale_test_monitoring"
OUTDIR="/crabprod/CSstoragePath/aperez/scale_test_monitoring"

collector=$($WORKDIR/collector_itb.sh)

date_s=$(date -u +%s) 

schedds=$(condor_status -pool $collector -nego -af LastNegotiationCycleScheddsOutOfTime0)

echo $schedds

echo $date_s $schedds >>$OUTDIR/out/schedds_out_time

# Get list for the last 4h and 24h (6 lines per hour, e.g. 6 * 24 = 144)
now=$(date -u)
echo "## INFO ON DROPPED SCHEDDS IN TEST POOL UPDATED AT" $now >$OUTDIR/HTML/globalpool_schedds_new.txt
echo "## --------------------------------------------------------------------------" >>$OUTDIR/HTML/globalpool_schedds_new.txt
echo "">>$OUTDIR/HTML/globalpool_schedds_new.txt

echo "## --------------------------------- LAST 1h --------------------------------" >>$OUTDIR/HTML/globalpool_schedds_new.txt
for i in `tail /crabprod/CSstoragePath/aperez/out/schedds_out_time -n 6 |awk '{$1=""; print $0}'`; do
        echo $i |awk -F"," '{print $1}';
done |sort |uniq -c |sort -nr>>$OUTDIR/HTML/globalpool_schedds_new.txt
echo "">>$OUTDIR/HTML/globalpool_schedds_new.txt

echo "## --------------------------------- LAST 4h --------------------------------" >>$OUTDIR/HTML/globalpool_schedds_new.txt
for i in `tail /crabprod/CSstoragePath/aperez/out/schedds_out_time -n 24 |awk '{$1=""; print $0}'`; do 
	echo $i |awk -F"," '{print $1}'; 
done |sort |uniq -c |sort -nr>>$OUTDIR/HTML/globalpool_schedds_new.txt
echo "">>$OUTDIR/HTML/globalpool_schedds_new.txt

echo "## --------------------------------- LAST 24h -------------------------------" >>$OUTDIR/HTML/globalpool_schedds_new.txt

for i in `tail /crabprod/CSstoragePath/aperez/out/schedds_out_time -n 144 |awk '{$1=""; print $0}'`; do
        echo $i |awk -F"," '{print $1}';
done |sort |uniq -c |sort -nr>>$OUTDIR/HTML/globalpool_schedds_new.txt

mv $OUTDIR/HTML/globalpool_schedds_new.txt $OUTDIR/HTML/globalpool_dropped_schedds.txt

