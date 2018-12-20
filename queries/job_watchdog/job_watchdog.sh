#!/bin/sh
source /etc/profile.d/condor.sh

# Monitor job performance over time  
# Antonio Perez-Calero Yzquierdo Nov 2017

collector=$(/home/aperez/collector.sh):9620
WORKDIR="/home/aperez/status/watchdog/files"

date=$(date -u +%s)
# condor_q -pool $collector -name $schedd -const 'JobStatus == 2' -af GlobalJobId WMAgent_RequestName WMAgent_SubTaskName CRAB_ReqName RequestCPUs RemoteWallClockTime ServerTime-JobStartDate ServerTime-EnteredCurrentStatus RemoteUserCpu RemoteSysCpu+RemoteUserCpu |sort 
#done >$WORKDIR/jobmonitor_$date

condor_q -pool $collector -global -const 'JobStatus == 2' -af GlobalJobId WMAgent_RequestName WMAgent_SubTaskName CRAB_ReqName RequestCPUs RemoteWallClockTime ServerTime-JobStartDate ServerTime-EnteredCurrentStatus RemoteUserCpu RemoteSysCpu+RemoteUserCpu |grep -v SUBMIT.MIT.EDU |sort >$WORKDIR/monitorjobs_$date

gzip $WORKDIR/monitorjobs_$date 

# Only keep last 24 to 48h!
find $WORKDIR -type f -atime +1 -delete

#--------------------
