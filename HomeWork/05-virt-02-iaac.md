## Задача 1

- Опишите основные преимущества применения на практике IaaC-паттернов.  
*Скорость настройки. Возможность воспроизведения конфигураций, быстрое восстановление при сбоях, масштабирование.  
Идентичные конфигураций
Документирование, так как код можно версионировать, автоматически документируются все изменения инфраструктуры*
- Какой из принципов IaaC является основополагающим?  
*Идемпотентность - свойство объекта или операции при повторном применении операции к объекту давать тот же результат,
что и при первом.*
## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?  
*Работает без агента по ssh  
Удобный формат для описания конфигураций yaml  
Большое комьюнити легко найти готовые решения
- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный — push или pull?
Оба метода надежны, у каждого метода свои плюсы и минусы, я бы предпочел push подход, вераятно менее трудоемкий, чем pull, но это уже не про надежность.
## Задача 3

Установите на личный компьютер:

- [VirtualBox](https://www.virtualbox.org/),
- [Vagrant](https://github.com/netology-code/devops-materials),
- [Terraform](https://github.com/netology-code/devops-materials/blob/master/README.md),
- Ansible.

*Приложите вывод команд установленных версий каждой из программ, оформленный в Markdown.*
```bash
vboxmanage --version
6.1.44r156814
```
```bash
vagrant --version
Vagrant 2.3.4
```
```bash
terraform --version
Terraform v1.4.6
on linux_amd64
```
```bash
 ansible --version
ansible 2.10.8
```

## Задача 4 

Воспроизведите практическую часть лекции самостоятельно.

- Создайте виртуальную машину.
- Зайдите внутрь ВМ, убедитесь, что Docker установлен с помощью команды
```
docker ps,
```
Vagrantfile из лекции и код ansible находятся в [папке](https://github.com/netology-code/virt-homeworks/tree/virt-11/05-virt-02-iaac/src).

Примечание. Если Vagrant выдаёт ошибку:
```
URL: ["https://vagrantcloud.com/bento/ubuntu-20.04"]     
Error: The requested URL returned error: 404:
```


```bash
alexander@ThinkBook-14-G2-ARE:~/Netology/vagrant$ vagrant up
Bringing machine 'server1.netology' up with 'virtualbox' provider...
==> server1.netology: Importing base box 'bento/ubuntu-20.04'...
==> server1.netology: Matching MAC address for NAT networking...
==> server1.netology: Checking if box 'bento/ubuntu-20.04' version '202212.11.0' is up to date...
==> server1.netology: Setting the name of the VM: server1.netology
==> server1.netology: Clearing any previously set network interfaces...
==> server1.netology: Preparing network interfaces based on configuration...
    server1.netology: Adapter 1: nat
    server1.netology: Adapter 2: hostonly
==> server1.netology: Forwarding ports...
    server1.netology: 22 (guest) => 20011 (host) (adapter 1)
    server1.netology: 22 (guest) => 2222 (host) (adapter 1)
==> server1.netology: Running 'pre-boot' VM customizations...
==> server1.netology: Booting VM...
==> server1.netology: Waiting for machine to boot. This may take a few minutes...
    server1.netology: SSH address: 127.0.0.1:2222
    server1.netology: SSH username: vagrant
    server1.netology: SSH auth method: private key
    server1.netology: 
    server1.netology: Vagrant insecure key detected. Vagrant will automatically replace
    server1.netology: this with a newly generated keypair for better security.
    server1.netology: 
    server1.netology: Inserting generated public key within guest...
    server1.netology: Removing insecure key from the guest if it's present...
    server1.netology: Key inserted! Disconnecting and reconnecting using new SSH key...
==> server1.netology: Machine booted and ready!
==> server1.netology: Checking for guest additions in VM...
==> server1.netology: Setting hostname...
==> server1.netology: Configuring and enabling network interfaces...
==> server1.netology: Mounting shared folders...
    server1.netology: /vagrant => /home/alexander/Netology/vagrant
==> server1.netology: Running provisioner: ansible...
    server1.netology: Running ansible-playbook...
[WARNING]:  * Failed to parse
/home/alexander/Netology/vagrant/inventory/provision.yml with auto plugin: no
root 'plugin' key found,
'/home/alexander/Netology/vagrant/inventory/provision.yml' is not a valid YAML
inventory plugin config file
[WARNING]:  * Failed to parse
/home/alexander/Netology/vagrant/inventory/provision.yml with yaml plugin: YAML
inventory has invalid structure, it should be a dictionary, got: <class
'ansible.parsing.yaml.objects.AnsibleSequence'>
[WARNING]:  * Failed to parse
/home/alexander/Netology/vagrant/inventory/provision.yml with ini plugin:
Invalid host pattern '---' supplied, '---' is normally a sign this is a YAML
file.
[WARNING]: Unable to parse
/home/alexander/Netology/vagrant/inventory/provision.yml as an inventory source

PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [server1.netology]

TASK [Create directory for ssh-keys] *******************************************
ok: [server1.netology]

TASK [Adding rsa-key in /root/.ssh/authorized_keys] ****************************
changed: [server1.netology]

TASK [Checking DNS] ************************************************************
changed: [server1.netology]

TASK [Installing tools] ********************************************************
ok: [server1.netology] => (item=['git', 'curl'])

TASK [Installing docker] *******************************************************
changed: [server1.netology]

TASK [Add the current user to docker group] ************************************
changed: [server1.netology]

PLAY RECAP *********************************************************************
server1.netology           : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

alexander@ThinkBook-14-G2-ARE:~/Netology/vagrant$ vagrant ssh
Welcome to Ubuntu 20.04.5 LTS (GNU/Linux 5.4.0-135-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun 21 May 2023 07:01:17 AM UTC

  System load:  0.03               Users logged in:          0
  Usage of /:   13.6% of 30.34GB   IPv4 address for docker0: 172.17.0.1
  Memory usage: 23%                IPv4 address for eth0:    10.0.2.15
  Swap usage:   0%                 IPv4 address for eth1:    192.168.56.11
  Processes:    109


This system is built by the Bento project by Chef Software
More information can be found at https://github.com/chef/bento
Last login: Sun May 21 06:50:05 2023 from 10.0.2.2

vagrant@server1:~$ docker --version
Docker version 24.0.1, build 6802122

vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

```