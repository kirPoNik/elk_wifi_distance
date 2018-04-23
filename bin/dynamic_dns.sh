#! /bin/bash

installed=`grep "##dynamic" /etc/nginx/nginx.conf  | awk -F"##" '{print $1}'`
curr1=`dig hqsvm.no-ip.info +short`
curr2=`dig hqmataro.no-ip.info +short`

match1=`echo "$installed" |  grep $curr1 &>/dev/null`
exit_code_m1=$?
match1=`echo "$installed" | grep $curr2 &>/dev/null`
exit_code_m2=$?


if [[ $exit_code_m1 != "0"  || $exit_code_m2 != "0" ]];
then
	#echo "updating"
	out=`sed -i "s/$installed##dynamic/\t\tallow $curr1;allow $curr2; ##dynamic/g" /etc/nginx/nginx.conf`
	exit_code=$?
	if [[ $exit_code == "0" ]]; then
		nginx -s reload
	fi
fi
