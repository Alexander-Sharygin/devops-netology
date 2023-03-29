## Задание

1. На лекции вы познакомились с [node_exporter](https://github.com/prometheus/node_exporter/releases). В демонстрации его исполняемый файл запускался в background. Этого достаточно для демо, но не для настоящей production-системы, где процессы должны находиться под внешним управлением. Используя знания из лекции по systemd, создайте самостоятельно простой [unit-файл](https://www.freedesktop.org/software/systemd/man/systemd.service.html) для node_exporter:

    * поместите его в автозагрузку;
    * предусмотрите возможность добавления опций к запускаемому процессу через внешний файл (посмотрите, например, на `systemctl cat cron`);
    * удостоверьтесь, что с помощью systemctl процесс корректно стартует, завершается, а после перезагрузки автоматически поднимается.

````bash
#Устанавливаем
wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
tar zxvf node_exporter-1.5.0.linux-amd64.tar.gz 
cd node_exporter-1.5.0.linux-amd64
sudo cp node_exporter /usr/local/bin/
#Создаем юнит файл, предусматриваем добавление опций через файл /etc/node_exporter.conf 
sudo mcedit /etc/systemd/system/node_exporter.service
````
````text
#Юнит файл
[Unit]
Description=Node Exporter Service
After=network.target

[Service]
EnvironmentFile=/etc/node_exporter.conf
Type=simple
ExecStart=/usr/local/bin/node_exporter $opts
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target

#conf файл с опциями
opts="--log.level=debug"
````
````bash
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter
#Смотрим, сттаус сервиса и удостоверяемся, что опции сработали
sudo systemctl status node_exporter 
● node_exporter.service - Node Exporter Service
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2023-03-29 17:57:29 UTC; 7min ago
   Main PID: 17194 (node_exporter)
      Tasks: 4 (limit: 2273)
     Memory: 2.2M
     CGroup: /system.slice/node_exporter.service
             └─17194 /usr/local/bin/node_exporter --log.level=debug

#Удостоверяемся, сто сервер запускается перезапускается, стопается.
sudo journalctl -u node_exporter
Mar 29 17:39:55 sysadm-fs systemd[1]: Started Node Exporter Service.
Mar 29 17:39:55 sysadm-fs node_exporter[16847]: ts=2023-03-29T17:39:55.284Z caller=node_exporter.go:180 level=info msg="Starting node_exporter" version="(version=1.5.0, branch=HEAD, revision=1b48970ffcf5630534f>
.
.
Mar 29 17:39:55 sysadm-fs node_exporter[16847]: ts=2023-03-29T17:39:55.310Z caller=tls_config.go:235 level=info msg="TLS is disabled." http2=false address=[::]:9100

sudo systemctl stop node_exporter
sudo journalctl -u node_exporter
Mar 29 17:40:23 sysadm-fs systemd[1]: Stopping Node Exporter Service...
Mar 29 17:40:23 sysadm-fs systemd[1]: node_exporter.service: Succeeded.
Mar 29 17:40:23 sysadm-fs systemd[1]: Stopped Node Exporter Service.


sudo systemctl restart node_exporter
sudo journalctl -u node_exporter
Mar 29 17:41:14 sysadm-fs systemd[1]: Stopping Node Exporter Service...
Mar 29 17:41:14 sysadm-fs systemd[1]: node_exporter.service: Succeeded.
Mar 29 17:41:14 sysadm-fs systemd[1]: Stopped Node Exporter Service.
Mar 29 17:41:14 sysadm-fs systemd[1]: Started Node Exporter Service.
Mar 29 17:41:14 sysadm-fs node_exporter[16881]: ts=2023-03-29T17:41:14.374Z caller=node_exporter.go:180 level=info msg="Starting node_exporter" version="(version=1.5.0, branch=HEAD, revision=1b48970ffcf5630534f>
.
.
Mar 29 17:41:14 sysadm-fs node_exporter[16881]: ts=2023-03-29T17:41:14.403Z caller=tls_config.go:235 level=info msg="TLS is disabled." http2=false address=[::]:9100

#удостоверяемся, что сервис запускается после перезагрузки
sudo reboot
sudo systemctl status node_exporter 
● node_exporter.service - Node Exporter Service
     Loaded: loaded (/etc/systemd/system/node_exporter.service; enabled; vendor preset: enabled)
     Active: active (running) since Wed 2023-03-29 18:06:58 UTC; 33s ago
````

2. Изучите опции node_exporter и вывод `/metrics` по умолчанию. Приведите несколько опций, которые вы бы выбрали для базового мониторинга хоста по CPU, памяти, диску и сети.
````bash
curl http://localhost:9100/metrics
CPU 
node_cpu_seconds_total counter
Memory
node_memory_MemAvailable_bytes Memory information field MemAvailable_bytes.
node_memory_MemFree_bytes Memory information field MemFree_bytes.
node_memory_MemTotal_bytes Memory information field MemTotal_bytes.
node_memory_SwapCached_bytes Memory information field SwapCached_bytes.
node_memory_SwapFree_bytes Memory information field SwapFree_bytes.
node_memory_SwapTotal_bytes Memory information field SwapTotal_bytes.
disk
node_filesystem_files_free Filesystem total free file nodes.
node_filesystem_free_bytes Filesystem free space in bytes
node_disk_written_bytes_total The total number of bytes written successfully
node_disk_reads_completed_total The total number of reads completed successfully.
````
3. Установите в свою виртуальную машину [Netdata](https://github.com/netdata/netdata). Воспользуйтесь [готовыми пакетами](https://packagecloud.io/netdata/netdata/install) для установки (`sudo apt install -y netdata`). 
   
   После успешной установки:
   
    * в конфигурационном файле `/etc/netdata/netdata.conf` в секции [web] замените значение с localhost на `bind to = 0.0.0.0`;
    * добавьте в Vagrantfile проброс порта Netdata на свой локальный компьютер и сделайте `vagrant reload`:

    ```bash
    config.vm.network "forwarded_port", guest: 19999, host: 19999
    ```

    После успешной перезагрузки в браузере на своём ПК (не в виртуальной машине) вы должны суметь зайти на `localhost:19999`. Ознакомьтесь с метриками, которые по умолчанию собираются Netdata, и с комментариями, которые даны к этим метрикам.  
**Выполнено**
1. Можно ли по выводу `dmesg` понять, осознаёт ли ОС, что загружена не на настоящем оборудовании, а на системе виртуализации?

да  
DMI: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006    
Hypervisor detected: KVM

5. Как настроен ``sysctl `fs.nr_open``` на системе по умолчанию? Определите, что означает этот параметр. Какой другой существующий лимит не позволит достичь такого числа (`ulimit --help`)?  
````text 
Лимит открытых файлов для каждого процесса
ulimit -a 
open files (-n) 1024
````


6. Запустите любой долгоживущий процесс (не `ls`, который отработает мгновенно, а, например, `sleep 1h`) в отдельном неймспейсе процессов; покажите, что ваш процесс работает под PID 1 через `nsenter`. Для простоты работайте в этом задании под root (`sudo -i`). Под обычным пользователем требуются дополнительные опции (`--map-root-user`) и т. д.  
````bash
unshare -f --pid --mount-proc sleep 1h
в другом терминале
root@sysadm-fs:~# nsenter --target 2412 --pid --mount
root@sysadm-fs:/# ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.0   7228   580 pts/0    S+   19:00   0:00 sleep 1h
root           2  0.0  0.2   8960  4104 pts/1    S    19:06   0:00 -bash
root          13  0.0  0.1  10612  3328 pts/1    R+   19:06   0:00 ps aux
````
7. Найдите информацию о том, что такое `:(){ :|:& };:`. Запустите эту команду в своей виртуальной машине Vagrant с Ubuntu 20.04 (**это важно, поведение в других ОС не проверялось**). Некоторое время всё будет плохо, после чего (спустя минуты) — ОС должна стабилизироваться. Вызов `dmesg` расскажет, какой механизм помог автоматической стабилизации.  
Как настроен этот механизм по умолчанию, и как изменить число процессов, которое можно создать в сессии?  

fork bomb бесконечно создает процессы копии
[2465.587612] cgroup: fork rejected by pids controller in /user.slice/user-1000.slice/session-3.scope
стабилизировалось по лимиту кол-ва процессов 
