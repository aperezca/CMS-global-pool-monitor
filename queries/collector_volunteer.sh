#collector=$(A=$(host vocms0840.cern.ch |grep alias |awk '{print $NF}'); echo ${A:0:${#A}-1})
collector="vocms0840.cern.ch"
echo $collector
