#!/bin/bash
# bakshi related code
rm /tmp/lircd.conf

sudo service lircd stop
sudo kill -9 $(pidof lircd)

ir_codes_dir=/opt/ir-codes/
cd $ir_codes_dir
var=$(ls  -1 *.conf)

cat $var >>/tmp/lircd.conf
chown -Rf root:root /tmp/lircd.conf
chmod 0644 /tmp/lircd.conf
cp -Rf /tmp/lircd.conf /etc/lirc

sudo lircd --device /dev/lirc0
sudo service lircd restart