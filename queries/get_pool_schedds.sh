#!/bin/sh
# Check dropped schedds in the nego cycle at CMS global pool
# Antonio Perez-Calero Yzquierdo Nov. 2017

source /data/srv/aperezca/Monitoring/env.sh

collector=$($WORKDIR/collector.sh)
collector_t0=$($WORKDIR/collector_t0.sh)

date_s=$(date -u +%s) 

schedds=$(condor_status -pool $collector -nego -af LastNegotiationCycleScheddsOutOfTime0)
schedds_t0=$(condor_status -pool $collector_t0 -nego -af LastNegotiationCycleScheddsOutOfTime0)

echo $schedds
echo $schedds_t0

echo $date_s $schedds $schedds_t0 >>$OUTDIR/schedds_out_time

# Get list for the last 4h and 24h (6 lines per hour, e.g. 6 * 24 = 144)
now=$(date -u)
echo "Info on dropped Schedds in CMS Global and CERN pools updated at" $now >$HTMLDIR/globalpool_schedds_new.txt
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
echo "">>$HTMLDIR/globalpool_schedds_new.txt

echo "--------------------------------- LAST 7 days -------------------------------" >>$HTMLDIR/globalpool_schedds_new.txt
for i in `tail $OUTDIR/schedds_out_time -n 1008 |awk '{$1=""; print $0}'`; do
        echo $i |awk -F"," '{print $1}';
done |sort |uniq -c |sort -nr>>$OUTDIR/globalpool_schedds_new.txt

mv $HTMLDIR/globalpool_schedds_new.txt $HTMLDIR/globalpool_dropped_schedds.txt

