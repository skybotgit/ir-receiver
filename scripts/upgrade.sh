#!/usr/bin/env bash

SAMPLE_COMMAND='`sh upgrade.sh {s3url - https://s3-ap-south-1.amazonaws.com/skybot-ir-binaries/debug/build_ir.tar.gz }`'
if [ "$#" -ne 1 ]; then
    echo "Invalid arguments passed"
    echo 'Sample Command :'$SAMPLE_COMMAND
    exit
fi
S3URL=$1
GITHUB_PATH='https://github.com/skybotgit/ir-receiver.git'
WORKPLACE=/opt/workplace
DIR=/opt/ir-receiver
DEPLOY_PATH=/opt/bin
UPGRADE='false'
TYPE='release'

sudo rm -Rf $WORKPLACE
sudo mkdir -p $WORKPLACE
cd $WORKPLACE
sudo wget $S3URL
sudo tar -zxvf build_ir.tar.gz ./
sudo rm build_ir.tar.gz

cd $DIR

sudo git reset --hard

status=$(sudo git pull origin)
if [ "$status" == error:* ]; then
    echo $status
    exit
fi

sudo supervisorctl stop all >> /dev/null
sudo rm -Rf /etc/supervisor/conf.d/*.conf
sudo cp -Rf $DIR/scripts/etc/supervisor/conf.d/* /etc/supervisor/conf.d/
sudo rm -Rf $DEPLOY_PATH
sudo mkdir -p $DEPLOY_PATH
sudo cp -Rf $WORKPLACE/bin/* $DEPLOY_PATH
sudo cp -Rf $DIR/template.conf $DEPLOY_PATH
sudo chown -Rf 0777 $DEPLOY_PATH
sudo chmod -Rf +x $DEPLOY_PATH
sudo rm -Rf $WORKPLACE
sudo hotspotd stop >> /dev/null
sudo ps aux | grep -i $DEPLOY_PATH/listenLIRC | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/listenLIRC | awk {'print $2'} | sudo xargs kill -9

sleep 2
sudo supervisorctl reload >> /dev/null
sleep 5
sudo sh $DIR/scripts/crontab.sh >> /dev/null
sleep 5
echo "True"
sudo chmod -Rf +x $DIR/scripts/upgrade.sh
sudo cp -Rf $DIR/scripts/upgrade.sh /opt
