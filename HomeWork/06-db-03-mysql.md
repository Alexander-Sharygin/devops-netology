## Задача 1

Используя Docker, поднимите инстанс MySQL (версию 8). Данные БД сохраните в volume.

```bash
docker run --name mysql -d \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=123QWEas \
    -v mysql:/var/lib/mysql
    mysql:latest
```
Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/virt-11/06-db-03-mysql/test_data) и 
восстановитесь из него.

```bash
wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-03-mysql/test_data/test_dump.sql
mysql --host=localhost --protocol=TCP --password=123QWEas
mysql> CREATE DATABASE test_db;
Query OK, 1 row affected (0,08 sec)
mysql> use test_db;
Database changed
mysql> source test_dump.sql
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,01 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,02 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,01 sec)
Query OK, 0 rows affected (0,15 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,02 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 5 rows affected (0,02 sec)
Records: 5  Duplicates: 0  Warnings: 0
Query OK, 0 rows affected (0,03 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
Query OK, 0 rows affected (0,00 sec)
```
Перейдите в управляющую консоль `mysql` внутри контейнера.

Используя команду `\h`, получите список управляющих команд.

Найдите команду для выдачи статуса БД и **приведите в ответе** из её вывода версию сервера БД.

Подключитесь к восстановленной БД и получите список таблиц из этой БД.

**Приведите в ответе** количество записей с `price` > 300.

В следующих заданиях мы будем продолжать работу с этим контейнером.
```bash
\h
status
Server version:		8.0.33 MySQL Community Server - GPL
mysql> SHOW TABLES;
+-------------------+
| Tables_in_test_db |
+-------------------+
| orders            |
+-------------------+
1 row in set (0,01 sec)

mysql> SELECT COUNT(*) FROM orders WHERE price > 300;
+----------+
| COUNT(*) |
+----------+
|        1 |
+----------+
1 row in set (0,00 sec)

```


## Задача 2

Создайте пользователя test в БД c паролем test-pass, используя:

- плагин авторизации mysql_native_password
- срок истечения пароля — 180 дней 
- количество попыток авторизации — 3 
- максимальное количество запросов в час — 100
- аттрибуты пользователя:
    - Фамилия "Pretty"
    - Имя "James".


Предоставьте привелегии пользователю `test` на операции SELECT базы `test_db`.
    
Используя таблицу INFORMATION_SCHEMA.USER_ATTRIBUTES, получите данные по пользователю `test` и 
**приведите в ответе к задаче**.
```bash
CREATE USER 'test'@'localhost' 
IDENTIFIED WITH mysql_native_password BY 'test-pass'
WITH MAX_CONNECTIONS_PER_HOUR 100
PASSWORD EXPIRE INTERVAL 180 DAY
FAILED_LOGIN_ATTEMPTS 3 PASSWORD_LOCK_TIME 2
ATTRIBUTE '{"first_name":"James", "last_name":"Pretty"}';

GRANT SELECT ON test_db.* TO test@localhost;

mysql> SELECT * FROM INFORMATION_SCHEMA.USER_ATTRIBUTES WHERE USER = 'test';
+------+-----------+------------------------------------------------+
| USER | HOST      | ATTRIBUTE                                      |
+------+-----------+------------------------------------------------+
| test | localhost | {"last_name": "Pretty", "first_name": "James"} |
+------+-----------+------------------------------------------------+
1 row in set (0,02 sec)
```

## Задача 3

Установите профилирование `SET profiling = 1`.
Изучите вывод профилирования команд `SHOW PROFILES;`.

Исследуйте, какой `engine` используется в таблице БД `test_db` и **приведите в ответе**.

Измените `engine` и **приведите время выполнения и запрос на изменения из профайлера в ответе**:
- на `MyISAM`,
- на `InnoDB`.
```bash
mysql> SET profiling = 1;
Query OK, 0 rows affected, 1 warning (0,01 sec)
mysql> SHOW PROFILES;
+----------+------------+-------------------+
| Query_ID | Duration   | Query             |
+----------+------------+-------------------+
|        1 | 0.00769350 | SET profiling = 1 |
+----------+------------+-------------------+
1 row in set, 1 warning (0,00 sec)

SELECT table_schema,table_name,engine FROM information_schema.tables WHERE table_schema = 'test_db';
+--------------+------------+--------+
| TABLE_SCHEMA | TABLE_NAME | ENGINE |
+--------------+------------+--------+
| test_db      | orders     | InnoDB |
+--------------+------------+--------+
1 row in set (0,01 sec)

mysql> ALTER TABLE orders ENGINE = MyISAM;
Query OK, 5 rows affected (0,14 sec)
Records: 5  Duplicates: 0  Warnings: 0
mysql> ALTER TABLE orders ENGINE = InnoDB;
Query OK, 5 rows affected (0,18 sec)
Records: 5  Duplicates: 0  Warnings: 0
mysql> SHOW PROFILES;
+----------+------------+------------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                                |
+----------+------------+------------------------------------------------------------------------------------------------------+
|       14 | 0.14701925 | ALTER TABLE orders ENGINE = MyISAM                                                                   |
|       15 | 0.18682100 | ALTER TABLE orders ENGINE = InnoDB                                                                   |
+----------+------------+------------------------------------------------------------------------------------------------------+
15 rows in set, 1 warning (0,01 sec)
```


## Задача 4 

Изучите файл `my.cnf` в директории /etc/mysql.

Измените его согласно ТЗ (движок InnoDB):

- скорость IO важнее сохранности данных;
- нужна компрессия таблиц для экономии места на диске;
- размер буффера с незакомиченными транзакциями 1 Мб;
- буффер кеширования 30% от ОЗУ;
- размер файла логов операций 100 Мб.

Приведите в ответе изменённый файл `my.cnf`.
```bash
cat my.cnf 
# For advice on how to change settings please see
# http://dev.mysql.com/doc/refman/8.0/en/server-configuration-defaults.html

[mysqld]
#
# Remove leading # and set to the amount of RAM for the most important data
# cache in MySQL. Start at 70% of total RAM for dedicated server, else 10%.
# innodb_buffer_pool_size = 128M
#
# Remove leading # to turn on a very important data integrity option: logging
# changes to the binary log between backups.
# log_bin
#
# Remove leading # to set options mainly useful for reporting servers.
# The server defaults are faster for transactions and fast SELECTs.
# Adjust sizes as needed, experiment to find the optimal values.
# join_buffer_size = 128M
# sort_buffer_size = 2M
# read_rnd_buffer_size = 2M

# Remove leading # to revert to previous value for default_authentication_plugin,
# this will increase compatibility with older clients. For background, see:
# https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_default_authentication_plugin
# default-authentication-plugin=mysql_native_password
skip-host-cache
skip-name-resolve
datadir=/var/lib/mysql
socket=/var/run/mysqld/mysqld.sock
secure-file-priv=/var/lib/mysql-files
user=mysql

pid-file=/var/run/mysqld/mysqld.pid
[client]
socket=/var/run/mysqld/mysqld.sock

!includedir /etc/mysql/conf.d/

innodb_flush_log_at_trx_commit = 0
innodb_file_per_table = ON
innodb_log_buffer_size = 1M
innodb_buffer_pool_size = 3G
innodb_log_file_size = 100M
```

---