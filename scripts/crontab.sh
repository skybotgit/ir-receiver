#!/bin/bash

setCrons(){
    crontmp=/tmp/cron.skybot
    echo "@reboot /opt/ir-receiver/scripts/init.sh >>/dev/null 2>&1" >> $crontmp

    sudo crontab $crontmp
    sudo rm $crontmp
}
setCrons
echo "Crons setup successfully"