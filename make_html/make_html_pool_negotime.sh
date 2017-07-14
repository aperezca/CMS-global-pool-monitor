#Interval to plot in hours
int=$1
let n_lines=6*$int
if [[ $int -gt "168" ]]; then  #put plots longer than one week at another location
	long="long"
else
	long=""
fi

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

for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS; do
	echo "var data_$neg = new google.visualization.DataTable();	
	data_$neg.addColumn('datetime', 'Date');
      	data_$neg.addColumn('number', 'Collecting'); 
	data_$neg.addColumn('number', 'Filtering');
	data_$neg.addColumn('number', 'Sorting'); 
        data_$neg.addColumn('number', 'Matching');
	data_$neg.addRows([">>$OUT
	tail -n $n_lines /crabprod/CSstoragePath/aperez/out/negotime_$neg >/home/aperez/status/input_$neg$int
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
	#stats_$neg=$(python /home/aperez/get_averages.py /home/aperez/status/input_$neg$int)
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

for neg in NEGOTIATORT1 NEGOTIATOR NEGOTIATORUS; do
	var="stats_$neg"
        echo ' <div id="chart_div_'$neg'"></div><p>'$(echo "[avg, min, max]: " "${!var}")'</p><br><br>'
done>>$OUT

echo "
Notes on negotiation phases from HTCondor <a href="http://research.cs.wisc.edu/htcondor/manual/v8.7/13_Appendix_A.html" target="blank">manual</a>:
<br>
LastNegotiationCyclePhase1Duration: The duration, in seconds, of Phase 1 of the negotiation cycle: the process of getting submitter and machine ClassAds from the condor_collector. 
<br>
LastNegotiationCyclePhase2Duration: The duration, in seconds, of Phase 2 of the negotiation cycle: the process of filtering slots and processing accounting group configuration. 
<br>
LastNegotiationCyclePhase3Duration: The duration, in seconds, of Phase 3 of the negotiation cycle: sorting submitters by priority. 
<br>
LastNegotiationCyclePhase4Duration: The duration, in seconds, of Phase 4 of the negotiation cycle: the process of matching slots to jobs in conjunction with the schedulers. 
<br>
</body>
</html>" >>$OUT
