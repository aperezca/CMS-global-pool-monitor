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

WORKDIR="/home/aperez"
OUTDIR="/crabprod/CSstoragePath/aperez"

OUT=$OUTDIR"/HTML/"$long"volunteer_pool_collector_"$int"h.html"
echo '<html>
<head>
<title>CMS Volunteer pool collector metrics</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

# Collector attrs being recorded:
# -------------------------------
# ActiveQueryWorkers PendingQueries RecentDroppedQueries 
# RecentDaemonCoreDutyCycle 
# RecentForkQueriesFromNEGOTIATOR RecentForkQueriesFromTOOL 
# RecentUpdatesTotal RecentUpdatesLost 
# SubmitterAds

#-------------
tail -n $n_lines $OUTDIR/out/collector_volunteer_pool|awk -v var="$ratio" 'NR % var == 0' |sort >$WORKDIR/status/input_volunteer_collector$int

# -------------------------------
# CoreDutyCycle in collector
echo "var data_dutycycle = new google.visualization.DataTable();
data_dutycycle.addColumn('datetime', 'Date');
data_dutycycle.addColumn('number', 'RecentCoreDutyCycle');

data_dutycycle.addRows([">>$OUT
while read -r line; do
	if [[ $(echo $line |wc -w ) -eq 1 ]]; then continue; fi
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $5}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_volunteer_collector$int

echo "      ]);
var options_dutycycle = {
        title: 'Collector RecentCoreDutyCycle',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#0040FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'dutycycle'}
        };

var chart_dutycycle = new google.visualization.AreaChart(document.getElementById('chart_div_dutycycle'));
chart_dutycycle.draw(data_dutycycle, options_dutycycle);">>$OUT

# -------------------------------
# RecentUpdatesTotal RecentUpdatesLost
echo "var data_updates = new google.visualization.DataTable();     
data_updates.addColumn('datetime', 'Date');
data_updates.addColumn('number', 'Total'); 
data_updates.addColumn('number', 'Lost'); 

data_updates.addRows([">>$OUT
while read -r line; do
	if [[ $(echo $line |wc -w ) -eq 1 ]]; then continue; fi
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $8", "$9}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_volunteer_collector$int

echo "      ]);
var options_updates = {
        title: 'Updates to the Collector',
        isStacked: 'false',
        explorer: {},
	lineWidth: 6,
        'height':500,
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of updates'}
        };

var chart_updates = new google.visualization.LineChart(document.getElementById('chart_div_updates'));
chart_updates.draw(data_updates, options_updates);">>$OUT

# -------------------------------
# ActiveQueryWorkers PendingQueries RecentDroppedQueries
echo "var data_queries = new google.visualization.DataTable();     
data_queries.addColumn('datetime', 'Date');
data_queries.addColumn('number', 'Active'); 
data_queries.addColumn('number', 'Pending'); 
data_queries.addColumn('number', 'Dropped'); 

data_queries.addRows([">>$OUT
while read -r line; do
	if [[ $(echo $line |wc -w ) -eq 1 ]]; then continue; fi
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$3", "$4}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_volunteer_collector$int

echo "      ]);
var options_queries = {
        title: 'Queries on the Collector',
        isStacked: 'false',
        explorer: {},
	lineWidth: 6,
        'height':500,
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of queries'}
        };

var chart_queries = new google.visualization.LineChart(document.getElementById('chart_div_queries'));
chart_queries.draw(data_queries, options_queries);">>$OUT

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

    <div id="header">
        <h2>CMS Volunteer (CMS@Home) pool collector metrics monitor for the last '$int' hours, updated at '$(date -u)'<br>
        <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/volunteer_pool_collector_24h.html">24h</a>
        <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/volunteer_pool_collector_168h.html">1week</a>
        <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longvolunteer_pool_collector_720h.html">1month</a>
        <br><br>
        </h2>
    </div>

<br>
 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_dutycycle"></div></p><br><br>'>>$OUT
echo ' <div id="chart_div_updates"></div><br><br>'>>$OUT
echo ' <div id="chart_div_queries"></div><br><br>'>>$OUT
echo "
</body>
</html>" >>$OUT
