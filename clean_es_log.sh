#!/bin/bash
#set -ue

curator=`which curator`
host=''
log=/var/log/${0%.sh}/output.log

if [ -e $curator ] || [ ! -x $curator ] ; then echo 'curator not found'; exit 1; fi
if [ ! -w $log ]; then echo "log file $log not writable"; exit 1; fi

nc -vz -w 1 $host 9200 >$log 2>&1
if [ "$?" -ne "0" ]; then echo "elasticsearch at $host not accessable"; exit 1; fi

$curator --host $host delete --older-than 90 --prefix host_log_ --timestring %Y%m%d 2>$log || echo "failed delete" && exit 1
$curator --host $host close --older-than 31 --prefix host_log_ --timestring %Y%m%d 2>$log || echo "failed close" && exit 1
$curator --host $host optimize --older-than 2 --max_num_segments 1 --prefix host_log_ --timestring %Y%m%d 2>$log || echo "failed optime" && exit 1
