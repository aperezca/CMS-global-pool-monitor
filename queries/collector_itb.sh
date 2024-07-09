#collector=$(A=$(host cmsgwms-collector-itb.cern.ch |grep alias |awk '{print $NF}'); echo ${A:0:${#A}-1})
collector="cmssrv623.fnal.gov" # Backup collector at FNAL
#collector="vocms0809.cern.ch" # Backup collector at CERN based on the VM, for the tests on the new phys machine (Jan2021)

echo $collector
