#!/bin/sh
source /etc/profile.d/condor.sh

# Check Idle, Running and Held multicore pilots at T1s to evaluate glidein pressure on each site compared to pledged slots
# Antonio Perez-Calero Yzquierdo Sep. 2015
#factory infos
for factory in 'vocms0305.cern.ch' 'cmsgwms-factory.fnal.gov' 'gfactory-1.t2.ucsd.edu' 'glidein.grid.iu.edu'; do
	#$(condor_q -g -pool $factory -const '(GridJobStatus=?="IDLE")' -format '%s ' GridJobStatus -format '%s\n' GlideinEntryName |grep "_T1_" >idle_glideins_$factory)
	$(condor_q -g -pool $factory -format '%s ' GridJobStatus -format '%s\n' GlideinEntryName |grep "_T1_" |sort  >fact_glideins_$factory)
done

for site in 'T1_DE_KIT' 'T1_ES_PIC' 'T1_FR_CCIN2P3' 'T1_IT_CNAF' 'T1_RU_JINR' 'T1_UK_RAL' 'T1_US_FNAL'; do
	#echo $site
	date=`date -u +%s`
	idle_g=0
	running_g=0
	held_g=0
	# grep by entry to pick only mcore entries!
	for entry in `cat entries_mcore_$site`; do
		idle=$(cat fact_glideins_* |grep $entry |grep IDLE | wc -l)
		idle_2=$(cat fact_glideins_* |grep $entry |grep INLRMS:Q | wc -l)

		running=$(cat fact_glideins_* |grep $entry |grep RUNNING | wc -l)
		running_2=$(cat fact_glideins_* |grep $entry |grep INLRMS:R | wc -l)

		held=$(cat fact_glideins_* |grep $entry |grep HELD | wc -l )
		let idle_g+=$idle
		let idle_g+=$idle_2
		let running_g+=$running
		let running_g+=$running_2
		let held_g+=$held
	done
	echo $date $idle_g $running_g $held_g >>/home/aperez/out/factories_$site
done
