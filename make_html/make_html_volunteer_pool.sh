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
OUT=$OUTDIR"/HTML/"$long"volunteer_pool_size_"$int"h.html"

echo '<html>
<head>
<title>CMS Volunteer pool running glideins monitor</title>
<!--Load the AJAX API-->
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <script type="text/javascript">'>$OUT

echo "google.load('visualization', '1', {packages: ['corechart', 'line']});
google.setOnLoadCallback(drawChart);

function drawChart() {">>$OUT

#----------------------
#Pool size:
echo "var data_pool = new google.visualization.DataTable();	
data_pool.addColumn('datetime', 'Date');
data_pool.addColumn('number', 'Partitionable'); 
data_pool.addColumn('number', 'Static');

data_pool.addRows([">>$OUT
tail -n $n_lines $OUTDIR/out/Volunteer/pool_size |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/Volunteer_pool/input_pool_size$int
while read -r line; do
	time=$(echo $line |awk '{print $1}')
	let timemil=1000*$time
	content=$(echo $line |awk '{print $2", "$3}')
	echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/Volunteer_pool/input_pool_size$int
stats_size=$(python $WORKDIR/get_averages.py $WORKDIR/status/Volunteer_pool/input_pool_size$int)
rm $WORKDIR/status/Volunteer_pool/input_pool_size$int

echo "      ]);
var options_pool = {
	title: 'Volunteer pool running cores',
	isStacked: 'true',
	explorer: {},
	'height':500,
	colors: ['#0000A0', '#1569C7'],
	hAxis: {title: 'Time'},
	vAxis: {title: 'Number of cores'}
	};

var chart_pool = new google.visualization.AreaChart(document.getElementById('chart_div_pool'));
chart_pool.draw(data_pool, options_pool);">>$OUT

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
        <h2>CMS VOLUNTEER POOL MONITOR: CMS@Home pool size and components for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/volunteer_pool_size_24h.html">24h</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/volunteer_pool_size_168h.html">1week</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longvolunteer_pool_size_720h.html">1, </a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longvolunteer_pool_size_2160h.html">3, </a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longvolunteer_pool_size_4320h.html">6, </a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longvolunteer_pool_size_6480h.html">9, </a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longvolunteer_pool_size_8640h.html">12 months</a>
	<br><br>
        

        <br>Ganglia monitoring for 
	<a href="http://hcc-ganglia.unl.edu/?r=hour&cs=&ce=&c=crab-infrastructure&h='$($WORKDIR/collector_volunteer.sh)'&tab=m&vn=&hide-hf=false&m=load_report&sh=1&z=small&hc=4&host_regex=&max_graphs=0&s=by+name" target="blank"> CM at CERN</a>
	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/pool_negotime_24h.html" target="blank">Negotiation cycle monitor</a>
	<br>
	<br>
	</h2>
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_pool"></div><p>'$(echo "[avg, min, max]: " $stats_size)'</p><br><br>'>>$OUT

echo "
</body>
</html>" >>$OUT
