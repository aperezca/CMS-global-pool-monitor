#!/bin/sh
# Check dropped schedds in the nego cycle at CMS global pool
# Antonio Perez-Calero Yzquierdo Nov. 2017

source /data/srv/aperezca/Monitoring/env_itb.sh

collector=$($WORKDIR/collector_itb.sh)

date_s=$(date -u +%s) 

schedds=$(condor_status -pool $collector -nego -af LastNegotiationCycleScheddsOutOfTime0)

echo $schedds

echo $date_s $schedds  >>$OUTDIR/schedds_out_time

# Get list for the last 4h and 24h (6 lines per hour, e.g. 6 * 24 = 144)
now=$(date -u)
echo "Info on dropped Schedds in CMS ITB pool updated at" $now >$HTMLDIR/globalpool_schedds_new.txt
echo "">>$HTMLDIR/globalpool_schedds_new.txt

echo "--------------------------------- LAST 1h --------------------------------" >>$HTMLDIR/globalpool_schedds_new.txt
for i in `tail $OUTDIR/schedds_out_time -n 6 |awk '{$1=""; print $0}'`; do
        echo $i |awk -F"," '{print $1}';
done |sort |uniq -c |sort -nr>>$HTMLDIR/globalpool_schedds_new.txt
echo "">>$HTMLDIR/globalpool_schedds_new.txt

echo "--------------------------------- LAST 4h --------------------------------" >>$HTMLDIR/globalpool_schedds_new.txt
for i in `tail $OUTDIR/schedds_out_time -n 24 |awk '{$1=""; print $0}'`; do 
	echo $i |awk -F"," '{print $1}'; 
done |sort |uniq -c |sort -nr>>$HTMLDIR/globalpool_schedds_new.txt
echo "">>$HTMLDIR/globalpool_schedds_new.txt

echo "--------------------------------- LAST 24h -------------------------------" >>$HTMLDIR/globalpool_schedds_new.txt
for i in `tail $OUTDIR/schedds_out_time -n 144 |awk '{$1=""; print $0}'`; do
        echo $i |awk -F"," '{print $1}';
done |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_schedds_new.txt

mv $HTMLDIR/globalpool_schedds_new.txt $HTMLDIR/globalpool_dropped_schedds.txt

