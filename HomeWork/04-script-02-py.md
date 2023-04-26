## Задание 1

Есть скрипт:

```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:

| Вопрос  | Ответ                                    |
| ------------- |------------------------------------------|
| Какое значение будет присвоено переменной `c`?  | Произойдет ошибка текс и число не складывается |
| Как получить для переменной `c` значение 12?  | c = str(a) + b                                         |
| Как получить для переменной `c` значение 3?  | c = a + int(b)                                         |

------

## Задание 2

Мы устроились на работу в компанию, где раньше уже был DevOps-инженер. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. 

Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os


bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/Netology/devops-netology", "git status"]
pwd = os.popen(bash_command[0]+";"+'pwd', 'r').read().replace('\n', '')
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(pwd+"/"+prepare_result)
```

### Вывод скрипта при запуске во время тестирования:

```
/usr/bin/python3.10 /home/alexander/Netology/devops-netology/HomeWork/04-02-03.py 
/home/alexander/Netology/devops-netology/.idea/workspace.xml
/home/alexander/Netology/devops-netology/HomeWork/04-02-03.py
/home/alexander/Netology/devops-netology/HomeWork/04-script-02-py.md

Process finished with exit code 0
```

------

## Задание 3

Доработать скрипт выше так, чтобы он не только мог проверять локальный репозиторий в текущей директории, но и умел воспринимать путь к репозиторию, который мы передаём, как входной параметр. Мы точно знаем, что начальство будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:

```python
#!/usr/bin/env python3

import os
from sys import argv
import git
try:
    git = git.Repo(argv[1]).git_dir
except git.exc.InvalidGitRepositoryError:
    print("Dir is non git")
    exit(1)


bash_command = ["cd "+argv[1], "git status"]
pwd = os.popen(bash_command[0]+";"+'pwd', 'r').read().replace('\n', '')
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(pwd+"/"+prepare_result)
```

### Вывод скрипта при запуске во время тестирования:

```
alexander@ThinkBook-14-G2-ARE:~/Netology/devops-netology/HomeWork$ python3 04-02-03.py ~/Netology/devops-netology/
/home/alexander/Netology/devops-netology/.idea/workspace.xml
/home/alexander/Netology/devops-netology/HomeWork/04-02-03.py

alexander@ThinkBook-14-G2-ARE:~/Netology/devops-netology/HomeWork$ python3 04-02-03.py ~/Netology/
Dir is non git

```

------

## Задание 4

Наша команда разрабатывает несколько веб-сервисов, доступных по HTTPS. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. 

Проблема в том, что отдел, занимающийся нашей инфраструктурой, очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS-имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. 

Мы хотим написать скрипт, который: 

- опрашивает веб-сервисы; 
- получает их IP; 
- выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. 

Также должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена — оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:

```python
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
```

### Вывод скрипта при запуске во время тестирования:

```
drive.google.com - 108.177.14.194
mail.google.com - 142.250.203.133
google.com - 64.233.164.139
drive.google.com - 108.177.14.194
mail.google.com - 142.250.203.133
ERROR google.com IP missmatch: 64.233.164.100
drive.google.com - 108.177.14.194
ERROR mail.google.com IP missmatch: 64.233.165.18
ERROR google.com IP missmatch: 64.233.164.139
drive.google.com - 108.177.14.194
ERROR mail.google.com IP missmatch: 64.233.165.83
ERROR google.com IP missmatch: 64.233.164.101
drive.google.com - 108.177.14.194
ERROR mail.google.com IP missmatch: 64.233.165.17
ERROR google.com IP missmatch: 64.233.164.100
.................
```

------
