#!/bin/bash

if [ `lds ${1}  -l | grep -v Логин |  wc -l` -ne "1" ]
then
lds   -l ${1}
exit
fi

USERNAME=`lds ${1} -l | tail -n 1`
PASSWORD=`pwgen -v -N 1`
IP=${2}
ACCESS_PORT=${3}
FULLNAME=`lds ${1} | tail -n 1 | awk '{print $3 " " $4 " " $5}'`

export USERNAME
export IP
export PASSWORD
export ACCESS_PORT
export FULLNAME

expect -c 'spawn ssh ssh1@192.168.xxx.xxx -oKexAlgorithms=+diffie-hellman-group1-sha1;\
expect "password:" {send -- "xxxxxxxxxxxxxx\r"};\
expect "asa5510>" {send -- "enable\r"};\
expect "Password:" {send -- "xxxxxxxxxxxxxx\r"};\
expect "asa5510#" {send -- "configure terminal\r"};\
expect "asa5510(config)#" {send -- "access-list $env(USERNAME) extended permit tcp any host $env(IP) eq $env(ACCESS_PORT) time-range 311217\r"};\
expect "asa5510(config)#" {send -- "username $env(USERNAME) password $env(PASSWORD)\r"};\
expect "asa5510(config)#" {send -- "username $env(USERNAME) attributes\r"};\
expect "asa5510(config-username)#" {send -- "vpn-filter value $env(USERNAME)\r"};\
expect "asa5510(config-username)#" {send -- "exit\r"};\
expect "asa5510(config)#" {send -- "wr\r"};\
expect "asa5510(config)#" {send -- "exit\r"};
expect "asa5510#" {send -- "exit\r"};'


expect -c 'spawn ssh 195.190.126.190 -p 2200 -l root;\
expect "password:" {send -- "xxxxxxxxxxxxxxxx\r"};\
expect "syslog-server ~]#" {send -- "echo $env(USERNAME)=$env(FULLNAME) >> cisco_log/names.txt \r "};\
expect "syslog-server ~]#" {send --  "exit\r"};'



touch template
echo user:         ${USERNAME} >> template
echo password:     ${PASSWORD} >> template
echo ip address:   ${IP} >> template
echo Вам необходимо скачать архив по адресу ftp://ftp.nicetu.spb.ru/vpn.zip >> template
echo Внутри находятся необходимые файлы и инструкция. >> template
lpr template
rm template

