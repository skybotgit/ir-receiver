#!/usr/bin/env bash
SAMPLE_COMMAND='`sh deploy.sh debug`'
if [ "$#" -ne 2 ]; then
    echo "Invalid arguments passed"
    echo 'Sample Command :'$SAMPLE_COMMAND
    exit
fi

MODE=$1

if [ "$MODE" != 'debug' -a "$MODE" != 'release' ]
then
    echo "Argument should be from 'debug', 'release'"
    echo 'Sample Command :'$SAMPLE_COMMAND
    exit
fi

DIR=/opt/ir-receiver-bin
S3URL="https://s3-ap-south-1.amazonaws.com/skybot-ir-binaries/${MODE}/build_ir.tar.gz"
WORKPLACE=/opt/ir-workplace
DEPLOY_PATH=/opt/bin

sudo rm -Rf $WORKPLACE
sudo mkdir -p $WORKPLACE
cd $WORKPLACE
sudo wget $S3URL
sudo tar -zxvf build_ir.tar.gz ./
sudo rm build_ir.tar.gz

cd $DIR
sudo supervisorctl stop all
sudo git reset --hard
sudo git pull origin
sudo git pull origin version/$VERSION
sudo rm -Rf /etc/supervisor/conf.d/*.conf
sudo cp -Rf $DIR/scripts/etc/supervisor/conf.d/* /etc/supervisor/conf.d/
sudo rm -Rf $DEPLOY_PATH
sudo mkdir -p $DEPLOY_PATH
sudo cp -Rf $WORKPLACE/bin/* $DEPLOY_PATH
sudo cp -Rf $DIR/template.conf $DEPLOY_PATH
sudo chown -Rf 0777 $DEPLOY_PATH
sudo chmod -Rf +x $DEPLOY_PATH
sudo rm -Rf $WORKPLACE
sudo hotspotd stop
sudo ps aux | grep -i $DEPLOY_PATH/listenLIRC | awk {'print $2'} | sudo xargs kill -9
sudo ps aux | grep -i $DEPLOY_PATH/listenLIRC | awk {'print $2'} | sudo xargs kill -9

sleep 2
sudo supervisorctl reload
sleep 5
sudo supervisorctl status
sudo sh $DIR/scripts/crontab.sh
echo "SkyBot installed successfully"
echo "check logs with tail -f /tmp/skybot.log"
sudo cp -Rf $DIR/scripts/upgrade.sh /opt
sudo chmod -Rf +x /opt/upgrade.sh
if [ "$MODE" = 'debug' ]
then
    tail -f /tmp/skybot.log
fi
