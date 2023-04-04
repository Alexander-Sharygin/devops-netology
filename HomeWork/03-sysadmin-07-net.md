## Задание

1. Проверьте список доступных сетевых интерфейсов на вашем компьютере. Какие команды есть для этого в Linux и в Windows?
 linux ip a (ifconfig)
````bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:59:cb:31 brd ff:ff:ff:ff:ff:ff
    inet 10.0.2.15/24 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 66267sec preferred_lft 66267sec
    inet6 fe80::a00:27ff:fe59:cb31/64 scope link 
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:1c:a5:3c brd ff:ff:ff:ff:ff:ff
    inet 192.168.56.3/24 brd 192.168.56.255 scope global dynamic eth1
       valid_lft 527sec preferred_lft 527sec
    inet6 fe80::a00:27ff:fe1c:a53c/64 scope link 
       valid_lft forever preferred_lft forever
````
windows ipconfig /all

2. Какой протокол используется для распознавания соседа по сетевому интерфейсу? Какой пакет и команды есть в Linux для этого?  
**Протокол LLDP  
Пакет lldpd  
lldpctl  
lldpcli** 
3. Какая технология используется для разделения L2-коммутатора на несколько виртуальных сетей? Какой пакет и команды есть в Linux для этого? Приведите пример конфига.  
**Технология vlan  
Модуль ядра, проверить загружен ли модуль ядра lsmod | grep 8021q  
sudo nano /etc/network/interfaces
````bash
auto eth0.100
iface eth0.100 inet static
address 192.168.1.200
netmask 255.255.255.0
vlan-raw-device eth0
auto eth0.100
````
systemctl restart network
4. Какие типы агрегации интерфейсов есть в Linux? Какие опции есть для балансировки нагрузки? Приведите пример конфига.  
````bash
BONDING  
 mode=0 (balance-rr) - обеспечивает балансировку нагрузки и отказоустойчивость.
 mode=1 (active-backup) - один интерфейс работает в активном режиме, остальные в ожидающем.
 mode=2 (balance-xor) - обеспечивает балансировку нагрузки и отказоустойчивость. ((MAC-адрес источника) XOR (MAC-адрес получателя)) % число интерфейсов
 mode=3 (broadcast) - передача во все объединенные интерфейсы, обеспечивая отказоустойчивость.
 mode=4 (802.3ad) - динамическое объединение портов, увеличивает производительность.
 mode=5 (balance-tlb) - Адаптивная балансировка нагрузки
 mode=6 (balance-alb) - Адаптивная балансировка нагрузки
 ````
0,2,5,6 - балансировка нагрузки
apt-get install ifenslave  
auto bond0
````bash
iface bond0 inet static
    address 10.31.1.5
    netmask 255.255.255.0
    network 10.31.1.0
    gateway 10.31.1.254
    bond-slaves eth0 eth1
    bond-mode active-backup
    bond-miimon 100
    bond-downdelay 200
    bond-updelay 200
````
5. Сколько IP-адресов в сети с маской /29 ? Сколько /29 подсетей можно получить из сети с маской /24. Приведите несколько примеров /29 подсетей внутри сети 10.10.10.0/24.  
** 6 адресов  
32 29х подсети, может быть внутри 24й  
   1 10.10.10.0/29  
   2 10.10.10.8/29  
   ...  
   32 10.10.10.248/29
**
6. Задача: вас попросили организовать стык между двумя организациями. Диапазоны 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 уже заняты. Из какой подсети допустимо взять частные IP-адреса? Маску выберите из расчёта — максимум 40–50 хостов внутри подсети.  
**Диапазон 100.64.0.0/10  
100.91.0.0/26  1я организация
100.91.0.0/64  2я организация
62 хоста, максимум 40-50 не получится, маска 27 уже 30 хостов.
Я бы взял 100.91.0.0/24 и 100.91.1.0/24** 
7. Как проверить ARP-таблицу в Linux, Windows? Как очистить ARP-кеш полностью? Как из ARP-таблицы удалить только один нужный IP?
arp
arp -d [ip-address]