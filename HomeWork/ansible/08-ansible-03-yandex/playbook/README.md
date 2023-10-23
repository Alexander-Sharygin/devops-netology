## Установка rpm-based Clickhouse и Vector + Lighthouse
Этот ansible playbook поддерживает следующее:
### Clickhouse
- Скачивает rpm пакеты Clickhouse
- Устанавливает через yum скачанные пакеты
- Запускает Clickhouse
- Создает в Clickhouse базу данных для логов
### Vector
- Скачивает rpm пакет Vector
- Устанавливает через yum пакет
- Устанавливает конфигурацию вектора из шаблона
### Lighthouse
- Устанавливает через yun git и nginx
- Настраивает и запускает nginx
- Копирует с git Lighthouse

### Настроить

Обратитесь к файлам:  
  `group_vars/clickhouse/vars.yml`, чтобы изменить значения по умолчанию версии ClickHouse.  
  `group_vars/vector/vars.yml`, чтобы изменить значения по умолчанию версии Vector и пути к шаблону конфигурации.  
  `group_vars/lighthouse/vars.yml`, чтобы изменить значения по умолчанию версии Vector и пути к шаблону конфигурации.  
      `document_root`   : "/var/www"  
      `app_root`        : "lighthouse"  
      `lighthouse_vcs`  : "https://github.com/VKCOM/lighthouse/"  
server_name: "{{ ansible_default_ipv4.address }}"


  `templates/vector-conf.j2`, чтобы изменить шаблон конфигурации vector
  `templates/nginx.conf.j2`, чтобы изменить шаблон конфигурации nginx
