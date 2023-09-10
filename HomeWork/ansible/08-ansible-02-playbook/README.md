# Домашнее задание к занятию 2 «Работа с Playbook»

## Подготовка к выполнению

1. * Необязательно. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).
2. Создайте свой публичный репозиторий на GitHub с произвольным именем или используйте старый.
3. Скачайте [Playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.
4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.

## Основная часть

1. Подготовьте свой inventory-файл `prod.yml`.
2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2.
3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.  
```bash 
WARNING  Listing 8 violation(s) that are fatal
name[missing]: All tasks should be named.
site.yml:11 Task/Handler: block/always/rescue 

risky-file-permissions: File permissions unset or incorrect.
site.yml:12 Task/Handler: Get clickhouse distrib

risky-file-permissions: File permissions unset or incorrect.
site.yml:18 Task/Handler: Get clickhouse distrib

fqcn[action-core]: Use FQCN for builtin module actions (meta).
site.yml:30 Use `ansible.builtin.meta` or `ansible.legacy.meta` instead.

jinja[spacing]: Jinja2 spacing could be improved: create_db.rc != 0 and create_db.rc !=82 -> create_db.rc != 0 and create_db.rc != 82 (warning)
site.yml:32 Jinja2 template rewrite recommendation: `create_db.rc != 0 and create_db.rc != 82`.

risky-file-permissions: File permissions unset or incorrect.
site.yml:41 Task/Handler: Get vector rpm distrib

jinja[spacing]: Jinja2 spacing could be improved: {{vector_rpm_url}} -> {{ vector_rpm_url }} (warning)
site.yml:43 Jinja2 template rewrite recommendation: `{{ vector_rpm_url }}`.

risky-file-permissions: File permissions unset or incorrect.
site.yml:51 Task/Handler: Deploy Vector Config

Read documentation for instructions on how to ignore specific rule violations.

                    Rule Violation Summary                    
 count tag                    profile    rule associated tags 
     2 jinja[spacing]         basic      formatting (warning) 
     1 name[missing]          basic      idiom                
     4 risky-file-permissions safety     unpredictability     
     1 fqcn[action-core]      production formatting           

Failed: 6 failure(s), 2 warning(s) on 1 files. Last profile that met the validation criteria was 'min'.
```
 - Добавил название для block
 - Добавил mode: "664" для get_url и template
 - Исправил meta на ansible.builtin.meta
 - Добавил пробелы в url: "{{vector_rpm_url}}"
 - Добавил пробел в create_db.rc !=82
```bash
Passed: 0 failure(s), 0 warning(s) on 1 files. Last profile that met the validation criteria was 'production'.
```


6. Попробуйте запустить playbook на этом окружении с флагом `--check`.  
 - Попробовал, в режиме проверки не вносятся изменения на удаленных системах, полезность для данного плэйбука не понятна, т.к. проверить его работу не удастся без внесения изменений, уже на установке не пойдет дальше, т.к. файлы пакетов не скачаны.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.  
 - Выводит информацию об изменениях, здесь вывело информации о изменении в конфиге вектора, относительно того который был после установки и задеплоенного ансиблом из шаблона.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
```bash
clickhouse-01              : ok=8    changed=0    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0   
```
- Плэйбук идемпотентен, т.к. ни какие изменения не выполнялись, потому что удаленный хост уже находится в нужном состоянии.  
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги. Пример качественной документации ansible playbook по [ссылке](https://github.com/opensearch-project/ansible-playbook).  
- [README.md](https://github.com/Alexander-Sharygin/devops-netology/blob/main/HomeWork/ansible/08-ansible-02-playbook/playbook/README.md)
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-02-playbook` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории. 

---
