#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

ratio=1
if [[ $int -gt "720" ]]; then ratio=2; fi # more than 1 month
if [[ $int -gt "1440" ]]; then ratio=3; fi # more than 2 months
if [[ $int -gt "2880" ]]; then ratio=4; fi # more than 4 months
if [[ $int -gt "4320" ]]; then ratio=6; fi # more than 6 months

OUT="/crabprod/CSstoragePath/aperez/HTML/"$long"pool_negotime_"$int"h.html"
echo '<html>
<head>
<title>CMS global pool negotiator cycle time</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS T0; do
	echo "var data_$neg = new google.visualization.DataTable();	
	data_$neg.addColumn('datetime', 'Date');
      	data_$neg.addColumn('number', 'Collecting'); 
	data_$neg.addColumn('number', 'Filtering');
	data_$neg.addColumn('number', 'Sorting'); 
        data_$neg.addColumn('number', 'Matching');
	data_$neg.addRows([">>$OUT
	tail -n $n_lines /crabprod/CSstoragePath/aperez/out/negotime_$neg|awk -v var="$ratio" 'NR % var == 0' >/home/aperez/status/input_$neg$int
	while read -r line; do
		time=$(echo $line |awk '{print $1}')
		let timemil=1000*$time

		if [[ $(echo $line |awk '{print $2}') != "" ]] && [[ $(echo $line |awk '{print $3}') != "" ]]; then
			content=$(echo $line |awk '{print $2", "$3", "$4", "$5}')
        	else
                	content="0, 0, 0, 0"
        	fi
		echo "[new Date($timemil), $content], " >>$OUT
	done </home/aperez/status/input_$neg$int
	list=$(python /home/aperez/get_averages.py /home/aperez/status/input_$neg$int)
	declare "stats_$neg=$(echo $list)"
	rm /home/aperez/status/input_$neg$int

	echo "      ]);

        var options_$neg = {
                title: '$neg cycle time',
                isStacked: 'true',
        	explorer: {},
                'height':500,
		colors: ['#0040FF', '#FFFF00', '#FF8000', '#00FF00'],
                hAxis: {title: 'Time'},
                vAxis: {title: 'Time spent in nego phase'}
        };

      	var chart_$neg = new google.visualization.AreaChart(document.getElementById('chart_div_$neg'));
      	chart_$neg.draw(data_$neg, options_$neg);">>$OUT
done

#----------------------
#Schedds dropped by the negotiators:
echo "var data_sch = new google.visualization.DataTable();     
data_sch.addColumn('datetime', 'Date');
data_sch.addColumn('number', 'Dropped schedds'); 

data_sch.addRows([">>$OUT
tail -n $n_lines /crabprod/CSstoragePath/aperez/out/schedds_out_time >/home/aperez/status/input_schedoot$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	let n_sch=$(echo $line |wc -w)-1
	#echo $n_sch
        echo "[new Date($timemil), $n_sch], " >>$OUT
done </home/aperez/status/input_schedoot$int
stats_size=$(python /home/aperez/get_averages.py /home/aperez/status/input_schedoot$int)
rm /home/aperez/status/input_schedoot$int

echo "      ]);
var options_sch = {
        title: 'Global pool negotiation cycle dropped (timeout) schedds ',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0000A0', '#1569C7'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of schedds'}
        };

var chart_sch = new google.visualization.AreaChart(document.getElementById('chart_sch'));
chart_sch.draw(data_sch, options_sch);">>$OUT

#----------------------

echo '
    }

    </script>
<style>
p {text-align: center;
   font-family: verdana;
        }
</style>
</head>

<body>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/pool_negotime_24h.html">24h</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/pool_negotime_168h.html">1week</a>
<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longpool_negotime_720h.html">1month</a>
<br>
 <!--Div to hold the charts-->'>>$OUT

for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS T0; do
	var="stats_$neg"
        echo ' <div id="chart_div_'$neg'"></div><p>'$(echo "[avg, min, max]: " "${!var}")'</p><br><br>'
done>>$OUT
echo ' <div id="chart_sch"></div><p>'$(echo "[avg, min, max]: " $stats_sch)'</p><br><br>'>>$OUT

echo "
Notes on negotiation phases from HTCondor <a href="http://research.cs.wisc.edu/htcondor/manual/v8.7/13_Appendix_A.html" target="blank">manual</a>:
<br>
LastNegotiationCyclePhase1Duration: The duration, in seconds, of Phase 1 of the negotiation cycle: the process of getting submitter and machine ClassAds from the condor_collector. 
<br>
LastNegotiationCyclePhase2Duration: The duration, in seconds, of Phase 2 of the negotiation cycle: the process of filtering slots (by NEGOTIATOR_SLOT_POOLSIZE_CONSTRAINT) and processing accounting group configuration. 
<br>
LastNegotiationCyclePhase3Duration: The duration, in seconds, of Phase 3 of the negotiation cycle: sorting submitters by priority. 
<br>
LastNegotiationCyclePhase4Duration: The duration, in seconds, of Phase 4 of the negotiation cycle: the process of matching slots to jobs in conjunction with the schedulers. 
<br>
</body>
</html>" >>$OUT
