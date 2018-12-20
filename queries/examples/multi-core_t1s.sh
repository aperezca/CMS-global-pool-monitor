#!/bin/sh
source /etc/profile.d/condor.sh

date=`date -u +%s`
# Non-allocated CPUs in partitionable slots:
for site in 'T1_DE_KIT' 'T1_ES_PIC' 'T1_FR_CCIN2P3' 'T1_IT_CNAF' 'T1_RU_JINR' 'T1_UK_RAL' 'T1_US_FNAL'; do
	echo $site;
	#echo "Idle CPUs: Count";
	condor_status -pool vocms099.cern.ch \
	-const '(GLIDEIN_CMSSite=?="'$site'")' \
	-const '(SlotType=?="Partitionable")' \
	-format '%s\n' CPUs \
 	| sort | uniq -c | awk '{print "Idle:"$2",Count:"$1}' >/home/aperez/out/data_"$site"_"$date"
	#echo
done

#echo "-------------"
#condor_status -pool vocms099.cern.ch \
#  -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' \
#  -format '%s '  Machine             \
#  -format '%s '  GLIDEIN_MASTER_NAME \
#  -format '%s '  CPUs \
#  -format '%s '  SlotType \
#  -format '%s\n' GLIDEIN_ToRetire \
#  | awk -v time=`/bin/date +%s` '{print $0 " =" int(($NF-time)/60.) "mins" }' | sort
#
## Esto nos da todos los pilots y sus slots:
#condor_status -pool vocms099.cern.ch \
#  -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' \
#  -format '%s ' SlotType \
#  -format '%s '  CPUs \
#  -format '%s\n' Machine \
#  |awk '{print $3, $2, $1}' |sort
#
