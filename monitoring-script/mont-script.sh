#!/bin/bash
cpuuse=$(cat /proc/loadavg | awk '{print $1}')

if [ "$cpuuse" > 80 ]; then
echo "CPU Current Usage is: $cpuuse%" 
fi

df -Ph | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5,$1 }' | while read output;
do
  echo $output
  used=$(echo $output | awk '{print $1}' | sed s/%//g)
  partition=$(echo $output | awk '{print $2}')
  if [ $used -ge 80 ]; then
  echo "The partition \"$partition\" on $(hostname) has used $used% at $(date)"
  fi
done

ramusage=$(free | awk '/Mem/{printf("RAM Usage: %.2f\n"), $3/$2*100}'| awk '{print $3}')
echo "Memory Current Usage is: $ramusage%" 


