## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.
```bash
docker run --name postgressql -d \
    -p 5432:5432 \
    -e POSTGRES_PASSWORD=123QWEas \
    -v pgvol:/var/lib/postgresql/data \            
    postgres:13
```

Подключитесь к БД PostgreSQL используя `psql`.
```bash
psql -h localhost --u postgres --password
```

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql
```bash
\l \l+
\conninfo
\dS 
\dS+
\q
```


## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

```bash
psql -h localhost --u postgres --password 
Password: 
postgres=# CREATE DATABASE test_database ;
postgres=# \q
wget https://raw.githubusercontent.com/netology-code/virt-homeworks/master/06-db-04-postgresql/test_data/test_dump.sql
cat test_dump.sql | psql -h localhost --u postgres --password test_database
psql -h localhost --u postgres --password 
Password:
postgres=# \c test_database    
test_database=# ANALYZE VERBOSE 
test_database=# SELECT max(avg_width) FROM pg_stats WHERE tablename='orders';
 max 
-----
  16
(1 row)
```

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и поиск по ней занимае т долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).
Предложите SQL-транзакцию для проведения данной операции.

```sql
CREATE TABLE orders_1 (CHECK (price > 499)) INHERITS (orders);
CREATE TABLE orders_2 (CHECK (price <= 499)) INHERITS (orders);
INSERT INTO orders_1 SELECT * FROM orders WHERE price > 499;
INSERT INTO orders_2 SELECT * FROM orders WHERE price <= 499;
```
**Может быть, добавить еще тригер и функцию, которая будет распределять значения по orders_1 и orders_2 при вставке. Но вообще в реальных задачах, наверное так не разбивается просто на две таблицы, приложение или что-там у нас работает с этой таблицей orders нужно будет переписывать под orders_1 и 2, какой-то не подходящий вариант.**  

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?
**Применить декларативное секционирование, при создании таблицы**  
```sql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL,
    price integer DEFAULT 0
)PARTITION BY RANGE (price);
CREATE TABLE orders_1 PARTITION OF orders FOR VALUES FROM (0 TO 499)
CREATE TABLE orders_2 PARTITION OF orders FOR VALUES FROM (499) TO (2147483647)
```
**В реальных задачах важен выбор столбца, по которому будет происходить секционирование, по цене вряд-ли имеет смысл. Например здесь, если добавить дату заказа, имеет смысл бить на диапазоны по дате. Что ускорит работу запросов, например в том случае, если основные запросы по заказам текущего периода выполняются.**

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.
```sql
pg_dump "host=localhost port=5432 dbname=test_database user=postgres password=123QWEas" > backup.dump.sql
```

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

Добавить UNIQUE
```sql
CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) NOT NULL UNIQUE,
    price integer DEFAULT 0
);
```

