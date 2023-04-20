#!/usr/bin/env python3

import os

bash_command = ["cd ~/Netology/devops-netology", "git status"]
pwd = os.popen(bash_command[0]+";"+'pwd', 'r').read().replace('\n', '')
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(pwd+"/"+prepare_result)
