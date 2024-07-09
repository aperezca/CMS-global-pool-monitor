# CMS-global-pool-monitor

This is a set of simple monitoring scripts that run queries to the CMS HTCondor global pool, then plot results via google charts scripts in HTML files

/queries: query shell scripts, plus a few python ones (calculate averages, parse gWMS FE xml, etc). It also requires:
/queries/FE_status and /queries/status

/make_html: scripts that build the html files that present the plots with the accumulated data

Additionally, scripts require:

/out: local storage for the data retrieved from the pools, from which the monitoring plots are built. Pools are: Global_pool, scale_test_monitoring, T0 and Volunteer

/HTML: where html files are written to, then copied to EOS at CERN for access via browser. It contains the following structure

/HTML: main plots
/HTML/JobInfo    
/HTML/scale_test_monitoring
/HTML/Schedds
/HTML/{T0, T1s, T2s, T3s}

