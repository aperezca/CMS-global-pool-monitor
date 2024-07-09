# Killing stuck monitoring processes!
for pid in `ps faux |grep aperezca |grep queries |grep html_jobs |awk '{print $2}'`; do echo $pid; kill $pid; done
for pid in `ps faux |grep aperezca |grep queries |grep html_long |awk '{print $2}'`; do echo $pid; kill $pid; done
for pid in `ps faux |grep aperezca |grep queries |grep html_pool |awk '{print $2}'`; do echo $pid; kill $pid; done
for pid in `ps faux |grep aperezca |grep queries |grep html_t1s |awk '{print $2}'`; do echo $pid; kill $pid; done
for pid in `ps faux |grep aperezca |grep queries |grep html_t2s |awk '{print $2}'`; do echo $pid; kill $pid; done
for pid in `ps faux |grep aperezca |grep queries |grep html_t3s |awk '{print $2}'`; do echo $pid; kill $pid; done
for pid in `ps faux |grep aperezca |grep queries |grep long |awk '{print $2}'`; do echo $pid; kill $pid; done
for pid in `ps faux |grep aperezca |grep queries |grep schedd |awk '{print $2}'`; do echo $pid; kill $pid; done
for pid in `ps faux |grep aperezca |grep queries |grep monitor_html_week.sh |awk '{print $2}'`; do echo $pid; kill $pid; done
