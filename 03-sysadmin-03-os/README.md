# Домашнее задание к занятию «Операционные системы. Лекция 1»

## Задание

1. Какой системный вызов делает команда `cd`? 

    В прошлом ДЗ вы выяснили, что `cd` не является самостоятельной  программой. Это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае увидите полный список системных вызовов, которые делает сам `bash` при старте. 

    Вам нужно найти тот единственный, который относится именно к `cd`. Обратите внимание, что `strace` выдаёт результат своей работы в поток stderr, а не в stdout.  
**chdir("/tmp")**
1. Попробуйте использовать команду `file` на объекты разных типов в файловой системе. Например:

    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
    
    Используя `strace`, выясните, где находится база данных `file`, на основании которой она делает свои догадки.  
**strace -e trace=file file /dev/tty  
/usr/share/misc/magic.mgc**
1. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удалён (deleted в lsof), но сказать сигналом приложению переоткрыть файлы или просто перезапустить приложение возможности нет. Так как приложение продолжает писать в удалённый файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков, предложите способ обнуления открытого удалённого файла, чтобы освободить место на файловой системе.  
**например rsyslog pid 639
la -la /proc/639/fd  
l-wx------ 1 root   root   64 Mar 22 14:08 7 -> /var/log/syslog  
l-wx------ 1 root   root   64 Mar 22 14:08 8 -> /var/log/kern.log  
l-wx------ 1 root   root   64 Mar 22 14:08 9 -> /var/log/auth.log  
echo > /proc/639/fd/7 - перенаправили поток вывода echo в файловый дискриптор**
1. Занимают ли зомби-процессы ресурсы в ОС (CPU, RAM, IO)?  
**Не занимают, освободили при завершении**
1. В IO Visor BCC есть утилита `opensnoop`:

    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные сведения по установке [по ссылке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).
```bash
vagrant@vagrant:~$ sudo /usr/sbin/opensnoop-bpfcc
PID    COMM               FD ERR PATH
389    systemd-udevd      -1   2 /run/udev/queue
389    systemd-udevd      14   0 /run/udev/queue
28702  systemd-udevd      15   0 /proc/self/oom_score_adj
28702  systemd-udevd       6   0 /sys/devices/LNXSYSTM:00/LNXSYBUS:00/PNP0A03:00/PNP0C0A:00/power_supply/BAT0/uevent
28702  systemd-udevd      -1   2 /run/udev/data/+power_supply:BAT0
28702  systemd-udevd       6   0 /
28702  systemd-udevd      15   0 sys
28702  systemd-udevd       6   0 class
28702  systemd-udevd      15   0 dmi
28702  systemd-udevd       6   0 id
28702  systemd-udevd       6   0 ..
28702  systemd-udevd      15   0 ..
28702  systemd-udevd       6   0 devices
28702  systemd-udevd      15   0 virtual 
```

6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc` и где можно узнать версию ядра и релиз ОС.

**proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}.**  

7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:

    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
    
    Есть ли смысл использовать в bash `&&`, если применить `set -e`?  
**; выполнит все команды, не зависимо от того как завершилась предыдущая  
&& выполняет следующую в случае если предыдущая завершилась успешно.  
В примере, Hi выводится всегда, в случае наличия директории some_dir  
c set -e завершает выполнение, при сбое выполнение шела,  && смысла использовать есть, при использованиии ; оболочка завершится после выполнения команды, которая даст ошибку. С && не выполнятся последующие команды.**
1. Из каких опций состоит режим bash `set -euxo pipefail`, и почему его хорошо было бы использовать в сценариях?
 
**из 4х  
e - указывает оболочке выйти, если команда дает ненулевой статус выхода  
u - обрабатывает неустановленные или неопределенные переменные, за исключением специальных параметров, таких как подстановочные знаки (*) или «@», как ошибки во время раскрытия параметра.  
x - печатает аргументы команды во время выполнения  
o pipefail  - без этой опции e не работает с конвеерными командами.
 
Стоит использовать, чтобы сценарий завершался в случае ошибок, x для информативности видимо вывода.

9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` изучите (`/PROCESS STATE CODES`), что значат дополнительные к основной заглавной букве статуса процессов. Его можно не учитывать при расчёте (считать S, Ss или Ssl равнозначными).  
**Наиболее часто встречающийся статус S  
ps -Ao stat  | cut -c1-1 | sort | uniq -c | sort -h  
      1 R  
     46 I  
     62 S**
```commandline 
PROCESS STATE CODES
       Here are the different values that the s, stat and state output specifiers (header "STAT" or "S") will display to describe the state of a process:

               D    uninterruptible sleep (usually IO)
               I    Idle kernel thread
               R    running or runnable (on run queue)
               S    interruptible sleep (waiting for an event to complete)
               T    stopped by job control signal
               t    stopped by debugger during the tracing
               W    paging (not valid since the 2.6.xx kernel)
               X    dead (should never be seen)
               Z    defunct ("zombie") process, terminated but not reaped by its parent

       For BSD formats and when the stat keyword is used, additional characters may be displayed:

               <    high-priority (not nice to other users)
               N    low-priority (nice to other users)
               L    has pages locked into memory (for real-time and custom IO)
               s    is a session leader
               l    is multi-threaded (using CLONE_THREAD, like NPTL pthreads do)
               +    is in the foreground process group
