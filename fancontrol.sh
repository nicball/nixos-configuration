enable sleep

histlen=5
interval=5

intake=/sys/devices/platform/nct6687.2592/hwmon/hwmon*/pwm5
outtake=/sys/devices/platform/nct6687.2592/hwmon/hwmon*/pwm3
gputemp=/sys/devices/pci0000:00/0000:00:01.1/0000:01:00.0/hwmon/hwmon*/temp1_input
cputemp=/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp3_input

autoctl() {
  echo 99 > ${intake}_enable
  echo 99 > ${outtake}_enable
}

trap autoctl EXIT

avg() {
  local len=$#
  local sum=0
  local i
  for i; do
    sum=$(( sum + i ))
  done
  echo $(( sum / len ))
}

echo 1 > ${intake}_enable
echo 1 > ${outtake}_enable

hist=()

while true; do
  currg=$(( $(cat $gputemp) / 1000 ))
  currc=$(( $(cat $cputemp) / 1000 ))
  max=$(( currg > currc ? currg : currc ))
  hist=( ${hist[@]} $max )
  if [[ ${#hist[@]} -gt $histlen ]]; then
    hist=( ${hist[@]: -$histlen} )
  fi
  temp=$(avg ${hist[@]})
  speed=$(( temp >= 60 ? ((temp - 60) * 255 / (100 - 60)) : 0 ))
  echo $speed > $intake
  echo $speed > $outtake
  sleep $interval
done
