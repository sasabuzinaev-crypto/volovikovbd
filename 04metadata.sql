-- Таблицы и счетчики новой базы. Выполнять после 03transactions.sql.
select
    row_number() over (order by objects.kind, objects.name) as "№",
    objects.name as "Наименование",
    objects.kind as "Тип"
from (
    select table_name as name, 'Таблица' as kind
    from information_schema.tables
    where table_catalog = 'volovikov_transactions_db'
      and table_schema = 'public'
      and table_type = 'BASE TABLE'
    union all
    select sequence_name as name, 'Последовательность' as kind
    from information_schema.sequences
    where sequence_catalog = 'volovikov_transactions_db'
      and sequence_schema = 'public'
) objects
order by objects.kind, objects.name;
