#!/bin/sh
source /etc/profile.d/condor.sh

# Watch number and type of jobs in CMS global pool
# Antonio Perez-Calero Yzquierdo Apr, Jun,  2016

collector=$(/home/aperez/collector.sh)

condor_status -pool $collector -schedd -af Name TotalRunningJobs TotalIdleJobs TotalHeldJobs CMSGWMS_Type Autoclusters| sort >/home/aperez/status/all_jobs.txt

total_jobs_run=0
total_jobs_idle=0
total_jobs_held=0
while read -r line; do
	let total_jobs_run+=$(echo $line |awk '{print $2}')
	let total_jobs_idle+=$(echo $line |awk '{print $3}')
	let total_jobs_held+=$(echo $line |awk '{print $4}')
done</home/aperez/status/all_jobs.txt

cat /home/aperez/status/all_jobs.txt |grep crab >/home/aperez/status/all_jobs_crab.txt
cat /home/aperez/status/all_jobs.txt |grep prod >/home/aperez/status/all_jobs_prod.txt
cat /home/aperez/status/all_jobs.txt |grep -v crab |grep -v prod>/home/aperez/status/all_jobs_other.txt

for i in 'prod' 'crab' 'other'; do
	let jobs_run_$i=0
	let jobs_idle_$i=0
	let jobs_held_$i=0
	let autoclusters_$i=0
	#echo $i
	while read -r line; do
		#echo $line
		let jobs_run_$i+=$(echo $line |awk '{print $2}')
		let jobs_idle_$i+=$(echo $line |awk '{print $3}')
		let jobs_held_$i+=$(echo $line |awk '{print $4}')
		let autoclusters_$i+=$(echo $line |awk '{print $6}')
	done</home/aperez/status/all_jobs_${i}.txt
done


date_all=`date -u +%s`
echo $date_all $total_jobs_run $total_jobs_idle $total_jobs_held >>/home/aperez/out/jobs_size

echo $date_all $jobs_run_prod $jobs_idle_prod $jobs_held_prod >>/home/aperez/out/jobs_size_prod
echo $date_all $jobs_run_crab $jobs_idle_crab $jobs_held_crab >>/home/aperez/out/jobs_size_crab
echo $date_all $jobs_run_other $jobs_idle_other $jobs_held_other >>/home/aperez/out/jobs_size_other

echo $date_all $autoclusters_prod $autoclusters_crab $autoclusters_other >>/home/aperez/out/autoclusters

