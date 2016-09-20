#!/bin/sh
source /etc/profile.d/condor.sh

# Analyse idle CPUs for multicore pilots at CMS global pool
# Antonio Perez-Calero Yzquierdo May 2016

collector=$(/home/aperez/collector.sh)

date_s=`date -u +%s`

#echo "Idle cores in mcore pilots in draining:"
condor_status -pool $collector -const '(SlotType=?="Partitionable") && (GLIDEIN_ToRetire<'${date_s}') && (CPUs>0)' -af CPUs |sort |uniq -c >/home/aperez/status/mcore_idle_retire.txt
condor_status -pool $collector -const '(SlotType=?="Dynamic") && (Activity=?="Idle") && (GLIDEIN_ToRetire<'${date_s}')' -af CPUs |sort |uniq -c >>/home/aperez/status/mcore_idle_retire.txt

#echo "Idle cores in mcore pilots with not enough memory:"
condor_status -pool $collector -const '(SlotType=?="Partitionable") && (GLIDEIN_ToRetire>'${date_s}') && (CPUs>0) && (Memory<2000)' -af CPUs |sort |uniq -c >/home/aperez/status/mcore_idle_memory.txt
condor_status -pool $collector -const '(SlotType=?="Dynamic") && (Activity=?="Idle") && (GLIDEIN_ToRetire>'${date_s}') && (Memory<2000)' -af CPUs |sort |uniq -c >>/home/aperez/status/mcore_idle_memory.txt

#echo "Idle cores in mcore pilots with enough time and memory:"
condor_status -pool $collector -const '(SlotType=?="Partitionable") && (GLIDEIN_ToRetire>'${date_s}') && (CPUs>0) && (Memory>2000*CPUs)' -af CPUs |sort |uniq -c >/home/aperez/status/mcore_idle_usable.txt
condor_status -pool $collector -const '(SlotType=?="Dynamic") && (Activity=?="Idle") && (GLIDEIN_ToRetire>'${date_s}') && (Memory>2000)' -af CPUs |sort |uniq -c >>/home/aperez/status/mcore_idle_usable.txt

n_retire=0
n_memory=0
n_usable=0

#echo "Idle cores in mcore pilots in draining:"
while read -r line; do
	#echo $line
	let n_retire+=$(echo $line | awk '{print $1*$2}')
done</home/aperez/status/mcore_idle_retire.txt
#echo $n_retire

#echo "Idle cores in mcore pilots with not enough memory:"
while read -r line; do
	#echo $line
        let n_memory+=$(echo $line | awk '{print $1*$2}')
done</home/aperez/status/mcore_idle_memory.txt
#echo $n_memory

#echo "Idle cores in mcore pilots with enough time and memory:"
while read -r line; do
	#echo $line
        let n_usable+=$(echo $line | awk '{print $1*$2}')
done</home/aperez/status/mcore_idle_usable.txt
#echo $n_usable

#echo "Total:"
echo $date_s $n_retire $n_memory $n_usable >>/home/aperez/out/pool_mcoreidle
