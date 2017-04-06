#!/bin/sh
source /etc/profile.d/condor.sh

# Based on get_pool_idle.sh
# /home/aperez/status/cores_all_glideins.txt

cores_mcore_busy=0
cores_mcore_idle=0
cores_score_busy=0
cores_score_idle=0

while read -r line; do
        #if [[ $(echo $line | grep Dynamic |grep Busy) != "" ]]; then let cores_mcore_busy+=$(echo $line | awk '{print $1*$4}'); fi
        if [[ $(echo $line | grep Dynamic |grep Idle) != "" ]]; then let cores_mcore_idle+=$(echo $line | awk '{print $1*$4}'); fi
        if [[ $(echo $line | grep Partitionable |grep Idle) != "" ]]; then let cores_mcore_idle+=$(echo $line | awk '{print $1*$4}'); fi
        #if [[ $(echo $line | grep Static |grep Busy) != "" ]]; then let cores_score_busy+=$(echo $line | awk '{print $1*$4}'); fi
        #if [[ $(echo $line | grep Static |grep Idle) != "" ]]; then let cores_score_idle+=$(echo $line | awk '{print $1*$4}'); fi
done</home/aperez/status/cores_all_glideins.txt

#echo $cores_mcore_busy $cores_mcore_idle $cores_score_busy $cores_score_idle
echo $cores_mcore_idle

# ---------------------------
# Based on get_pool_mcore_idle.sh
n_retire=0
n_memory=0
n_usable_unclaimed=0
n_usable_claimed=0
#echo "Idle cores in mcore pilots in draining:"
while read -r line; do let n_retire+=$(echo $line | awk '{print $1*$5}'); done</home/aperez/status/mcore_idle_retire.txt

#echo "Idle cores in mcore pilots with not enough memory:"
while read -r line; do let n_memory+=$(echo $line | awk '{print $1*$5}'); done</home/aperez/status/mcore_idle_memory.txt

#echo "Idle cores in mcore pilots with enough time and memory:"
while read -r line; do
        let cores=$(echo $line | awk '{print $1*$5}')
        state=$(echo $line | awk '{print $4}')
        if [[ $state == "Unclaimed" ]]; then let n_usable_unclaimed+=$cores; fi
        if [[ $state == "Claimed" ]]; then let n_usable_claimed+=$cores; fi
done</home/aperez/status/mcore_idle_usable.txt

let n_total=$n_retire+$n_memory+$n_usable_unclaimed+$n_usable_claimed
#echo "Total:"
echo $n_total
#echo $n_total $n_retire $n_memory $n_usable_unclaimed $n_usable_claimed
