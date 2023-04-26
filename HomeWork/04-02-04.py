#!/usr/bin/env python3

import socket
import sys
import time
from sys import argv
try:
    argv[1]
except IndexError:
    print('Set the path to the file monitor-hosts in the script argument')
    sys.exit(1)
hosts = {}

#Заполняем словарь host:ip из файла
file = open(argv[1], "r")
while True:
    line = file.readline().strip()
    if not line:
        break
    hosts[line] = socket.gethostbyname(line)
    print (line + ' - ' +hosts[line] )
file.close

#Проверяем по кругу
while True:
    for host, ip in hosts.items():
        hosts[host] = socket.gethostbyname(host)
        if ip != hosts[host]:
            print('ERROR ' + host + ' IP missmatch: ' + hosts[host])
        else:
            print(host + ' - ' + ip)
        time.sleep(1)
