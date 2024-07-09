#collector=$(A=$(host cmsgwms-collector-itb.cern.ch |grep alias |awk '{print $NF}'); echo ${A:0:${#A}-1})
#collector="vocms0803.cern.ch" # Backup collector at CERN based on the VM, for the tests on the new phys machine (Jan2021)
collector="vocms0808.cern.ch" # New CM at CERN for scale tests (Mar2023)
echo $collector
