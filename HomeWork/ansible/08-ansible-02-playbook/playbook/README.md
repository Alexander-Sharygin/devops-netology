## Установка rpm-based Clickhouse и Vector
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

### Настроить

Обратитесь к файлам:  
  `group_vars/clickhouse/vars.yml`, чтобы изменить значения по умолчанию версии ClickHouse.  
  `group_vars/vector/vars.yml`, чтобы изменить значения по умолчанию версии Vector и пути к шаблону конфигурации.  
  `templates/vector-conf.j2`, чтобы изменить шаблон конфигурации
