# Домашнее задание к занятию 3 «Использование Ansible»

## Подготовка к выполнению

1. Подготовьте в Yandex Cloud три хоста: для `clickhouse`, для `vector` и для `lighthouse`.  
**Запущено с помощью терраформ 3 ВМ**  
ans-03-01.png
![ans-03-01.png](https://github.com/Alexander-Sharygin/devops-netology/blob/main/HomeWork/img/ans-03-01.png)
2. Репозиторий LightHouse находится [по ссылке](https://github.com/VKCOM/lighthouse).

## Основная часть

1. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает LightHouse.
2. При создании tasks рекомендую использовать модули: `get_url`, `template`, `yum`, `apt`.
3. Tasks должны: скачать статику LightHouse, установить Nginx или любой другой веб-сервер, настроить его конфиг для открытия LightHouse, запустить веб-сервер.
4. Подготовьте свой inventory-файл `prod.yml`.
5. Запустите `ansible-lint site.yml` и исправьте ошибки, если они есть.
6. Попробуйте запустить playbook на этом окружении с флагом `--check`.
7. Запустите playbook на `prod.yml` окружении с флагом `--diff`. Убедитесь, что изменения на системе произведены.
8. Повторно запустите playbook с флагом `--diff` и убедитесь, что playbook идемпотентен.
9. Подготовьте README.md-файл по своему playbook. В нём должно быть описано: что делает playbook, какие у него есть параметры и теги.
10. Готовый playbook выложите в свой репозиторий, поставьте тег `08-ansible-03-yandex` на фиксирующий коммит, в ответ предоставьте ссылку на него.

---

1-3. 
```yaml
- name: Install lighthouse
  hosts: lighthouse
  handlers:
    - name: start-nginx
      become: true
      command: nginx
    - name: reload-nginx
      become: true
      command: nginx -s reload
  pre_tasks:
    - name: Lighthouse | Install git
      become: true
      ansible.builtin.yum:
        name: git
        state: present
    - name: Lighthouse | Install epel
      become: true
      ansible.builtin.yum:
        name: epel-release
        state: present
    - name: Lighthouse | Install nginx
      become: true
      ansible.builtin.yum:
        name: nginx
        state: present
      notify: start-nginx
    - name: Lighthouse | Create nginx config
      become: true
      template:
        src: nginx.conf.j2
        dest: /etc/nginx/conf.d/default.conf
      notify: reload-nginx
  tasks:
    - name: Lighthouse | Copy form git
      become: true
      git:
        repo: "{{ lighthouse_vcs }}"
        version: master
        dest: "{{ document_root }}/{{ app_root }}"
```
4. inventory-файл `prod.yml`  
```yaml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_host: 158.160.123.78
      ansible_user: centos

vector:
  hosts:
    clickhouse-01:
      ansible_host: 158.160.124.6
      ansible_user: centos

lighthouse:
  hosts:
    lighthouse-01:
      ansible_host: 158.160.106.140
      ansible_user: centos
```
5. Запущено ошибки исправлены, всё накатилось.
6-8. Выполнено  
9. [readme.md](https://github.com/Alexander-Sharygin/devops-netology/blob/main/HomeWork/ansible/08-ansible-03-yandex/playbook/README.md)  
10. 
### Как оформить решение задания

Выполненное домашнее задание пришлите в виде ссылки на .md-файл в вашем репозитории.

---
