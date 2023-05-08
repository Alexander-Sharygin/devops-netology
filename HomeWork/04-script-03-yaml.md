## Задание 1

Мы выгрузили JSON, который получили через API-запрос к нашему сервису:

```
    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175
            }
            { "name" : "second",
            "type" : "proxy",
            "ip : 71.78.22.43
            }
        ]
    }
```
  Нужно найти и исправить все ошибки, которые допускает наш сервис.

### Ваш скрипт:

```
#!/usr/bin/env python3

import json
with open("04-script-03-yaml-1.json", 'r') as f:
    data = json.load(f)
    print (data)

    { "info" : "Sample JSON output from our service\t",
        "elements" :[
            { "name" : "first",
            "type" : "server",
            "ip" : 7175
            },
            { "name" : "second",
            "type" : "proxy",
            "ip" : "71.78.22.43"
            }
        ]
    }
```

---

## Задание 2

В прошлый рабочий день мы создавали скрипт, позволяющий опрашивать веб-сервисы и получать их IP. К уже реализованному функционалу нам нужно добавить возможность записи JSON и YAML-файлов, описывающих наши сервисы.

Формат записи JSON по одному сервису: `{ "имя сервиса" : "его IP"}`.

Формат записи YAML по одному сервису: `- имя сервиса: его IP`.

Если в момент исполнения скрипта меняется IP у сервиса — он должен так же поменяться в YAML и JSON-файле.

### Ваш скрипт:

```python
#!/usr/bin/env python3

import socket
import sys
import time
import json, yaml

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
with open("hosts.json", "w") as outfile:
    json.dump(hosts, outfile)
with open("hosts.yaml", "w") as outfile:
    json.dump(hosts, outfile)

#Проверяем по кругу
while True:
    for host, ip in hosts.items():
        hosts[host] = socket.gethostbyname(host)
        if ip != hosts[host]:
            print('ERROR ' + host + ' IP missmatch: ' + hosts[host])
            with open("hosts.json", "w") as outfile:
                json.dump(hosts, outfile)
            with open("hosts.yaml", "w") as outfile:
                json.dump(hosts, outfile)
        else:
            print(host + ' - ' + ip)
        time.sleep(1)
```

### Вывод скрипта при запуске во время тестирования:

```
drive.google.com - 64.233.165.194
mail.google.com - 142.250.74.37
google.com - 142.251.1.138
drive.google.com - 64.233.165.194
mail.google.com - 142.250.74.37
ERROR google.com IP missmatch: 142.251.1.102
drive.google.com - 64.233.165.194
mail.google.com - 142.250.74.37
ERROR google.com IP missmatch: 142.251.1.113
drive.google.com - 64.233.165.194
mail.google.com - 142.250.74.37
ERROR google.com IP missmatch: 142.251.1.139
drive.google.com - 64.233.165.194
mail.google.com - 142.250.74.37
ERROR google.com IP missmatch: 142.251.1.113
drive.google.com - 64.233.165.194
```

### JSON-файл(ы), который(е) записал ваш скрипт:

```json
{"drive.google.com": "64.233.165.194", "mail.google.com": "142.250.150.83", "google.com": "64.233.165.138"}
```

### YAML-файл(ы), который(е) записал ваш скрипт:

```yaml
{"drive.google.com": "64.233.165.194", "mail.google.com": "142.250.150.83", "google.com": "64.233.165.138"}
```

---