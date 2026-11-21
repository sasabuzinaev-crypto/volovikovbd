# Перенос Front в PostgreSQL OLAP

Скрипты находятся в этой папке:

- `olap_ddl.sql` — схема `olap`, факты, измерения и staging-таблицы.
- `front_resources_mssql.sql` — четыре выборки из MSSQL: закупки, продажи, персонал и недельные складские движения.
- `olap_time.sql` — заполнение календаря месяцами из staging-данных.
- `olap_load.sql` — перенос строк из staging в факты и измерения.

## Порядок запуска

1. Создать пустую базу PostgreSQL, например `front_olap`, и выполнить в ней `olap_ddl.sql`.
2. В MSSQL выполнить каждый SELECT из `front_resources_mssql.sql` и сохранить четыре результата в CSV.
3. Импортировать результаты в PostgreSQL в таблицы `olap.stg_purchase`, `olap.stg_sales`, `olap.stg_staff_work` и `olap.stg_inventory`. Порядок колонок указан в запросах и совпадает с таблицами staging.
4. Выполнить `olap_time.sql`, затем `olap_load.sql`.

`olap_load.sql` можно выполнять повторно: строки фактов обновляются по ключам. Представления `olap.v_purchase_abc` и `olap.v_sales_abc` показывают ABC-группы товаров в разрезе месяца: A — примерно первые 80% суммы, B — следующие 15%, C — остаток.

Для квартальных и полугодовых показателей персонала суммируйте месячные строки `olap.fact_staff_work`, группируя по `olap.dim_month.quarter_number` и `year`.
