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

source /data/srv/aperezca/Monitoring/env_itb.sh
OUT=$HTMLDIR/$long"itb_pool_size_"$int"h.html"
#---------------------
echo '<html>
<head>
<title>CMS ITB pool running glideins monitor</title>
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
data_pool.addColumn('number', 'T1 mcore'); 
data_pool.addColumn('number', 'T2 mcore');
data_pool.addColumn('number', 'T2 score');
data_pool.addColumn('number', 'T3 score');

data_pool.addRows([">>$OUT
tail -n $n_lines $OUTDIR/pool_size |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_pool_size$int
while read -r line; do
	time=$(echo $line |awk '{print $1}')
	let timemil=1000*$time
	content=$(echo $line |awk '{print $2", "$3", "$4", "$5}')
	echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_pool_size$int
stats_size=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_pool_size$int)
rm $WORKDIR/status/input_pool_size$int

echo "      ]);
var options_pool = {
	title: 'Global pool running cores',
	isStacked: 'true',
	explorer: {},
	'height':500,
	colors: ['#0000A0', '#1569C7', '#52D017', '#B2C248'],
	hAxis: {title: 'Time'},
	vAxis: {title: 'Number of cores'}
	};

var chart_pool = new google.visualization.AreaChart(document.getElementById('chart_div_pool'));
chart_pool.draw(data_pool, options_pool);">>$OUT

#----------------------
#Pool busy and idle cores:
echo "var data_poolidle = new google.visualization.DataTable();     
data_poolidle.addColumn('datetime', 'Date');
data_poolidle.addColumn('number', 'mcore busy'); 
data_poolidle.addColumn('number', 'score busy');
data_poolidle.addColumn('number', 'mcore idle');
data_poolidle.addColumn('number', 'score idle');

data_poolidle.addRows([">>$OUT
tail -n $n_lines $OUTDIR/pool_idle |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_pool_idle$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
        content=$(echo $line |awk '{print $2", "$4", "$3", "$5}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_pool_idle$int
stats_idle=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_pool_idle$int)
rm $WORKDIR/status/input_pool_idle$int

echo "      ]);
var options_poolidle = {
        title: 'Global pool busy and idle cores per type of pilot',
        isStacked: 'true',
        explorer: {},
        'height':500,
	colors: ['#0040FF', '#0060FF', '#FF0000', '#FF3000'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_poolidle = new google.visualization.AreaChart(document.getElementById('chart_div_poolidle'));
chart_poolidle.draw(data_poolidle, options_poolidle);">>$OUT

#----------------------
#Pool usage efficiencies:
echo "var data_pooleff = new google.visualization.DataTable();     
data_pooleff.addColumn('datetime', 'Date');
data_pooleff.addColumn('number', 'pool occupation');

data_pooleff.addRows([">>$OUT
tail -n $n_lines $OUTDIR/pool_idle |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_pool_idle$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	#correct for HLT slots!
	m_b=$(echo $line |awk '{print $2-$6}')
	m_i=$(echo $line |awk '{print $3-$7}')
	s_b=$(echo $line |awk '{print $4}')
	s_i=$(echo $line |awk '{print $5}')
	if [[ $m_b+$m_i -ne 0 ]] && [[ $s_b+$s_i -ne 0 ]]; then
		content=$(echo $m_b $m_i $s_b $s_i |awk '{print ($1+$3)/($1+$2+$3+$4)}')
		#content=$(echo $m_b $m_i $s_b $s_i |awk '{print $1/($1+$2)", "$3/($3+$4)", "($1+$3)/($1+$2+$3+$4)}')
	else
		content=$(echo "0")
	fi
	echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_pool_idle$int
rm $WORKDIR/status/input_pool_idle$int

echo "      ]);
var options_pooleff = {
        title: 'ITB pool pilot occupation percentages',
        isStacked: 'false',
        explorer: {},
        'height':500,
	colors: ['#0060FF'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Occupation (%)', minValue: 0, maxValue: 1}
        };

var chart_pooleff = new google.visualization.AreaChart(document.getElementById('chart_div_pooleff'));
chart_pooleff.draw(data_pooleff, options_pooleff);">>$OUT

#----------------------
#Idle cores in mcore pilots:
echo "var data_mcoreidle = new google.visualization.DataTable();
data_mcoreidle.addColumn('datetime', 'Date');
data_mcoreidle.addColumn('number', 'retiring');
data_mcoreidle.addColumn('number', 'memory');
data_mcoreidle.addColumn('number', 'idle unclaimed');
data_mcoreidle.addColumn('number', 'idle claimed');

data_mcoreidle.addRows([">>$OUT
tail -n $n_lines $OUTDIR/pool_mcoreidle |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_pool_mcoreidle$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	if [[ $(echo $line |awk '{print $5}') != "" ]]; then
        	content=$(echo $line |awk '{print $2", "$3", "$4", "$5}')
	else
		content=$(echo $line |awk '{print $2", "$3", "$4", 0"}')
	fi
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_pool_mcoreidle$int
stats_mcoreidle=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_pool_mcoreidle$int)
rm $WORKDIR/status/input_pool_mcoreidle$int

echo "      ]);
var options_mcoreidle = {
        title: 'Global pool idle cores in multicore pilots: past retire time, not enough memory, usable claimed and unclaimed',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#FF4000', '#FF8000', '#FF0000', '#FF0040'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_mcoreidle = new google.visualization.AreaChart(document.getElementById('chart_div_mcoreidle'));
chart_mcoreidle.draw(data_mcoreidle, options_mcoreidle);">>$OUT

#---------------------------
#FrontEnd pressure on the pool (new requested idle):
echo "var data_FE = new google.visualization.DataTable();     
data_FE.addColumn('datetime', 'Date');
data_FE.addColumn('number', 'T1_t1prod');
data_FE.addColumn('number', 'T1_main');
data_FE.addColumn('number', 'T2_main_mcore');
data_FE.addColumn('number', 'T2_main_score');
data_FE.addColumn('number', 'T3_main_score');

data_FE.addRows([">>$OUT
tail -n $n_lines $OUTDIR/frontend_full |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_FE_full$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	if [[ $(echo $line |awk '{print $2}') != "" ]] && [[ $(echo $line |awk '{print $3}') != "" ]]; then
        	content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6}')
	else
		content="0, 0, 0, 0, 0"
	fi
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_FE_full$int
stats_FE=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_FE_full$int)
rm $WORKDIR/status/input_FE_full$int

echo "      ]);
var options_FE = {
        title: 'Global pool FE pressure in requested_idle_glideins X N_cores',
        isStacked: 'true',
        explorer: {},
        'height':500,
	colors: ['#0000A0', '#6060A0', '#1569C7', '#52D017', '#B2C248'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_FE = new google.visualization.AreaChart(document.getElementById('chart_div_FE'));
chart_FE.draw(data_FE, options_FE);">>$OUT

#---------------------------

#----------
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
        <h2>CMS GLOBAL POOL MONITOR: Global pool size and components for the last '$int' hours, updated at '$(date -u)'<br>
	<a href="'$WEBPATH'itb_pool_size_24h.html">24h</a>
	<a href="'$WEBPATH'itb_pool_size_168h.html">1week</a>
	<a href="'$WEBPATH'longitb_pool_size_720h.html">1, </a>
	<a href="'$WEBPATH'longgitb_pool_size_2160h.html">3, </a>
	<a href="'$WEBPATH'longitb_pool_size_4320h.html">6, </a>
	<a href="'$WEBPATH'longitb_pool_size_6480h.html">9, </a>
	<a href="'$WEBPATH'longitb_pool_size_8640h.html">12 months</a>
	<br><br>
        
	See also:
	<br><a href="'$WEBPATH'jobstatus_'$int'h.html" target="blank">Time evolution of job metrics in the global pool</a>
	<br><a href="'$WEBPATH'Schedds/schedd_status_index.html" target="blank">Schedds status</a>
        <a href="'$WEBPATH'globalpool_pilot_info.txt" target="blank">currently running pilots and slots in the pool</a>
	
	<br><br>
	<a href="'$WEBPATH'JobInfo/globalpool_all_running_jobs.txt" target="blank">Summary of currently running jobs</a> and
	<a href="'$WEBPATH'JobInfo/globalpool_all_queued_jobs.txt" target="blank">queued jobs</a> in the pool
	<br>
	<a href="'$WEBPATH'JobInfo/globalpool_jobs_info.txt" target="blank">Additional performance metrics for running jobs</a> and 
	<a href="'$WEBPATH'JobInfo/globalpool_running_jobs.txt" target="blank">summary of running jobs with site info</a><br>

        <br>Ganglia monitoring for
	<a href="http://vocms0801.cern.ch/ganglia/?r=day&cs=&ce=&m=load_one&c=VOCMS&h='$($WORKDIR/collector_itb.sh)'&tab=m&vn=&hide-hf=false&mc=2&z=small&metric_group=ALLGROUPS" target="blank"> CM at CERN</a> 
	<br><a href="'$WEBPATH'pool_negotime_24h.html" target="blank">Negotiation cycle monitor</a>
	<br>
	<br><a href="'$WEBPATH'global_pool_fragment_24h.html" target="blank">Pool fragmentation</a>
	<br>
	</h2>
	<br>
    </div>
<br>

 <!--Div to hold the charts-->'>>$OUT
echo ' <div id="chart_div_pool"></div><p>'$(echo "[avg, min, max]: " $stats_size)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_poolidle"></div><p>'$(echo "[avg, min, max]: " $stats_idle)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_pooleff"></div><br><br>'>>$OUT
echo ' <div id="chart_div_mcoreidle"></div><p>'$(echo "[avg, min, max]: " $stats_mcoreidle)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_FE"></div><p>'$(echo "[avg, min, max]: " $stats_FE)'</p><br><br>'>>$OUT

echo "
</body>
</html>" >>$OUT
