#!/bin/sh
source /etc/profile.d/condor.sh

# Check Idle, Running and Held multicore pilots at T1s to evaluate glidein pressure on each site compared to pledged slots
# Antonio Perez-Calero Yzquierdo Sep. 2015, May 2016, May 2017
# factory infos

CERN_factory=`host -t CNAME cmsgwms-factory-prod.cern.ch |awk '{print $6}'`
#CERN_factory="vocms0805.cern.ch"
UCSD_factory="gfactory-1.t2.ucsd.edu:9614"
FNAL_factory="cmsgwms-factory.fnal.gov"
GOC_factory="glidein.grid.iu.edu"

date_s=`date -u +%s`
idle_g=0
running_g=0
held_g=0
for factory in $CERN_factory $FNAL_factory $UCSD_factory $GOC_factory; do
	#condor_q -g -pool $factory -const '(GlideinFrontendName == "CMSG-v1_0:cmspilot") && (JobStatus==1)' -af GlideinEntryName  
	#condor_q -g -pool $factory -const '(GlideinFrontendName == "CMSG-v1_0:cmspilot") && (JobStatus==1)' -af GridJobStatus #GlideinEntryName EnteredCurrentStatus 
	#condor_q -g -pool $factory -const '(GlideinFrontendName == "CMSG-v1_0:cmspilot") && (JobStatus==1)' -af $date_s-QDate
	condor_q -g -pool $factory -const '(GlideinFrontendName == "CMSG-v1_0:cmspilot") && (JobStatus==1)' -af QDate
	#condor_q -g -pool $factory -af GlideinFrontendName GlideinEntryName JobStatus

#done |awk '{print int($1/3600)}' |sort -n |uniq -c
done |sort >/home/aperez/status/pilots_entered_queue_status

for i in `cat /home/aperez/status/pilots_entered_queue_status |sort`; do date -d @$i -u +%D; done |uniq -c
#---------
#get cores for each entry
python /home/aperez/parse_FE_xml_full.py /home/aperez/FE_status/FE_CERN_status.xml |grep -v None |grep CMS|sort |uniq >entries/entries_all_cores
#get number of pilots and qdate for running pilots

for i in $(for factory in vocms0805.cern.ch gfactory-1.t2.ucsd.edu:9614 cmsgwms-factory.fnal.gov glidein.grid.iu.edu; do condor_q -g -pool $factory -const '(GlideinFrontendName == "CMSG-v1_0:cmspilot") && (JobStatus==2)' -af QDate; done |sort); do date -d @$i -u +%D; done |uniq -c

#----------------
# Make plot
OUT="/crabprod/CSstoragePath/aperez/HTML/pilots_in_queue.html"
echo '<html>
<head>
<title>CMS multicore queued pilot status</title>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT
echo "  google.load('visualization', '1', {packages: ['corechart']});
        google.setOnLoadCallback(drawChart);
        function drawChart() {">>$OUT

#-----
echo "var data_queue_age = google.visualization.arrayToDataTable([
        ['number', 'age'],">>$OUT
j=1
while read -r line; do
        ivalue=$(echo $line |awk '{print int($1/3600)}')
        echo "  ['$j', $ivalue], " >>$OUT
        let j+=1
done</home/aperez/status/pilots_entered_queue_status

echo "]);
var options_queue_age = {
        title: 'Idle pilots queue time (h)',
        legend: { position: 'none' },
        colors: ['blue'],
        histogram: { hideBucketItems: 'True', bucketSize: 1 }
  };
var chart_queue_age = new google.visualization.Histogram(document.getElementById('chart_div_queue_age'));
chart_queue_age.draw(data_queue_age, options_queue_age);">>$OUT
#-----
echo '
    }
    </script>
</head>

<body>
    <div id="header">
        <h2>GLOBAL POOL IDLE MULTICORE PILOT queue time, updated at '$(date -u)'</h2><br>
    </div>
 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_queue_age" style="width: 1400px; height: 600px;"></div>'>>$OUT
echo "
</body>
</html>" >>$OUT
