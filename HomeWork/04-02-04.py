#!/usr/bin/env python3

import socket

file1 = open("argv1", "r")

# считываем все строки
lines = file1.readlines()

# итерация по строкам
for line in lines:
    print(line.strip())

# закрываем файл
file1.close

ip = socket.gethostbyname ("google.com")
print(ip)