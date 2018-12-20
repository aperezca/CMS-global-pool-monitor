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
OUT=$OUTDIR"/HTML/"$long"global_pool_size_"$int"h.html"

echo '<html>
<head>
<title>CMS global pool running glideins monitor</title>
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
tail -n $n_lines $OUTDIR/out/pool_size |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_pool_size$int
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
tail -n $n_lines $OUTDIR/out/pool_idle |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_pool_idle$int
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
data_pooleff.addColumn('number', 'score occupation');
data_pooleff.addColumn('number', 'pool occupation');

data_pooleff.addRows([">>$OUT
tail -n $n_lines $OUTDIR/out/pool_idle |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_pool_idle$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	#correct for HLT slots!
	m_b=$(echo $line |awk '{print $2-$6}')
	m_i=$(echo $line |awk '{print $3-$7}')
	s_b=$(echo $line |awk '{print $4}')
	s_i=$(echo $line |awk '{print $5}')
	if [[ $m_b+$m_i -ne 0 ]] && [[ $s_b+$s_i -ne 0 ]]; then
		content=$(echo $m_b $m_i $s_b $s_i |awk '{print $3/($3+$4)", "($1+$3)/($1+$2+$3+$4)}')
		#content=$(echo $m_b $m_i $s_b $s_i |awk '{print $1/($1+$2)", "$3/($3+$4)", "($1+$3)/($1+$2+$3+$4)}')
		echo "[new Date($timemil), $content], " >>$OUT
	fi
done <$WORKDIR/status/input_pool_idle$int
rm $WORKDIR/status/input_pool_idle$int

echo "      ]);
var options_pooleff = {
        title: 'Global pool pilot occupation percentages',
        isStacked: 'false',
        explorer: {},
        'height':500,
	colors: ['#000000', '#0060FF'],
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
tail -n $n_lines $OUTDIR/out/pool_mcoreidle |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_pool_mcoreidle$int
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
tail -n $n_lines $OUTDIR/out/frontend_full |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_FE_full$int
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
# Running jobs in pool by type:
echo "var data_jobs = new google.visualization.DataTable();
data_jobs.addColumn('datetime', 'Date');
data_jobs.addColumn('number', 'Prod jobs');
data_jobs.addColumn('number', 'Analysis jobs');
data_jobs.addColumn('number', 'Tier0 jobs');

data_jobs.addRows([">>$OUT
tail -n $n_lines $OUTDIR/out/jobs_running_global |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_jobs_running_global$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time
	if [[ $(echo $line |wc -w) -eq 4 ]]; then
		content=$(echo $line |awk '{print $2", "$3", "$4}')
	else
		content=$(echo $line |awk '{print $2", "$3", 0"}')
	fi
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_jobs_running_global$int
stats_jobs=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobs_running_global$int)
rm $WORKDIR/status/input_jobs_running_global$int

echo "      ]);
var options_jobs = {
        title: 'Global and T0 pool running production and analysis job cores',
        isStacked: 'true',
        explorer: {},
        'height':500,
	colors: ['#1569C7', '#52D017', '#ff8553'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_jobs = new google.visualization.AreaChart(document.getElementById('chart_div_jobs'));
chart_jobs.draw(data_jobs, options_jobs);">>$OUT

#---------------------------
# Running jobs in pool by type and Tier 0, 1 and 2:
echo "var data_jobstier = new google.visualization.DataTable();
data_jobstier.addColumn('datetime', 'Date');
data_jobstier.addColumn('number', 'T0 Prod jobs');
data_jobstier.addColumn('number', 'T0 Analysis jobs');
data_jobstier.addColumn('number', 'T0 Tier0 jobs');
data_jobstier.addColumn('number', 'T1 Prod jobs');
data_jobstier.addColumn('number', 'T1 Analysis jobs');
data_jobstier.addColumn('number', 'T1 Tier0 jobs');
data_jobstier.addColumn('number', 'T2 Prod jobs');
data_jobstier.addColumn('number', 'T2 Analysis jobs');
data_jobstier.addColumn('number', 'T2 Tier0 jobs');

data_jobstier.addRows([">>$OUT
tail -n $n_lines $OUTDIR/out/jobs_running_T0AndGlobalPool |awk -v var="$ratio" 'NR % var == 0'>$WORKDIR/status/input_jobstier_running_global$int
while read -r line; do
        time=$(echo $line |awk '{print $1}')
        let timemil=1000*$time

        if [[ $(echo $line |wc -w) -eq 10 ]]; then
                content=$(echo $line |awk '{print $2", "$3", "$4", "$5", "$6", "$7", "$8", "$9", "$10}')
        else
		content=$(echo $line |awk '{print $2", "$3", 0, "$4", "$5", 0, "$6", "$7", 0"}')
        fi
        #content=$(echo $line |awk '{print $2", "$4", "$5", "$6", "$7}')
        echo "[new Date($timemil), $content], " >>$OUT
done <$WORKDIR/status/input_jobstier_running_global$int
stats_jobstier=$(python $WORKDIR/get_averages.py $WORKDIR/status/input_jobstier_running_global$int)
rm $WORKDIR/status/input_jobstier_running_global$int

# colors: ['#FACC2E', '#4060C7', '#6060C7', '#70D017', '#90D017'],
echo "      ]);
var options_jobstier = {
        title: 'Running jobs cores at T0+T1s+T2s for production and analysis',
        isStacked: 'true',
        explorer: {},
        'height':500,
        colors: ['#1569C7', '#52D017', '#ff8553', '#1569C7', '#52D017', '#ff8553', '#1569C7', '#52D017', '#ff8553'],
        hAxis: {title: 'Time'},
        vAxis: {title: 'Number of cores'}
        };

var chart_jobstier = new google.visualization.AreaChart(document.getElementById('chart_div_jobstier'));
chart_jobstier.draw(data_jobstier, options_jobstier);">>$OUT

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
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/global_pool_size_24h.html">24h</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/global_pool_size_168h.html">1week</a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longglobal_pool_size_720h.html">1, </a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longglobal_pool_size_2160h.html">3, </a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longglobal_pool_size_4320h.html">6, </a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longglobal_pool_size_6480h.html">9, </a>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/longglobal_pool_size_8640h.html">12 months</a>
	<br><br>
        
	See also:
	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/jobstatus_'$int'h.html" target="blank">Time evolution of job metrics in the global pool</a>
	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/Schedds/schedd_status_index.html" target="blank">Schedds status</a>
	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/Monitor/latest-new.txt" target="blank">Summary table for the current global pool status</a> and
        <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/globalpool_pilot_info.txt" target="blank">currently running pilots and slots in the pool</a>
	
	<br><br>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/globalpool_all_running_jobs.txt" target="blank">Summary of currently running jobs</a> and
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/globalpool_all_queued_jobs.txt" target="blank">queued jobs</a> in the pool
	<br>
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/globalpool_jobs_info.txt" target="blank">Additional performance metrics for running jobs</a> and 
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/globalpool_running_jobs.txt" target="blank">summary of running jobs with site info</a><br>

        <br>Ganglia monitoring for 
	<a href="http://hcc-ganglia.unl.edu/?r=hour&cs=&ce=&c=crab-infrastructure&h='$($WORKDIR/collector.sh)'&tab=m&vn=&hide-hf=false&m=load_report&sh=1&z=small&hc=4&host_regex=&max_graphs=0&s=by+name" target="blank"> CM at CERN</a> and
	<a href="http://hcc-ganglia.unl.edu/?r=hour&cs=&ce=&c=crab-infrastructure&h=cmssrv221.fnal.gov&tab=m&vn=&hide-hf=false&m=load_report&sh=1&z=small&hc=4&host_regex=&max_graphs=0&s=by+name" target="blank"> CM at FNAL</a> 
	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/pool_negotime_24h.html" target="blank">Negotiation cycle monitor</a>
	<br>
	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/global_pool_fragment_24h.html" target="blank">Pool fragmentation</a>
	<br>
	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T1s/multicore_usage_t1s_24h.html" target="blank">T1 mcore pilots</a> and
	<a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/jobstatus_T1_24h.html" target="blank"> jobs</a>

	<br><a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/T2s/multicore_usage_t2s_24h.html" target="blank">T2 mcore pilots</a> and
        <a href="http://submit-3.t2.ucsd.edu/CSstoragePath/aperez/HTML/JobInfo/jobstatus_T2_24h.html" target="blank"> jobs</a>

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
echo ' <div id="chart_div_jobs"></div><p>'$(echo "[avg, min, max]: " $stats_jobs)'</p><br><br>'>>$OUT
echo ' <div id="chart_div_jobstier"></div><p>'$(echo "[avg, min, max]: " $stats_jobstier)'</p><br><br>'>>$OUT

echo "
</body>
</html>" >>$OUT
