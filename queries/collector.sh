#collector="cmsgwms-collector-global.cern.ch" # Main collector used by CMS, by alias
#collector=$(A=$(host cmsgwms-collector-global.cern.ch |grep alias |awk '{print $NF}'); echo ${A:0:${#A}-1})
#collector="vocms0814.cern.ch."

collector="cmsgwms-collector-global.fnal.gov" # Backup collector used by CMS, by alias
#collector="cmssrvz02.fnal.gov" # New backup collector at FNAL
#collector="vocms0814.cern.ch" # temporary using the CERN collector!!

echo $collector
