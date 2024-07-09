list=$1

for site in `cat sites_$list`; do
	now=$(date) 
	echo "Starting with "$site" at "$now ;
	./make_html_usage_per_site.sh $site 2023/01/01 2024/01/01; 
	#./make_html_usage_per_site_allocated.sh $site 2019/01/01 2020/09/01; 
	done

ending=$(date)
echo "WORK COMPLETED!"
echo $ending

