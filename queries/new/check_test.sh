#!/bin/sh
source /etc/profile.d/condor.sh

# Analyse idle CPUs for multicore pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo Apr 2017

collector=$(/home/aperez/collector.sh)
date_s=`date -u +%s`
list="/home/aperez/status/test_list"
#take all slots except IOslots
condor_status -pool $collector -const '((IOslots=?=undefined) || (IOslots != 1))' -af GLIDEIN_CMSSite SlotType State Activity TotalSlotCPUs CPUs Memory GLIDEIN_ToRetire |sort |uniq -c >$list
#-------------------------------
all=$(cat $list |wc -l)
static_busy=$(cat $list |grep Static |grep -v Idle |wc -l)
static_idle=$(cat $list |grep Static |grep Idle |wc -l)
mcore_busy=$(cat $list |grep -v Static |grep -v Idle |wc -l)
mcore_idle=$(cat $list |grep -v Static |grep Idle |wc -l)
let total=$static_busy+$static_idle+$mcore_busy+$mcore_idle
echo $date_s $all $total

python analyse_list.py $list $date_s

