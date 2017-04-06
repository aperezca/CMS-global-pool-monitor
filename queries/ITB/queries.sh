condor_q -pool cmsgwms-collector-itb.cern.ch -global -l
#condor_q -pool cmsgwms-collector-itb.cern.ch:9620 -global -const '(User=="aperezca@cms")' -af User JobStatus RemoteHost | sort |uniq -c

condor_status -pool cmsgwms-collector-itb.cern.ch -schedd -l

#condor_status -pool cmsgwms-collector-itb.cern.ch -af GLIDEIN_CMSSite Name
condor_status -pool cmsgwms-collector-itb.cern.ch -l

condor_status -pool cmsgwms-collector-itb.cern.ch -collector -l

condor_status -pool cmsgwms-collector-itb.cern.ch -neg -l
