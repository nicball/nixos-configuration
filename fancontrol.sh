intake=/sys/devices/platform/nct6687.2592/hwmon/hwmon*/pwm5
outtake=/sys/devices/platform/nct6687.2592/hwmon/hwmon*/pwm3
gputemp=/sys/devices/pci0000:00/0000:00:01.1/0000:01:00.0/hwmon/hwmon*/temp1_input
cputemp=/sys/devices/pci0000:00/0000:00:18.3/hwmon/hwmon*/temp3_input

autoctl() {
  echo 99 > ${intake}_enable
  echo 99 > ${outtake}_enable
}

trap autoctl EXIT

echo 1 > ${intake}_enable
echo 1 > ${outtake}_enable

while true; do
  tg=$(( $(cat $gputemp) / 1000 ))
  tc=$(( $(cat $cputemp) / 1000 ))
  input=$(( tg > tc ? tg : tc ))
  output=$(( input >= 80 ? (128 + (input - 80) * (255 - 128) / (100 - 80)) :
             input >= 60 ? (50 + (input - 60) * (128 - 50) / (80 - 60)) :
             50 ))
  echo $output > $intake
  echo $output > $outtake
  sleep 5
done
