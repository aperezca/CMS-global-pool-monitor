#!/bin/sh

source /data/srv/aperezca/Monitoring/env_itb.sh

# GlideinWMS frontend status in xml format
curl http://cmsgwms-frontend-itb.cern.ch/vofrontend/monitor/frontend_status.xml >$WORKDIR/FE_status/FE_CERN_status.xml
#curl http://cmsgwms-frontend.fnal.gov:8319/vofrontend/monitor/frontend_status.xml >$WORKDIR/FE_status/FE_FNAL_status.xml

# Save data to /out
date=`date -u +%s`

# Parse xml to produce output in terms of requested idle glideins

# a) For all sites in global pool (t1prod and main groups so far)
FE_full=$(python $WORKDIR/parse_FE_xml_full.py $WORKDIR/FE_status/FE_CERN_status.xml)
echo $date $FE_full>>$OUTDIR/frontend_full

