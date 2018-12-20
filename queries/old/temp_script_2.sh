#!/bin/sh

for day in `cat timestamp_day`; do
	for hour in `cat timestamp_hour`; do
	timestamp=$(echo $day"-"$hour)
	date_s=`date -d"$day $hour" +%s`
	cat period_cores_ordered |grep $day |grep $hour >lines_$timestamp
	for cores in {1..8}; do let slots_$cores=0; done
	while read -r line; do
		cores=$(echo $line |awk '{print $4}')
		total=$(echo $line |awk '{print $3}')
		let slots_$cores=$(echo $total)
	done<lines_$timestamp
	#echo $timestamp $date_s
	echo $date_s $slots_1 $slots_2 $slots_3 $slots_4 $slots_5 $slots_6 $slots_7 $slots_8 
	rm lines_$timestamp
	done
done
