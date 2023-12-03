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
**Выполнено** [verify.yml](https://github.com/Alexander-Sharygin/vector-role/blob/master/molecule/default/verify.yml)
6. Запустите тестирование роли повторно и проверьте, что оно прошло успешно.  
Проверку статуса сервиса выполнить также не удается из-за не работающего systemd в контейнере.  
````bash
TASK [Get information about vector] ********************************************
fatal: [centos7]: FAILED! => {"ansible_facts": {"discovered_interpreter_python": "/usr/bin/python"}, "changed": false, "cmd": ["systemctl", "status", "vector"], "delta": "0:00:00.179890", "end": "2023-12-03 06:27:36.344317", "msg": "non-zero return code", "rc": 1, "start": "2023-12-03 06:27:36.164427", "stderr": "Failed to get D-Bus connection: Operation not permitted", "stderr_lines": ["Failed to get D-Bus connection: Operation not permitted"], "stdout": "", "stdout_lines": []}
````
Проверка конфига
````bash
TASK [Validate vector configuration] *******************************************
ok: [centos7]

TASK [Assert vector configuragtion] ********************************************
ok: [centos7] => {
    "changed": false,
    "msg": "All assertions passed"
}
````
5. Добавьте новый тег на коммит с рабочим сценарием в соответствии с семантическим версионированием.  
**Выполнено** tag 1.0.3

### Tox

1. Добавьте в директорию с vector-role файлы из [директории](./example).
2. Запустите `docker run --privileged=True -v <path_to_repo>:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash`, где path_to_repo — путь до корня репозитория с vector-role на вашей файловой системе.
3. Внутри контейнера выполните команду `tox`, посмотрите на вывод.  
````bash
alexander@ThinkBook-14-G2-ARE:~/Netology/git/mnt-homeworks/08-ansible-05-testing/example$ sudo docker run --privileged=True -v /home/alexander/Netology/devops-netology/HomeWork/ansible/08-ansible-04-role/role/vector-role:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash
[root@d78af54cfe64 vector-role]# tox
py37-ansible210 create: /opt/vector-role/.tox/py37-ansible210
py37-ansible210 installdeps: -rtox-requirements.txt, ansible<3.0
py37-ansible210 installed: ansible==2.10.7,ansible-base==2.10.17,ansible-compat==1.0.0,ansible-lint==5.1.3,arrow==1.2.3,bcrypt==4.1.1,binaryornot==0.4.4,bracex==2.3.post1,cached-property==1.5.2,Cerberus==1.3.5,certifi==2023.11.17,cffi==1.15.1,chardet==5.2.0,charset-normalizer==3.3.2,click==8.1.7,click-help-colors==0.9.4,cookiecutter==2.5.0,cryptography==41.0.7,distro==1.8.0,enrich==1.2.7,idna==3.6,importlib-metadata==6.7.0,Jinja2==3.1.2,jmespath==1.0.1,lxml==4.9.3,markdown-it-py==2.2.0,MarkupSafe==2.1.3,mdurl==0.1.2,molecule==3.5.2,molecule-podman==1.1.0,packaging==23.2,paramiko==2.12.0,pathspec==0.11.2,pluggy==1.2.0,pycparser==2.21,Pygments==2.17.2,PyNaCl==1.5.0,python-dateutil==2.8.2,python-slugify==8.0.1,PyYAML==5.4.1,requests==2.31.0,rich==13.7.0,ruamel.yaml==0.18.5,ruamel.yaml.clib==0.2.8,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.2.3,text-unidecode==1.3,typing_extensions==4.7.1,urllib3==2.0.7,wcmatch==8.4.1,yamllint==1.26.3,zipp==3.15.0
py37-ansible210 run-test-pre: PYTHONHASHSEED='1757863550'
py37-ansible210 run-test: commands[0] | molecule test -s compatibility --destroy always
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible210/bin/molecule test -s compatibility --destroy always (exited with code 1)
py37-ansible30 create: /opt/vector-role/.tox/py37-ansible30
py37-ansible30 installdeps: -rtox-requirements.txt, ansible<3.1
py37-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==1.0.0,ansible-lint==5.1.3,arrow==1.2.3,bcrypt==4.1.1,binaryornot==0.4.4,bracex==2.3.post1,cached-property==1.5.2,Cerberus==1.3.5,certifi==2023.11.17,cffi==1.15.1,chardet==5.2.0,charset-normalizer==3.3.2,click==8.1.7,click-help-colors==0.9.4,cookiecutter==2.5.0,cryptography==41.0.7,distro==1.8.0,enrich==1.2.7,idna==3.6,importlib-metadata==6.7.0,Jinja2==3.1.2,jmespath==1.0.1,lxml==4.9.3,markdown-it-py==2.2.0,MarkupSafe==2.1.3,mdurl==0.1.2,molecule==3.5.2,molecule-podman==1.1.0,packaging==23.2,paramiko==2.12.0,pathspec==0.11.2,pluggy==1.2.0,pycparser==2.21,Pygments==2.17.2,PyNaCl==1.5.0,python-dateutil==2.8.2,python-slugify==8.0.1,PyYAML==5.4.1,requests==2.31.0,rich==13.7.0,ruamel.yaml==0.18.5,ruamel.yaml.clib==0.2.8,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.2.3,text-unidecode==1.3,typing_extensions==4.7.1,urllib3==2.0.7,wcmatch==8.4.1,yamllint==1.26.3,zipp==3.15.0
py37-ansible30 run-test-pre: PYTHONHASHSEED='1757863550'
py37-ansible30 run-test: commands[0] | molecule test -s compatibility --destroy always
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible30/bin/molecule test -s compatibility --destroy always (exited with code 1)
py39-ansible210 create: /opt/vector-role/.tox/py39-ansible210
py39-ansible210 installdeps: -rtox-requirements.txt, ansible<3.0
py39-ansible210 installed: ansible==2.10.7,ansible-base==2.10.17,ansible-compat==4.1.10,ansible-core==2.15.6,ansible-lint==5.1.3,arrow==1.3.0,attrs==23.1.0,bcrypt==4.1.1,binaryornot==0.4.4,bracex==2.4,Cerberus==1.3.5,certifi==2023.11.17,cffi==1.16.0,chardet==5.2.0,charset-normalizer==3.3.2,click==8.1.7,click-help-colors==0.9.4,cookiecutter==2.5.0,cryptography==41.0.7,distro==1.8.0,enrich==1.2.7,idna==3.6,importlib-resources==5.0.7,Jinja2==3.1.2,jmespath==1.0.1,jsonschema==4.20.0,jsonschema-specifications==2023.11.2,lxml==4.9.3,markdown-it-py==3.0.0,MarkupSafe==2.1.3,mdurl==0.1.2,molecule==3.5.2,molecule-podman==2.0.0,packaging==23.2,paramiko==2.12.0,pathspec==0.11.2,pluggy==1.3.0,pycparser==2.21,Pygments==2.17.2,PyNaCl==1.5.0,python-dateutil==2.8.2,python-slugify==8.0.1,PyYAML==5.4.1,referencing==0.31.1,requests==2.31.0,resolvelib==1.0.1,rich==13.7.0,rpds-py==0.13.2,ruamel.yaml==0.18.5,ruamel.yaml.clib==0.2.8,selinux==0.3.0,six==1.16.0,subprocess-tee==0.4.1,tenacity==8.2.3,text-unidecode==1.3,types-python-dateutil==2.8.19.14,typing_extensions==4.8.0,urllib3==2.1.0,wcmatch==8.5,yamllint==1.26.3
py39-ansible210 run-test-pre: PYTHONHASHSEED='1757863550'
py39-ansible210 run-test: commands[0] | molecule test -s compatibility --destroy always
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py39-ansible210/bin/molecule test -s compatibility --destroy always (exited with code 1)
py39-ansible30 create: /opt/vector-role/.tox/py39-ansible30
py39-ansible30 installdeps: -rtox-requirements.txt, ansible<3.1
py39-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==4.1.10,ansible-core==2.15.6,ansible-lint==5.1.3,arrow==1.3.0,attrs==23.1.0,bcrypt==4.1.1,binaryornot==0.4.4,bracex==2.4,Cerberus==1.3.5,certifi==2023.11.17,cffi==1.16.0,chardet==5.2.0,charset-normalizer==3.3.2,click==8.1.7,click-help-colors==0.9.4,cookiecutter==2.5.0,cryptography==41.0.7,distro==1.8.0,enrich==1.2.7,idna==3.6,importlib-resources==5.0.7,Jinja2==3.1.2,jmespath==1.0.1,jsonschema==4.20.0,jsonschema-specifications==2023.11.2,lxml==4.9.3,markdown-it-py==3.0.0,MarkupSafe==2.1.3,mdurl==0.1.2,molecule==3.5.2,molecule-podman==2.0.0,packaging==23.2,paramiko==2.12.0,pathspec==0.11.2,pluggy==1.3.0,pycparser==2.21,Pygments==2.17.2,PyNaCl==1.5.0,python-dateutil==2.8.2,python-slugify==8.0.1,PyYAML==5.4.1,referencing==0.31.1,requests==2.31.0,resolvelib==1.0.1,rich==13.7.0,rpds-py==0.13.2,ruamel.yaml==0.18.5,ruamel.yaml.clib==0.2.8,selinux==0.3.0,six==1.16.0,subprocess-tee==0.4.1,tenacity==8.2.3,text-unidecode==1.3,types-python-dateutil==2.8.19.14,typing_extensions==4.8.0,urllib3==2.1.0,wcmatch==8.5,yamllint==1.26.3
py39-ansible30 run-test-pre: PYTHONHASHSEED='1757863550'
py39-ansible30 run-test: commands[0] | molecule test -s compatibility --destroy always
CRITICAL 'molecule/compatibility/molecule.yml' glob failed.  Exiting.
ERROR: InvocationError for command /opt/vector-role/.tox/py39-ansible30/bin/molecule test -s compatibility --destroy always (exited with code 1)
__________________________________________________________________________________________________ summary __________________________________________________________________________________________________
ERROR:   py37-ansible210: commands failed
ERROR:   py37-ansible30: commands failed
ERROR:   py39-ansible210: commands failed
ERROR:   py39-ansible30: commands failed
````
6. Создайте облегчённый сценарий для `molecule` с драйвером `molecule_podman`. Проверьте его на исполнимость.  
````bash
molecule init scenario tox --driver-name=podman
````
6. Пропишите правильную команду в `tox.ini`, чтобы запускался облегчённый сценарий.
```yaml
    {posargs:molecule test -s tox --destroy always}
```
9. Запустите команду `tox`. Убедитесь, что всё отработало успешно.  
Не работает, почему не понятно.
```bash
alexander@ThinkBook-14-G2-ARE:~/Netology/devops-netology/HomeWork/ansible/08-ansible-04-role/role/vector-role$ sudo docker run --privileged=True -v /home/alexander/Netology/devops-netology/HomeWork/ansible/08-ansible-04-role/role/vector-role:/opt/vector-role -w /opt/vector-role -it aragast/netology:latest /bin/bash
[sudo] password for alexander: 
[root@aad6a8307cb1 vector-role]# tox
py37-ansible210 installed: ansible==2.10.7,ansible-base==2.10.17,ansible-compat==1.0.0,ansible-lint==5.1.3,arrow==1.2.3,bcrypt==4.1.1,binaryornot==0.4.4,bracex==2.3.post1,cached-property==1.5.2,Cerberus==1.3.5,certifi==2023.11.17,cffi==1.15.1,chardet==5.2.0,charset-normalizer==3.3.2,click==8.1.7,click-help-colors==0.9.4,cookiecutter==2.5.0,cryptography==41.0.7,distro==1.8.0,enrich==1.2.7,idna==3.6,importlib-metadata==6.7.0,Jinja2==3.1.2,jmespath==1.0.1,lxml==4.9.3,markdown-it-py==2.2.0,MarkupSafe==2.1.3,mdurl==0.1.2,molecule==3.5.2,molecule-podman==1.1.0,packaging==23.2,paramiko==2.12.0,pathspec==0.11.2,pluggy==1.2.0,pycparser==2.21,Pygments==2.17.2,PyNaCl==1.5.0,python-dateutil==2.8.2,python-slugify==8.0.1,PyYAML==5.4.1,requests==2.31.0,rich==13.7.0,ruamel.yaml==0.18.5,ruamel.yaml.clib==0.2.8,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.2.3,text-unidecode==1.3,typing_extensions==4.7.1,urllib3==2.0.7,wcmatch==8.4.1,yamllint==1.26.3,zipp==3.15.0
py37-ansible210 run-test-pre: PYTHONHASHSEED='1514319976'
py37-ansible210 run-test: commands[0] | molecule test -s tox --destroy always
INFO     tox scenario test matrix: destroy, create, converge, destroy
INFO     Performing prerun...
INFO     Set ANSIBLE_LIBRARY=/root/.cache/ansible-compat/b984a4/modules:/root/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/root/.cache/ansible-compat/b984a4/collections:/root/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/root/.cache/ansible-compat/b984a4/roles:/root/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Running tox > destroy
INFO     Sanity checks: 'podman'

PLAY [Destroy] *****************************************************************

TASK [Populate instance config] ************************************************
ok: [localhost]

TASK [Dump instance config] ****************************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Running tox > create

PLAY [Create] ******************************************************************

TASK [Populate instance config dict] *******************************************
skipping: [localhost]

TASK [Convert instance config dict to a list] **********************************
skipping: [localhost]

TASK [Dump instance config] ****************************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=0    changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

INFO     Running tox > converge

PLAY [Converge] ****************************************************************

TASK [Include vector-role] *****************************************************

TASK [vector-role : Create directory for vector data "/var/lib/vector/test"] ***
fatal: [centos7]: UNREACHABLE! => {"changed": false, "msg": "Failed to create temporary directory.In some cases, you may have been able to authenticate and did not have permissions on the target directory. Consider changing the remote tmp path in ansible.cfg to a path rooted in \"/tmp\", for more error information use -vvv. Failed command was: ( umask 77 && mkdir -p \"` echo ~/.ansible/tmp `\"&& mkdir \"` echo ~/.ansible/tmp/ansible-tmp-1701626780.4821253-80-145908694066034 `\" && echo ansible-tmp-1701626780.4821253-80-145908694066034=\"` echo ~/.ansible/tmp/ansible-tmp-1701626780.4821253-80-145908694066034 `\" ), exited with result 125", "unreachable": true}

PLAY RECAP *********************************************************************
centos7                    : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0

CRITICAL Ansible return code was 4, command was: ['ansible-playbook', '--inventory', '/root/.cache/molecule/vector-role/tox/inventory', '--skip-tags', 'molecule-notest,notest', '/opt/vector-role/molecule/tox/converge.yml']
WARNING  An error occurred during the test sequence action: 'converge'. Cleaning up.
INFO     Running tox > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running tox > destroy

PLAY [Destroy] *****************************************************************

TASK [Populate instance config] ************************************************
ok: [localhost]

TASK [Dump instance config] ****************************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible210/bin/molecule test -s tox --destroy always (exited with code 1)
py37-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==1.0.0,ansible-lint==5.1.3,arrow==1.2.3,bcrypt==4.1.1,binaryornot==0.4.4,bracex==2.3.post1,cached-property==1.5.2,Cerberus==1.3.5,certifi==2023.11.17,cffi==1.15.1,chardet==5.2.0,charset-normalizer==3.3.2,click==8.1.7,click-help-colors==0.9.4,cookiecutter==2.5.0,cryptography==41.0.7,distro==1.8.0,enrich==1.2.7,idna==3.6,importlib-metadata==6.7.0,Jinja2==3.1.2,jmespath==1.0.1,lxml==4.9.3,markdown-it-py==2.2.0,MarkupSafe==2.1.3,mdurl==0.1.2,molecule==3.5.2,molecule-podman==1.1.0,packaging==23.2,paramiko==2.12.0,pathspec==0.11.2,pluggy==1.2.0,pycparser==2.21,Pygments==2.17.2,PyNaCl==1.5.0,python-dateutil==2.8.2,python-slugify==8.0.1,PyYAML==5.4.1,requests==2.31.0,rich==13.7.0,ruamel.yaml==0.18.5,ruamel.yaml.clib==0.2.8,selinux==0.2.1,six==1.16.0,subprocess-tee==0.3.5,tenacity==8.2.3,text-unidecode==1.3,typing_extensions==4.7.1,urllib3==2.0.7,wcmatch==8.4.1,yamllint==1.26.3,zipp==3.15.0
py37-ansible30 run-test-pre: PYTHONHASHSEED='1514319976'
py37-ansible30 run-test: commands[0] | molecule test -s tox --destroy always
INFO     tox scenario test matrix: destroy, create, converge, destroy
INFO     Performing prerun...
INFO     Set ANSIBLE_LIBRARY=/root/.cache/ansible-compat/b984a4/modules:/root/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/root/.cache/ansible-compat/b984a4/collections:/root/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/root/.cache/ansible-compat/b984a4/roles:/root/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Running tox > destroy
INFO     Sanity checks: 'podman'

PLAY [Destroy] *****************************************************************

TASK [Populate instance config] ************************************************
ok: [localhost]

TASK [Dump instance config] ****************************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Running tox > create

PLAY [Create] ******************************************************************

TASK [Populate instance config dict] *******************************************
skipping: [localhost]

TASK [Convert instance config dict to a list] **********************************
skipping: [localhost]

TASK [Dump instance config] ****************************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=0    changed=0    unreachable=0    failed=0    skipped=3    rescued=0    ignored=0

INFO     Running tox > converge

PLAY [Converge] ****************************************************************

TASK [Include vector-role] *****************************************************

TASK [vector-role : Create directory for vector data "/var/lib/vector/test"] ***
fatal: [centos7]: UNREACHABLE! => {"changed": false, "msg": "Failed to create temporary directory.In some cases, you may have been able to authenticate and did not have permissions on the target directory. Consider changing the remote tmp path in ansible.cfg to a path rooted in \"/tmp\", for more error information use -vvv. Failed command was: ( umask 77 && mkdir -p \"` echo ~/.ansible/tmp `\"&& mkdir \"` echo ~/.ansible/tmp/ansible-tmp-1701626790.0956237-187-25242816919235 `\" && echo ansible-tmp-1701626790.0956237-187-25242816919235=\"` echo ~/.ansible/tmp/ansible-tmp-1701626790.0956237-187-25242816919235 `\" ), exited with result 125", "unreachable": true}

PLAY RECAP *********************************************************************
centos7                    : ok=0    changed=0    unreachable=1    failed=0    skipped=0    rescued=0    ignored=0

CRITICAL Ansible return code was 4, command was: ['ansible-playbook', '--inventory', '/root/.cache/molecule/vector-role/tox/inventory', '--skip-tags', 'molecule-notest,notest', '/opt/vector-role/molecule/tox/converge.yml']
WARNING  An error occurred during the test sequence action: 'converge'. Cleaning up.
INFO     Running tox > cleanup
WARNING  Skipping, cleanup playbook not configured.
INFO     Running tox > destroy

PLAY [Destroy] *****************************************************************

TASK [Populate instance config] ************************************************
ok: [localhost]

TASK [Dump instance config] ****************************************************
skipping: [localhost]

PLAY RECAP *********************************************************************
localhost                  : ok=1    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0

INFO     Pruning extra files from scenario ephemeral directory
ERROR: InvocationError for command /opt/vector-role/.tox/py37-ansible30/bin/molecule test -s tox --destroy always (exited with code 1)
py39-ansible210 installed: ansible==2.10.7,ansible-base==2.10.17,ansible-compat==4.1.10,ansible-core==2.15.6,ansible-lint==5.1.3,arrow==1.3.0,attrs==23.1.0,bcrypt==4.1.1,binaryornot==0.4.4,bracex==2.4,Cerberus==1.3.5,certifi==2023.11.17,cffi==1.16.0,chardet==5.2.0,charset-normalizer==3.3.2,click==8.1.7,click-help-colors==0.9.4,cookiecutter==2.5.0,cryptography==41.0.7,distro==1.8.0,enrich==1.2.7,idna==3.6,importlib-resources==5.0.7,Jinja2==3.1.2,jmespath==1.0.1,jsonschema==4.20.0,jsonschema-specifications==2023.11.2,lxml==4.9.3,markdown-it-py==3.0.0,MarkupSafe==2.1.3,mdurl==0.1.2,molecule==3.5.2,molecule-podman==2.0.0,packaging==23.2,paramiko==2.12.0,pathspec==0.11.2,pluggy==1.3.0,pycparser==2.21,Pygments==2.17.2,PyNaCl==1.5.0,python-dateutil==2.8.2,python-slugify==8.0.1,PyYAML==5.4.1,referencing==0.31.1,requests==2.31.0,resolvelib==1.0.1,rich==13.7.0,rpds-py==0.13.2,ruamel.yaml==0.18.5,ruamel.yaml.clib==0.2.8,selinux==0.3.0,six==1.16.0,subprocess-tee==0.4.1,tenacity==8.2.3,text-unidecode==1.3,types-python-dateutil==2.8.19.14,typing_extensions==4.8.0,urllib3==2.1.0,wcmatch==8.5,yamllint==1.26.3
py39-ansible210 run-test-pre: PYTHONHASHSEED='1514319976'
py39-ansible210 run-test: commands[0] | molecule test -s tox --destroy always
INFO     tox scenario test matrix: destroy, create, converge, destroy
INFO     Performing prerun...
INFO     Set ANSIBLE_LIBRARY=/root/.cache/ansible-compat/f5bcd7/modules:/root/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/root/.cache/ansible-compat/f5bcd7/collections:/root/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/root/.cache/ansible-compat/f5bcd7/roles:/root/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Running tox > destroy
INFO     Sanity checks: 'podman'
Traceback (most recent call last):
  File "/opt/vector-role/.tox/py39-ansible210/bin/molecule", line 8, in <module>
    sys.exit(main())
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/click/core.py", line 1157, in __call__
    return self.main(*args, **kwargs)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/click/core.py", line 1078, in main
    rv = self.invoke(ctx)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/click/core.py", line 1688, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/click/core.py", line 1434, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/click/core.py", line 783, in invoke
    return __callback(*args, **kwargs)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/click/decorators.py", line 33, in new_func
    return f(get_current_context(), *args, **kwargs)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule/command/test.py", line 159, in test
    base.execute_cmdline_scenarios(scenario_name, args, command_args, ansible_args)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule/command/base.py", line 118, in execute_cmdline_scenarios
    execute_scenario(scenario)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule/command/base.py", line 160, in execute_scenario
    execute_subcommand(scenario.config, action)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule/command/base.py", line 149, in execute_subcommand
    return command(config).execute()
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule/logger.py", line 188, in wrapper
    rt = func(*args, **kwargs)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule/command/destroy.py", line 107, in execute
    self._config.provisioner.destroy()
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule/provisioner/ansible.py", line 705, in destroy
    pb.execute()
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule/provisioner/ansible_playbook.py", line 110, in execute
    self._config.driver.sanity_checks()
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/molecule_podman/driver.py", line 224, in sanity_checks
    if runtime.version < Version("2.10.0"):
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/ansible_compat/runtime.py", line 393, in version
    self._version = parse_ansible_version(proc.stdout)
  File "/opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/ansible_compat/config.py", line 44, in parse_ansible_version
    raise InvalidPrerequisiteError(msg)
ansible_compat.errors.InvalidPrerequisiteError: Unable to parse ansible cli version: ansible 2.10.17
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/vector-role/.tox/py39-ansible210/lib/python3.9/site-packages/ansible
  executable location = /opt/vector-role/.tox/py39-ansible210/bin/ansible
  python version = 3.9.2 (default, Jun 13 2022, 19:42:33) [GCC 8.5.0 20210514 (Red Hat 8.5.0-10)]

Keep in mind that only 2.12 or newer are supported.
ERROR: InvocationError for command /opt/vector-role/.tox/py39-ansible210/bin/molecule test -s tox --destroy always (exited with code 1)
py39-ansible30 installed: ansible==3.0.0,ansible-base==2.10.17,ansible-compat==4.1.10,ansible-core==2.15.6,ansible-lint==5.1.3,arrow==1.3.0,attrs==23.1.0,bcrypt==4.1.1,binaryornot==0.4.4,bracex==2.4,Cerberus==1.3.5,certifi==2023.11.17,cffi==1.16.0,chardet==5.2.0,charset-normalizer==3.3.2,click==8.1.7,click-help-colors==0.9.4,cookiecutter==2.5.0,cryptography==41.0.7,distro==1.8.0,enrich==1.2.7,idna==3.6,importlib-resources==5.0.7,Jinja2==3.1.2,jmespath==1.0.1,jsonschema==4.20.0,jsonschema-specifications==2023.11.2,lxml==4.9.3,markdown-it-py==3.0.0,MarkupSafe==2.1.3,mdurl==0.1.2,molecule==3.5.2,molecule-podman==2.0.0,packaging==23.2,paramiko==2.12.0,pathspec==0.11.2,pluggy==1.3.0,pycparser==2.21,Pygments==2.17.2,PyNaCl==1.5.0,python-dateutil==2.8.2,python-slugify==8.0.1,PyYAML==5.4.1,referencing==0.31.1,requests==2.31.0,resolvelib==1.0.1,rich==13.7.0,rpds-py==0.13.2,ruamel.yaml==0.18.5,ruamel.yaml.clib==0.2.8,selinux==0.3.0,six==1.16.0,subprocess-tee==0.4.1,tenacity==8.2.3,text-unidecode==1.3,types-python-dateutil==2.8.19.14,typing_extensions==4.8.0,urllib3==2.1.0,wcmatch==8.5,yamllint==1.26.3
py39-ansible30 run-test-pre: PYTHONHASHSEED='1514319976'
py39-ansible30 run-test: commands[0] | molecule test -s tox --destroy always
INFO     tox scenario test matrix: destroy, create, converge, destroy
INFO     Performing prerun...
INFO     Set ANSIBLE_LIBRARY=/root/.cache/ansible-compat/f5bcd7/modules:/root/.ansible/plugins/modules:/usr/share/ansible/plugins/modules
INFO     Set ANSIBLE_COLLECTIONS_PATH=/root/.cache/ansible-compat/f5bcd7/collections:/root/.ansible/collections:/usr/share/ansible/collections
INFO     Set ANSIBLE_ROLES_PATH=/root/.cache/ansible-compat/f5bcd7/roles:/root/.ansible/roles:/usr/share/ansible/roles:/etc/ansible/roles
INFO     Running tox > destroy
INFO     Sanity checks: 'podman'
Traceback (most recent call last):
  File "/opt/vector-role/.tox/py39-ansible30/bin/molecule", line 8, in <module>
    sys.exit(main())
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/click/core.py", line 1157, in __call__
    return self.main(*args, **kwargs)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/click/core.py", line 1078, in main
    rv = self.invoke(ctx)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/click/core.py", line 1688, in invoke
    return _process_result(sub_ctx.command.invoke(sub_ctx))
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/click/core.py", line 1434, in invoke
    return ctx.invoke(self.callback, **ctx.params)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/click/core.py", line 783, in invoke
    return __callback(*args, **kwargs)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/click/decorators.py", line 33, in new_func
    return f(get_current_context(), *args, **kwargs)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule/command/test.py", line 159, in test
    base.execute_cmdline_scenarios(scenario_name, args, command_args, ansible_args)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule/command/base.py", line 118, in execute_cmdline_scenarios
    execute_scenario(scenario)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule/command/base.py", line 160, in execute_scenario
    execute_subcommand(scenario.config, action)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule/command/base.py", line 149, in execute_subcommand
    return command(config).execute()
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule/logger.py", line 188, in wrapper
    rt = func(*args, **kwargs)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule/command/destroy.py", line 107, in execute
    self._config.provisioner.destroy()
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule/provisioner/ansible.py", line 705, in destroy
    pb.execute()
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule/provisioner/ansible_playbook.py", line 110, in execute
    self._config.driver.sanity_checks()
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/molecule_podman/driver.py", line 224, in sanity_checks
    if runtime.version < Version("2.10.0"):
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/ansible_compat/runtime.py", line 393, in version
    self._version = parse_ansible_version(proc.stdout)
  File "/opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/ansible_compat/config.py", line 44, in parse_ansible_version
    raise InvalidPrerequisiteError(msg)
ansible_compat.errors.InvalidPrerequisiteError: Unable to parse ansible cli version: ansible 2.10.17
  config file = None
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /opt/vector-role/.tox/py39-ansible30/lib/python3.9/site-packages/ansible
  executable location = /opt/vector-role/.tox/py39-ansible30/bin/ansible
  python version = 3.9.2 (default, Jun 13 2022, 19:42:33) [GCC 8.5.0 20210514 (Red Hat 8.5.0-10)]

Keep in mind that only 2.12 or newer are supported.
ERROR: InvocationError for command /opt/vector-role/.tox/py39-ansible30/bin/molecule test -s tox --destroy always (exited with code 1)
__________________________________________________________________________________________________ summary __________________________________________________________________________________________________
ERROR:   py37-ansible210: commands failed
ERROR:   py37-ansible30: commands failed
ERROR:   py39-ansible210: commands failed
ERROR:   py39-ansible30: commands failed
````
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