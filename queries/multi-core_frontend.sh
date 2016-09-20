#!/bin/sh

# GlideinWMS frontend status in xml format
curl http://cmsgwms-frontend-global.cern.ch/vofrontend/monitor/frontend_status.xml >/home/aperez/FE_status/FE_CERN_status.xml
#curl http://cmsgwms-frontend.fnal.gov:8319/vofrontend/monitor/frontend_status.xml >/home/aperez/FE_status/FE_FNAL_status.xml

# Save data to /out
date=`date -u +%s`

# Parse xml to produce output in terms of requested idle glideins
# a) For all sites in global pool (t1prod and main groups so far)
FE_full=$(python /home/aperez/parse_FE_xml_full.py /home/aperez/FE_status/FE_CERN_status.xml)
echo $date $FE_full>>/home/aperez/out/frontend_full

# b) For each multicore T1 and T2 site:
python /home/aperez/parse_FE_xml.py /home/aperez/FE_status/FE_CERN_status.xml T1s>/home/aperez/FE_status/stats_T1_FE_CERN
#python /home/aperez/parse_FE_xml.py /home/aperez/FE_status/FE_FNAL_status.xml T1s>/home/aperez/FE_status/stats_T1_FE_FNAL
python /home/aperez/parse_FE_xml.py /home/aperez/FE_status/FE_CERN_status.xml T2s>/home/aperez/FE_status/stats_T2_FE_CERN
#python /home/aperez/parse_FE_xml.py /home/aperez/FE_status/FE_FNAL_status.xml T2s>/home/aperez/FE_status/stats_T2_FE_FNAL

for site in `cat /home/aperez/entries/T1_sites`; do
	CERN_prod=$(cat /home/aperez/FE_status/stats_T1_FE_CERN |grep $site |grep t1prod |awk '{print $3}')
	#FNAL_prod=$(cat /home/aperez/FE_status/stats_T1_FE_FNAL |grep $site |grep t1prod |awk '{print $3}')

	CERN_main=$(cat /home/aperez/FE_status/stats_T1_FE_CERN |grep $site |grep main |awk '{print $3}')
        #FNAL_main=$(cat /home/aperez/FE_status/stats_T1_FE_FNAL |grep $site |grep main |awk '{print $3}')
	echo $date $CERN_prod $CERN_main >>/home/aperez/out/frontend_$site
done

for site in `cat /home/aperez/entries/T2_sites`; do
        CERN_main=$(cat /home/aperez/FE_status/stats_T2_FE_CERN |grep $site |grep main |awk '{print $3}')
        #FNAL_main=$(cat /home/aperez/FE_status/stats_T2_FE_FNAL |grep $site |grep main |awk '{print $3}')
        echo $date $CERN_main >>/home/aperez/out/frontend_$site
done
