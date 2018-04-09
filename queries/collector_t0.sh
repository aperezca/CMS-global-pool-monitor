#collector="cmsgwms-collector-global.cern.ch" # Main collector used by CMS, by alias
collector=$(A=$(host cmsgwms-collector-tier0.cern.ch |grep alias |awk '{print $NF}'); echo ${A:0:${#A}-1})
#collector="cmssrv239.fnal.gov" # Backup collector at FNAL
echo $collector
