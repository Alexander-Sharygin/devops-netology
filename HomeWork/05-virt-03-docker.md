--

## Задача 1

Сценарий выполнения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберите любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```

Опубликуйте созданный fork в своём репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.  

 ```
sudo docker login --username 9122288454
docker pull nginx

Dockerfile 
  FROM nginx
  COPY html /usr/share/nginx/html
  
docker build -t 9122288454/netology-nginx 
docker push 9122288454/netology-nginx

docker run -d -p 8080:80 9122288454/netology-nginx
```
https://hub.docker.com/repository/docker/9122288454/netology-nginx/general

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
«Подходит ли в этом сценарии использование Docker-контейнеров или лучше подойдёт виртуальная машина, физическая машина? Может быть, возможны разные варианты?»

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- высоконагруженное монолитное Java веб-приложение;  
**Не разбивается на сервисы, и высоконагруженное, поэтому ВМ или физический сервер в случае, если приложение способно нагрузить его полностью**
- Nodejs веб-приложение;  
**Docker, позволит упаковать приложение и все вместе с необходимым ему окружением в контейнер. Есть image на докерхаб.**
- мобильное приложение c версиями для Android и iOS;
**Нужен gui, поэтому VM 
- шина данных на базе Apache Kafka;
**Можно в докере, наверное лучше в VM т.к. данные нужно хранить.**
- Elasticsearch-кластер для реализации логирования продуктивного веб-приложения — три ноды elasticsearch, два logstash и две ноды kibana;  
**Elasticsearch в VM, т.к. храним данные, отказоустойчивость решается кластером, logstash и kibana в docker**
- мониторинг-стек на базе Prometheus и Grafana;  
**Подойдет docker**
- MongoDB как основное хранилище данных для Java-приложения;  
**Базу данных лучше в VM или физический сервер**
- Gitlab-сервер для реализации CI/CD-процессор и приватный (закрытый) Docker Registry.
**Можно docker или vm**

## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тегом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера.
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера.
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```.
- Добавьте ещё один файл в папку ```/data``` на хостовой машине.
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.  
```bash
root@ThinkBook-14-G2-ARE:~# docker run -it -d -v $(pwd)/data/:/data centos  
root@ThinkBook-14-G2-ARE:~# docker run -it -d -v $(pwd)/data/:/data debian  

root@ThinkBook-14-G2-ARE:~# docker ps

CONTAINER ID   IMAGE                       COMMAND                  CREATED         STATUS         PORTS                                   NAMES
1181b5a81e35   debian                      "bash"                   9 minutes ago   Up 9 minutes                                           xenodochial_pascal
bad403ed6caa   centos                      "/bin/bash"              9 minutes ago   Up 9 minutes                                           serene_kilby

root@ThinkBook-14-G2-ARE:~# docker exec serene_kilby sh -c "echo centos>>/data/file.txt"
root@ThinkBook-14-G2-ARE:~# echo host>~/data/file2.txt
root@ThinkBook-14-G2-ARE:~# docker exec serene_kilby sh -c "ls -lha /data&&cat /data/*.txt"

total 16K
drwxr-xr-x 2 root root 4.0K May 25 19:50 .
drwxr-xr-x 1 root root 4.0K May 25 19:34 ..
-rw-r--r-- 1 root root    7 May 25 19:47 file.txt
-rw-r--r-- 1 root root    5 May 25 19:49 file2.txt
centos
host
```
