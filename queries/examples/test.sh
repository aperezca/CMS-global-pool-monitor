site="T1_ES_PIC"
site="T1_RU_JINR"
for i in {0..12}; do
	line='Partitionable'$i'Unclaimed'
	echo $i $line
	let used=12-$i
	num=$(cat glideins_$site| grep Partitionable |awk '{print $2 $3 $4}' |grep $line| wc -l);
	let pilot_$used=$num
done
echo $pilot_0 $pilot_1 $pilot_2 $pilot_3 $pilot_4 $pilot_5 $pilot_6 $pilot_7 $pilot_8 $pilot_9 $pilot_10 $pilot_11 $pilot_12

for i in {0..12}; do
	let used=12-$i
	let pilot_$i=$(cat glideins_$site| grep Partitionable |awk '{print $3}' |grep $used| wc -l);
done
echo $pilot_0 $pilot_1 $pilot_2 $pilot_3 $pilot_4 $pilot_5 $pilot_6 $pilot_7 $pilot_8 $pilot_9 $pilot_10 $pilot_11 $pilot_12
