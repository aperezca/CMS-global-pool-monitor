#collector=$(A=$(host cmsgwms-collector-itb.cern.ch |grep alias |awk '{print $NF}'); echo ${A:0:${#A}-1})
collector="cmssrv283.fnal.gov" # Backup collector at FNAL
collector="vocms0809.cern.ch" # Backup collector at CERN based on the VM, for the tests on the new phys machine (Jan2021)
collector="vocms0803.cern.ch" # ITB collector at CERN based on the phys machine, as the 0809 one gets saturated! (Jan2021)
echo $collector
