#!/bin/sh
source /etc/profile.d/condor.sh

# Get job attributes from schedds in the CMS global pool
# Antonio Perez-Calero Yzquierdo May 2016

collector=$(/home/aperez/collector.sh)

echo "Requests prior to rounding"

query="RequestMemory_RAW RequestMemory"

echo "by schedd:"
for schedd in $(condor_status -pool $collector -schedd -af Name); do
        echo $schedd
        condor_q -pool $collector -name $schedd -af $query |sort |uniq -c | awk '{print $2, $1}' | sort -n
done 

