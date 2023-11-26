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
2. Перейдите в каталог с ролью vector-role и создайте сценарий тестирования по умолчанию при помощи `molecule init scenario --driver-name docker`.
3. Добавьте несколько разных дистрибутивов (centos:8, ubuntu:latest) для инстансов и протестируйте роль, исправьте найденные ошибки, если они есть.
4. Добавьте несколько assert в verify.yml-файл для  проверки работоспособности vector-role (проверка, что конфиг валидный, проверка успешности запуска и др.). 
5. Запустите тестирование роли повторно и проверьте, что оно прошло успешно.
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