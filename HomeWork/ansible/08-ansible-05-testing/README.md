# Домашнее задание к занятию 5 «Тестирование roles»

## Подготовка к выполнению

1. Установите molecule: `pip3 install "molecule==3.5.2"` и драйвера `pip3 install molecule_docker molecule_podman`.
2. Выполните `docker pull aragast/netology:latest` — это образ с podman, tox и несколькими пайтонами (3.7 и 3.9) внутри.  

**Выполнено.**
## Основная часть

Ваша цель — настроить тестирование ваших ролей. 

Задача — сделать сценарии тестирования для vector. 

Ожидаемый результат — все сценарии успешно проходят тестирование ролей.

### Molecule

1. Запустите  `molecule test -s centos_7` внутри корневой директории clickhouse-role, посмотрите на вывод команды. Данная команда может отработать с ошибками, это нормально. Наша цель - посмотреть как другие в реальном мире используют молекулу.  

Получена ошибка 
```bash
CRITICAL Failed to validate /home/alexander/.ansible/roles/clickhouse/molecule/centos_7/molecule.yml

["Additional properties are not allowed ('playbooks' was unexpected)"]
``` 
Не доступно свойство playbooks ./centos_7/molecule.yml, закоментировал:
```yaml
provisioner:
  name: ansible
  options:
    vv: true
    D: true
  inventory:
    links:
      hosts: ../resources/inventory/hosts.yml
      group_vars: ../resources/inventory/group_vars/
      host_vars: ../resources/inventory/host_vars/
#  playbooks:
#    converge: ../resources/playbooks/converge.yml
verifier:
  name: ansible
#  playbooks:
#    verify: ../resources/tests/verify.yml
```
Повторное тестирование, ошибка:  
```bash
TASK [Include ansible-clickhouse] **********************************************
ERROR! the role 'ansible-clickhouse' was not found in /home/alexander/.ansible/roles/clickhouse/molecule/centos_7/roles:/root/.cache/molecule/clickhouse/centos_7/roles:/home/alexander/.ansible/roles:/root/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles:/home/alexander/.ansible/roles/clickhouse/molecule/centos_7

The error appears to be in '/home/alexander/.ansible/roles/clickhouse/molecule/centos_7/converge.yml': line 7, column 15, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

      include_role:
        name: "ansible-clickhouse"
              ^ here
```  
У меня эта роль называется clickhouse, исправил в ./centos_7/converge.yml  
Повторил тестирование, длинный вывод вынес [сюда](https://github.com/Alexander-Sharygin/devops-netology/blob/main/HomeWork/ansible/08-ansible-05-testing/con_out/Molecule_1_3.md)  
Критичные ошибки, проверка состояния сервиса кликхауса, выдала неизвестное состояние.
```bash
TASK [clickhouse : Ensure clickhouse-server.service is enabled: True and state: restarted] ***
fatal: [centos_7]: FAILED! => {"changed": false, "msg": "Service is in unknown state", "status": {}}

PLAY RECAP *********************************************************************
centos_7                   : ok=18   changed=7    unreachable=0    failed=1    skipped=6    rescued=0    ignored=0

CRITICAL Ansible return code was 2, command was: ansible-playbook -D --inventory /root/.cache/molecule/clickhouse/centos_7/inventory --skip-tags molecule-notest,notest /home/alexander/.ansible/roles/clickhouse/molecule/centos_7/converge.yml
```
Не известное состояние, из-за не работающего внутри контейнера systemd, ниже у меня в следующем задании та же проблема. Если подключится к контейнеру выполнить systemctl -> Failed to get D-Bus connection: Operation not permitted.  
Здесь же вроде как автор роли сделал всё, что не обходимо в [описании платформы](https://github.com/AlexeySetevoi/ansible-clickhouse/blob/master/molecule/centos_7/molecule.yml) и [докерфайле](https://github.com/AlexeySetevoi/ansible-clickhouse/blob/master/molecule/resources/Dockerfile.j2), чтобы systemd работал, но нет. Не могу разобраться почему не работает.
Попробовал еще раз на чистой виртуалке qemu/kvm под ubuntu тоже самое.

3. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.  

**Выполнено**  

4. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.  

**Тестирование**  
В [molecule.yml](https://github.com/Alexander-Sharygin/vector-role/blob/master/molecule/default/molecule.yml) добавлены два инстансы  
*Ошибка:*
```bash
ERROR    Computed fully qualified role name of vector-role does not follow current galaxy requirements.
Please edit meta/main.yml and assure we can correctly determine full role name:

galaxy_info:
role_name: my_name  # if absent directory name hosting role is used instead
namespace: my_galaxy_namespace  # if absent, author is used instead
```  
Устранил,добавив role_name и namespace в meta/mail.yml  

*Ошибка:*
```bash
ERROR! The handlers/main.yml file for role 'vector-role' must contain a list of tasks

The error appears to be in '/home/alexander/Netology/devops-netology/HomeWork/ansible/08-ansible-04-role/role/vector-role/handlers/main.yml': line 12, column 1, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:


handlers:
^ here
CRITICAL Ansible return code was 4, command was: ansible-playbook --inventory /root/.cache/molecule/vector-role/default/inventory --skip-tags molecule-notest,notest /home/alexander/Netology/devops-netology/HomeWork/ansible/08-ansible-04-role/role/vector-role/molecule/default/converge.yml
```
Устранил, убрал handlers:, должен быть просто список тасок.  

*Ошибка:*
```bash
fatal: [instance-2]: FAILED! => {"ansible_facts": {"pkg_mgr": "apt"}, "changed": false, "msg": ["Could not detect which major revision of yum is in use, which is required to determine module backend.", "You should manually specify use_backend to tell the module whether to use the yum (yum3) or dnf (yum4) backend})"]}
fatal: [instance-1]: FAILED! => {"changed": false, "msg": "Failed to validate GPG signature for vector-0.32.1-1.x86_64: Package vector-0.32.1-1.x86_64.rpm is not signed"}
```
Устранил, добавил в ansible.builtin.yum, disable_gpg_check: true  

```bash
RUNNING HANDLER [vector-role : Start vector service] ***************************
fatal: [centos7]: FAILED! => {"changed": false, "msg": "Service is in unknown state", "status": {}}
```  
Хендлер не запускает сервис, потому-что в контейнере не работает systemd, не могу решить эту проблему.

4. Добавьте несколько assert в verify.yml-файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска и др.). 

6. Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./example).
2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`, где path_to_repo — путь до корня репозитория с vector-role на вашей файловой системе.
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.
5. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.
6. Пропишите правильную команду в `tox.ini`, чтобы запускался облегчённый сценарий.
8. Запустите команду `tox`. Убедитесь, что всё отработало успешно.
9. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.

После выполнения у вас должно получится два сценария molecule и один tox.ini файл в репозитории. Не забудьте указать в ответе теги решений Tox и Molecule заданий. В качестве решения пришлите ссылку на  ваш репозиторий и скриншоты этапов выполнения задания. 

## Необязательная часть

1. Проделайте схожие манипуляции для создания роли LightHouse.
2. Создайте сценарий внутри любой из своих ролей, который умеет поднимать весь стек при помощи всех ролей.
3. Убедитесь в работоспособности своего стека. Создайте отдельный verify.yml, который будет проверять работоспособность интеграции всех инструментов между ними.
4. Выложите свои roles в репозитории.

В качестве решения пришлите ссылки и скриншоты этапов выполнения задания.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.