#!/usr/bin/env python3

import socket
import sys
import time
from sys import argv
#Выйдем, если не задан путь к файлу с хостами
try:
    argv[1]
except IndexError:
    print('Set the path to the file monitor-hosts in the script argument')
    sys.exit(1)
hosts = []
i = 0

while True:
    # Посчитаем кол-во хостов (строк в файле с хостами), это здесь, чтобы перечитывать конфиг с каждой новой итерацией
    qt = 0
    file = open(argv[1], "r")
    while True:
        line = file.readline().strip()
        if not line:
            break
        qt = qt + 1
    file.close
    #Цикл заполняет словарь хост+ip, сравнивает текущий ip с прошлым , выводит сообщение о рассхождении
    file = open(argv[1], "r")
    while True:
        line = file.readline().strip()
        if not line:
            break
        hosts.append({line: socket.gethostbyname(line)})
        print(str(*hosts[i].keys())+' - '+str(*hosts[i].values())+' ')
        time.sleep(1)
        if i > qt-1:
            if hosts[i] != hosts[(i-qt)]:
                #Выхода из программы нет, в задании не указано выйти после ошибки
                print('[ERROR] '+ str(*hosts[i].keys())+' IP mismatch: '+str(*hosts[i-qt].values()))
        i = i + 1
# закрываем файл
file.close
