echo ; echo PIC:
echo "Idle CPUs, Count"
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -const '(SlotType=?="Partitionable")' -af  CPUs | sort | uniq -c | awk '{print $2 "," $1}'

# Esto nos da la lista de pilots que esten conectados a un collector. Eso significa que puede haber mas corriendo en el site, pero no los tenemos en cuenta:
# 07/07/15 15:17:01 (pid:58582) CCBListener: connection to CCB server vocms099.cern.ch:9868 failed; will try to reconnect in 60 seconds.
# 07/07/15 15:17:03 (pid:58582) attempt to connect to <131.225.207.128:9868> failed: Connection refused (connect errno = 111).
# 07/07/15 15:17:03 (pid:58582) ERROR: SECMAN:2003:TCP connection to collector cmssrv221.fnal.gov:9868 failed.
# 07/07/15 15:17:03 (pid:58582) CCBListener: connection to CCB server cmssrv221.fnal.gov:9868 failed; will try to reconnect in 60 seconds.
# ...

# -------------------
#DOCUMENTATION AT http://research.cs.wisc.edu/htcondor/manual/current/condor_status.html

# queries on the global pool negotiator:
condor_status -pool vocms032 -neg
# to check all negotiator classads:
condor_status -pool vocms032 -neg -l

condor_status -pool cmsgwms-collector-global.cern.ch -nego -const '(name=?="NEGOTIATOR")' -l

# queries to the global pool collector:
condor_status -pool cmssrv221.fnal.gov -collector -l

# summary tables for jobs per schedd:
condor_status -pool vocms032.cern.ch -schedd

# get list of schedds connected to the pool
condor_status -pool cmsgwms-collector-global.cern.ch -schedd -af Name

# all attributes from a schedd
condor_status -pool cmssrv221.fnal.gov -schedd vocms0304.cern.ch -l

#condor_q on a given schedd:
condor_q -pool vocms032.cern.ch -name cmsgwms-submit1.fnal.gov

#Check job attributes from the schedd, RAW!
condor_q -l -pool cmsgwms-collector-global.cern.ch -name cmsgwms-submit1.fnal.gov 157707.72 |grep RAW

MaxWallTimeMins_RAW = 60
RequestMemory_RAW = 1980
NumCkpts_RAW = 0
DiskUsage_RAW = 3851
ExecutableSize_RAW = 4
ImageSize_RAW = 4
RequestDisk_RAW = 1048576

# Jobs running at a given site, with particular request of cores:
condor_q -pool cmsgwms-collector-global.cern.ch -global -constraint '(JobStatus == 2) && (RequestCPUs == 4) && (MATCH_GLIDEIN_CMSSite == "T2_US_Vanderbilt")'

# Jobs running with resource request and usage and WMAgent request name and job type:
condor_q -pool cmsgwms-collector-global.cern.ch -global -constraint '(JobStatus == 2)' -af RequestMemory_RAW RequestMemory MemoryUsage WMAgent_RequestName CMS_JobType |sort |uniq -c
#--------------------
#Queries al FE para ver cuando esta ignorando un schedd: aunque haya carga no genera pilots!!
[mmascher@vocms080 ~]$ egrep '(Ignoring schedd|hit maxrun limit|hitmaxupload limit|CurbMatchmaking in its classad evaluated to)' /etc/gwms-frontend/log/group_main/main.err.log

#-------------------
#Jobs totales en la global pool:
[aperezca@vocms032 ~]$ condor_q -g -totals
#--------------------

#-------------------
#Info from finished jobs:
condor_history -pool cmsgwms-collector-global.cern.ch -name cmsgwms-submit1.fnal.gov
condor_history -pool cmsgwms-collector-global.cern.ch -name cmsgwms-submit1.fnal.gov -l 449897.0

#-------------------
#Total pilot monitor:
condor_status -pool cmsgwms-collector-global.cern.ch -af GLIDEIN_CMSSite SlotType TotalSlotCpus CPUs State Activity |sort |uniq -c 
condor_status -pool cmsgwms-collector-global.cern.ch -af GLIDEIN_CMSSite SlotType TotalSlotCPUs GLIDEIN_Entry_Name |sort |uniq -c

echo "-------------"
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -af Machine GLIDEIN_MASTER_NAME CPUs SlotType GLIDEIN_ToRetire | awk -v time=`/bin/date +%s` '{print $0 " =" int(($NF-time)/60.) "mins" }' | sort

condor_status -pool vocms099.cern.ch  -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -af CPUs SlotType state activity GLIDEIN_ToRetire | awk -v time=`/bin/date +%s` '{print $0 " =" int(($NF-time)/60.) "mins" }' | sort

condor_status -pool cmssrv221.fnal.gov -af GLIDEIN_CMSSite Name SlotType TotalSlotCPus |grep -v Dynamic |sort

# Esto nos da todos los pilots y sus slots:
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")'  -af SlotType CPUs Machine |awk '{print $3, $2, $1}' |sort

# Mamery per core in partitionable glideins:
condor_status -pool cmsgwms-collector-global.cern.ch -const '(SlotType=?="Partitionable")' -af TotalMemory/TotalCPUs |sort |uniq -c |sort -nr

# Dynamic slots segun su state, claimed or not
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -const '(SlotType=?="Dynamic")' -format '%s\n' state |sort |uniq -c

#Check glideins according to group:
condor_status -const 'GLIDEIN_CMSSite=?="T1_US_FNAL" && GLIDECLIENT_Group=?="main"' -pool vocms099.cern.ch
condor_status -const 'GLIDEIN_CMSSite=?="T1_US_FNAL" && GLIDECLIENT_Group=?="t1prod"' -pool vocms099.cern.ch

#Other classads:
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -format '%s ' SlotType  -format '%s\n' MonitorSelfCPUUsage
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -format '%s '  SlotType  -format '%s\n' JobStarts
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -format '%s '  SlotType  -format '%s\n' TotalTimeUnclaimedIdle  #Only for static and partitionable! = can be used to measure total pilot running time?
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -format '%s '  SlotType  -format '%s\n' TotalTimeClaimedBusy    #Only for static and dynamic!
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -format '%s '  SlotType  -format '%s\n' TotalJobRunTime
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -format '%s '  SlotType  -format '%s\n' CpuBusyTime
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -format '%s '  SlotType  -format '%s\n' MonitorSelfResidentSetSize 
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -const '(SlotType=?="Partitionable")' -format '%s\n' Disk |sort |uniq -c 
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -const '(SlotType=?="Partitionable")' -format '%s\n' Memory |sort |uniq -c
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -const '(SlotType=?="Partitionable")' -format '%s\n' MonitorSelfAge |sort |uniq -c
condor_status -pool vocms099.cern.ch -const '(GLIDEIN_CMSSite=?="T1_ES_PIC")' -const '(SlotType=?="Partitionable")' -format '%s ' MonitorSelfAge -format '%s\n' TotalTimeUnclaimedIdle  #son casi equivalentes!
# -----------------------

# Para distinguir los glideins idle segun memoria o retire:
condor_status -pool vocms099.cern.ch  -const '(GLIDEIN_CMSSite=?="T1_ES_PIC") && (SlotType=?="Partitionable") && (CPUs>0)' -format '%s '  CPUs   -format '%s '  SlotType -format '%s '  state -format '%s '  activity   -format '%s\n' GLIDEIN_ToRetire   | awk -v time=`/bin/date +%s` '{print $0 " = " int(($NF-time)/60.) "mins" }' | sort

condor_status -pool cmsgwms-collector-global.cern.ch -const '(GLIDEIN_CMSSite=?="T1_US_FNAL") && (SlotType=?="Partitionable") && (Memory<2000)' -format '%s ' CPUs -format '%s\n' RetirementTimeRemaining |sort |uniq -c
#----------------

#Para los glideins que aun no estan corriendo, puedo hacer queries a las factories!
condor_q -g -pool vocms0305.cern.ch -const '(GlideinEntryName=?="CMSHTPC_T1_ES_PIC_ce10-multicore")'
condor_q -g -pool cmsgwms-factory.fnal.gov -const '(GlideinEntryName=?="CMSHTPC_T1_ES_PIC_ce10-multicore")'
condor_q -g -pool gfactory-1.t2.ucsd.edu -const '(GlideinEntryName=?="CMSHTPC_T1_ES_PIC_ce10-multicore")'
condor_q -g -pool glidein.grid.iu.edu -const '(GlideinEntryName=?="CMSHTPC_T1_ES_PIC_ce10-multicore")'

# Por ejemplo, puedo ver los glideins R, I y H en dada site. Voy a tratar de sacar plots de cuanto estamos tratando de allocate para cada site, porque no tiene medida en relacion con los pledges del site, lo cual no tiene sentido.
