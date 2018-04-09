#!/bin/sh
source /etc/profile.d/condor.sh

# Check dropped schedds in the nego cycle at CMS global pool
# Antonio Perez-Calero Yzquierdo Nov. 2017

collector=$(/home/aperez/scale_test_monitoring/collector.sh)
date_s=$(date -u +%s) 

schedds=$(condor_status -pool $collector -nego -af LastNegotiationCycleScheddsOutOfTime0)
#echo $date_s $schedds
echo $date_s $schedds >>/crabprod/CSstoragePath/aperez/scale_test_monitoring/out/schedds_out_time
