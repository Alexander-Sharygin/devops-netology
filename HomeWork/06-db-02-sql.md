## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.
```yaml
version: '3'
services:
  database:
    image: 'postgres:12'
    ports:
      - 5432:5432

    environment:
      POSTGRES_USER: puser # The PostgreSQL user (useful to connect to the database)
      POSTGRES_PASSWORD: 123qweas # The PostgreSQL password (useful to connect to the database)
    volumes:
      - ./db-data/:/var/lib/postgresql/data/
      - ./backup:/mnt/backup
```

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

psql -h localhost -U puser
puser=# CREATE USER "test-admin-user" WITH PASSWORD '123qweas';
puser=# CREATE DATABASE test_db
puser=# CREATE TABLE orders (
        id SERIAL PRIMARY KEY,
        наименование VARCHAR,
        цена INTEGER
        );
puser=# CREATE TABLE clients (
        id SERIAL PRIMARY KEY,
        фамилия VARCHAR,
        "страна проживания" VARCHAR,
        заказ INTEGER,
        FOREIGN KEY(заказ) REFERENCES orders(id)
        );
puser=# CREATE INDEX ON clients("страна проживания");
puser=# GRANT ALL ON TABLE orders, clients TO "test-admin-user";
puser=# CREATE USER "test-simple-user" WITH PASSWORD '123qweas';
puser=# GRANT SELECT, INSERT, UPDATE, DELETE ON orders, clients TO "test-simple-user";

puser=# \l+
                                                               List of databases
   Name    | Owner | Encoding |  Collate   |   Ctype    | Access privileges |  Size   | Tablespace |                Description                 
-----------+-------+----------+------------+------------+-------------------+---------+------------+--------------------------------------------
 postgres  | puser | UTF8     | en_US.utf8 | en_US.utf8 |                   | 7977 kB | pg_default | default administrative connection database
 puser     | puser | UTF8     | en_US.utf8 | en_US.utf8 |                   | 8129 kB | pg_default | 
 template0 | puser | UTF8     | en_US.utf8 | en_US.utf8 | =c/puser         +| 7833 kB | pg_default | unmodifiable empty database
           |       |          |            |            | puser=CTc/puser   |         |            | 
 template1 | puser | UTF8     | en_US.utf8 | en_US.utf8 | =c/puser         +| 7833 kB | pg_default | default template for new databases
           |       |          |            |            | puser=CTc/puser   |         |            | 
 test_db   | puser | UTF8     | en_US.utf8 | en_US.utf8 |                   | 7833 kB | pg_default | 
(5 rows)

puser=# \d+ clients
                                                           Table "public.clients"
      Column       |       Type        | Collation | Nullable |               Default               | Storage  | Stats target | Description 
-------------------+-------------------+-----------+----------+-------------------------------------+----------+--------------+-------------
 id                | integer           |           | not null | nextval('clients_id_seq'::regclass) | plain    |              | 
 фамилия           | character varying |           |          |                                     | extended |              | 
 страна проживания | character varying |           |          |                                     | extended |              | 
 заказ             | integer           |           |          |                                     | plain    |              | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "clients_страна проживания_idx" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap

puser=# \d+ orders
                                                        Table "public.orders"
    Column    |       Type        | Collation | Nullable |              Default               | Storage  | Stats target | Description 
--------------+-------------------+-----------+----------+------------------------------------+----------+--------------+-------------
 id           | integer           |           | not null | nextval('orders_id_seq'::regclass) | plain    |              | 
 наименование | character varying |           |          |                                    | extended |              | 
 цена         | integer           |           |          |                                    | plain    |              | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
Access method: heap

puser=# SELECT 
    grantee, table_name, privilege_type 
FROM 
    information_schema.table_privileges 
WHERE 
    grantee in ('test-admin-user','test-simple-user') and table_name in ('orders','clients')
order by grantee, table_name;
     grantee      | table_name | privilege_type 
------------------+------------+----------------
 test-admin-user  | clients    | TRIGGER
 test-admin-user  | clients    | REFERENCES
 test-admin-user  | clients    | TRUNCATE
 test-admin-user  | clients    | DELETE
 test-admin-user  | clients    | INSERT
 test-admin-user  | clients    | SELECT
 test-admin-user  | clients    | UPDATE
 test-admin-user  | orders     | INSERT
 test-admin-user  | orders     | SELECT
 test-admin-user  | orders     | UPDATE
 test-admin-user  | orders     | DELETE
 test-admin-user  | orders     | TRUNCATE
 test-admin-user  | orders     | REFERENCES
 test-admin-user  | orders     | TRIGGER
 test-simple-user | clients    | DELETE
 test-simple-user | clients    | INSERT
 test-simple-user | clients    | SELECT
 test-simple-user | clients    | UPDATE
 test-simple-user | orders     | DELETE
 test-simple-user | orders     | UPDATE
 test-simple-user | orders     | SELECT
 test-simple-user | orders     | INSERT
(22 rows)



## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|


Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

```text
puser=# INSERT INTO orders VALUES (1, 'Шоколад', 10), (2, 'Принтер', 3000), (3, 'Книга', 500), (4, 'Монитор', 7000), (5, 'Гитара', 4000);
INSERT 0 5
puser=# INSERT INTO clients VALUES (1, 'Иванов Иван Иванович', 'USA'), (2, 'Петров Петр Петрович', 'Canada'), (3, 'Иоганн Себастьян Бах', 'Japan'), (4, 'Ронни Джеймс Дио', 'Russia'), (5, 'Ritchie Blackmore', 'Russia');
INSERT 0 5

puser=# SELECT count(id) FROM clients;
 count 
-------
     5
(1 row)

puser=# SELECT count(id) FROM orders;
 count 
-------
     5
(1 row)

```

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

puser=# UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование"='Книга') WHERE "фамилия"='Иванов Иван Иванович';
puser=# UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование"='Монитор') WHERE "фамилия"='Петров Петр Петрович';
puser=# UPDATE clients SET "заказ" = (SELECT id FROM orders WHERE "наименование"='Гитара') WHERE "фамилия"='Иоганн Себастьян Бах';

puser=# SELECT c.* FROM clients c JOIN orders o ON c.заказ = o.id;

## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 
