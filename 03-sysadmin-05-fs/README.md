## Задание

1. Узнайте о [sparse-файлах](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных).  
**Выполнено**
1. Могут ли файлы, являющиеся жёсткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?  
**Не могут, так как права и владелец хранятся в inode, inode один и тотже у исходного файла и файла хардлинка.**
1. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```ruby
    path_to_disk_folder = './disks'

    host_params = {
        'disk_size' => 2560,
        'disks'=>[1, 2],
        'cpus'=>2,
        'memory'=>2048,
        'hostname'=>'sysadm-fs',
        'vm_name'=>'sysadm-fs'
    }
    Vagrant.configure("2") do |config|
        config.vm.box = "bento/ubuntu-20.04"
        config.vm.hostname=host_params['hostname']
        config.vm.provider :virtualbox do |v|

            v.name=host_params['vm_name']
            v.cpus=host_params['cpus']
            v.memory=host_params['memory']

            host_params['disks'].each do |disk|
                file_to_disk=path_to_disk_folder+'/disk'+disk.to_s+'.vdi'
                unless File.exist?(file_to_disk)
                    v.customize ['createmedium', '--filename', file_to_disk, '--size', host_params['disk_size']]
                end
                v.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', disk.to_s, '--device', 0, '--type', 'hdd', '--medium', file_to_disk]
            end
        end
        config.vm.network "private_network", type: "dhcp"
    end
    ```

    Эта конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2,5 Гб.  
**Выполнено**
1. Используя `fdisk`, разбейте первый диск на два раздела: 2 Гб и оставшееся пространство.  
```bash
sudo fdisk /dev/sdb  
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-5242879, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-5242879, default 5242879): +2G

Created a new partition 1 of type 'Linux' and of size 2 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 
First sector (4196352-5242879, default 4196352): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (4196352-5242879, default 5242879): 

Created a new partition 2 of type 'Linux' and of size 511 MiB.

Command (m for help): m

Help:

  DOS (MBR)
   a   toggle a bootable flag
   b   edit nested BSD disklabel
   c   toggle the dos compatibility flag

  Generic
   d   delete a partition
   F   list free unpartitioned space
   l   list known partition types
   n   add a new partition
   p   print the partition table
   t   change a partition type
   v   verify the partition table
   i   print information about a partition

  Misc
   m   print this menu
   u   change display/entry units
   x   extra functionality (experts only)

  Script
   I   load disk layout from sfdisk script file
   O   dump disk layout to sfdisk script file

  Save & Exit
   w   write table to disk and exit
   q   quit without saving changes

  Create a new label
   g   create a new empty GPT partition table
   G   create a new empty SGI (IRIX) partition table
   o   create a new empty DOS partition table
   s   create a new empty Sun partition table


Command (m for help): w

The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

```
5. Используя `sfdisk`, перенесите эту таблицу разделов на второй диск.  
```bash
sudo sfdisk -d /dev/sdb > part_table  
sudo sfdisk /dev/sdc < part_table
sdb                         8:16   0  2.5G  0 disk                   
├─sdb1                      8:17   0    2G  0 part                   
└─sdb2                      8:18   0  511M  0 part                   
sdc                         8:32   0  2.5G  0 disk                   
├─sdc1                      8:33   0    2G  0 part                   
└─sdc2                      8:34   0  511M  0 part
```
6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.
```bash
vagrant@sysadm-fs:~$ sudo mdadm --create --verbose --assume-clean /dev/md0 -l 1 -n 2 /dev/sd{b1,c1}
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? 
Continue creating array? (y/n) y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
vagrant@sysadm-fs:~$ cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
````

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.  
```bash
vagrant@sysadm-fs:~$ sudo mdadm --create --verbose /dev/md0 -l 1 -n 2 /dev/sd{b1,c1}
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
mdadm: size set to 2094080K
Continue creating array? 
Continue creating array? (y/n) y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
vagrant@sysadm-fs:~$ cat /proc/mdstat
Personalities : [linear] [multipath] [raid0] [raid1] [raid6] [raid5] [raid4] [raid10] 
md0 : active raid1 sdc1[1] sdb1[0]
      2094080 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>
```
```bash
sudo mdadm --detail --scan  | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
```
8. Создайте два независимых PV на получившихся md-устройствах.
```bash
vagrant@sysadm-fs:~$ sudo pvcreate /dev/md0; sudo pvcreate /dev/md1
Physical volume "/dev/md0" successfully created.
Physical volume "/dev/md1" successfully created.
```
9. Создайте общую volume-group на этих двух PV.
````bash
sudo vgcreate vg00 /dev/md0 /dev/md1
````
10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
````bash
sudo lvcreate -L 100M vg00 /dev/md0
````
11. Создайте `mkfs.ext4` ФС на получившемся LV.
````bash
sudo mkfs.ext4 /dev/vg00/lvol0 
````
12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.
````bash
mkdir /tmp/lvol0
sudo mount /dev/vg00/lvol0 /tmp/lvol0/
````
13. Поместите туда тестовый файл, например, `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.  
````bash
wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
`````
14. Прикрепите вывод `lsblk`.
````bash
NAME                      MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
loop0                       7:0    0 63.3M  1 loop  /snap/core20/1852
loop1                       7:1    0 67.8M  1 loop  /snap/lxd/22753
loop2                       7:2    0 49.9M  1 loop  /snap/snapd/18596
loop3                       7:3    0   62M  1 loop  /snap/core20/1611
loop4                       7:4    0 91.9M  1 loop  /snap/lxd/24061
sda                         8:0    0   64G  0 disk  
├─sda1                      8:1    0    1M  0 part  
├─sda2                      8:2    0    2G  0 part  /boot
└─sda3                      8:3    0   62G  0 part  
  └─ubuntu--vg-ubuntu--lv 253:0    0   31G  0 lvm   /
sdb                         8:16   0  2.5G  0 disk  
├─sdb1                      8:17   0    2G  0 part  
│ └─md1                     9:1    0    2G  0 raid1 
└─sdb2                      8:18   0  511M  0 part  
  └─md0                     9:0    0 1018M  0 raid0 
    └─vg00-lvol0          253:1    0  100M  0 lvm   /tmp/lvol0
sdc                         8:32   0  2.5G  0 disk  
├─sdc1                      8:33   0    2G  0 part  
│ └─md1                     9:1    0    2G  0 raid1 
└─sdc2                      8:34   0  511M  0 part  
  └─md0                     9:0    0 1018M  0 raid0 
    └─vg00-lvol0          253:1    0  100M  0 lvm   /tmp/lvol0
````
15. Протестируйте целостность файла:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```
**Выполнено**  
16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
```bash
sudo pvmove /dev/md0 /dev/md1
```
17. Сделайте `--fail` на устройство в вашем RAID1 md.
````bash
sudo mdadm /dev/md1 --fail /dev/sdb1 
````
18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
````bash
md/raid1:md1: Disk failure on sdb1, disabling device.
md/raid1:md1: Operation continuing on 1 devices.
 ````
19. Протестируйте целостность файла — он должен быть доступен несмотря на «сбойный» диск:

    ```bash
    root@vagrant:~# gzip -t /tmp/new/test.gz
    root@vagrant:~# echo $?
    0
    ```
**Выполнено**
20. Погасите тестовый хост — `vagrant destroy`.
**Выполнено**