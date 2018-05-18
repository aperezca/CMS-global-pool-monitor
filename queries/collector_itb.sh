#collector="cmsgwms-collector-global.cern.ch" # Main collector used by CMS, by alias
collector=$(A=$(host cmsgwms-collector-itb.cern.ch |grep alias |awk '{print $NF}'); echo ${A:0:${#A}-1})
echo $collector
