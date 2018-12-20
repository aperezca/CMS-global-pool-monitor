#!/bin/sh
source /etc/profile.d/condor.sh


CERN_factory=`host -t CNAME cmsgwms-factory-prod.cern.ch |awk '{print $6}'`
CERN_factory="vocms0805.cern.ch"
UCSD_factory="gfactory-1.t2.ucsd.edu:9614"
FNAL_factory="cmsgwms-factory.fnal.gov"
GOC_factory="glidein.grid.iu.edu"


for factory in $CERN_factory $UCSD_factory $FNAL_factory $GOC_factory; do
	echo $factory 
	condor_q -g -pool $factory -const '(GlideinFrontendName == "CMSG-v1_0:cmspilot")' -af JobStatus |sort |uniq -c
	echo ''
	echo ''
done 


