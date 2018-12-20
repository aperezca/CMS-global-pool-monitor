#!/bin/sh
source /etc/profile.d/condor.sh

# Get job attributes from schedds in the CMS global pool
# Antonio Perez-Calero Yzquierdo May 2016

# Choose prod, crab, cmsconnect or all schedds
schedds=$1
# Choose constraint for the jobs
#const=$2 
# Choose from list of attibutes on which we perform autoclustering
attrib=$2

collector=$(/home/aperez/collector.sh)

if [ $schedds == "prod" ]; then condor_status -pool $collector -schedd -const '( CMSGWMS_Type =?= "prodschedd")' -af Name > schedds_prod; fi
if [ $schedds == "crab" ]; then condor_status -pool $collector -schedd -const '( CMSGWMS_Type =?= "crabschedd")' -af Name > schedds_crab; fi
if [ $schedds == "cmsconnect" ]; then condor_status -pool $collector -schedd -const '( CMSGWMS_Type =?= "cmsconnect")' -af Name > schedds_cmsconnect; fi
if [ $schedds == "all" ]; then condor_status -pool $collector -schedd -af Name |sort > schedds_all; fi

#echo "Requests on" $attrib "for" $schedds "schedds"

#exp="'$(echo $const)'"
for schedd in $(cat schedds_$schedds); do
	#echo $schedd $exp
	#condor_q -pool $collector -name $schedd -const $exp -af $attrib |sort |uniq -c
	# Running
	#condor_q -pool $collector -name $schedd -const '(JobStatus==2)' -af $attrib
	# Queued
	condor_q -pool $collector -name $schedd -const '(JobStatus==1) && (RequestCPUs==4)' -af $attrib
done

#echo "by schedd:"
#for schedd in $(condor_status -pool $collector -schedd -af Name); do
#        echo $schedd
#        condor_q -pool $collector -name $schedd -af RequestMemory_RAW |sort |uniq -c | awk '{print $2, $1}' | sort -n
#done 

# to run the whole thing use something like:
# for i in `cat autocluster_attrs.txt`; do echo $i; ./get_attr_values.sh $i prod |sort |uniq | wc -l; echo "---"; done

# find schedds connected to the pool and autoclusters
# condor_status -pool cmsgwms-collector-global.cern.ch -schedd -af Name CMSGWMS_Type Autoclusters

#count atoclusters:
# clusters=0; for i in `condor_status -pool cmsgwms-collector-global.cern.ch -schedd -af Name CMSGWMS_Type Autoclusters |grep prod |awk '{print $3}'`; do let clusters+=$i; done; echo $clusters
# clusters=0; for i in `condor_status -pool cmsgwms-collector-global.cern.ch -schedd -af Name CMSGWMS_Type Autoclusters |grep crab |awk '{print $3}'`; do let clusters+=$i; done; echo $clusters
# clusters=0; for i in `condor_status -pool cmsgwms-collector-global.cern.ch -schedd -af Name CMSGWMS_Type Autoclusters |awk '{print $3}'`; do let clusters+=$i; done; echo $clusters
