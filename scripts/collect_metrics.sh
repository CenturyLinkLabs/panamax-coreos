#! /bin/sh


loadAvg="$(awk '{printf $1}' /proc/loadavg)"
memoryFree="$(gawk '( $1 == "MemFree:" ) { print $2*1024/1000000 }' /proc/meminfo)"
cpuIdle="$(top -b  -d 0.1 -n 2 | grep '^Cpu(s):' | tail -1 | awk -F"," '{print $4}'|sed 's/%.*//'i)"
curDate="$(date +'%Y/%m/%d %H:%M:%S')"
cpuCores="`nproc`"
etcdctl set /_panamax/host/metrics "{\"load_average\":\"${loadAvg}\", \"cpu_idle\": \"${cpuIdle}\", \"memory_free\":\"${memoryFree}\",\"cpu_cores\":\"${cpuCores}\",\"last_updated\":\"${curDate}\"}"

exit 0
