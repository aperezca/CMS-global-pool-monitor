#!/bin/sh
source /etc/profile.d/condor.sh

collector="cmsgwms-collector-tier0.cern.ch" # Main T0 collector used by CMS
#collector="cmssrv239.fnal.gov" # Backup collector for T0 at FNAL

for site in `cat /home/aperez/entries/T0_sites`; do
	condor_status -pool $collector \
	-const '(GLIDEIN_CMSSite=?="'$site'") && (SlotType=?="Partitionable")' \
	-format '%s ' MonitorSelfAge \
	-format '%s ' CPUs \
	-format '%s ' Memory \
	-format '%s ' Disk \
	-format '%s\n' JobStarts \
	>/home/aperez/status/partglideins_now_$site

	/crabprod/CSstoragePath/aperez/T0/make_html_status.sh $site
done
