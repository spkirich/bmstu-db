drop table if exists meta;

create table meta (
    meta_name text,
    meta_size int
);

create or replace function table_size(table_name text)
    returns int as
$$
declare
    result int;
    query text;
begin
    query := 'select count(*) from ' || table_name;
    execute query into result;

    return result;
end;
$$
language plpgsql;

insert into meta
    select table_name, table_size(table_name) from information_schema.tables
        where table_schema not in ('pg_catalog', 'information_schema');

create or replace function handle_insert()
    returns trigger as
$$
begin
    update meta set meta_size = meta_size + 1;
    return new;
end;
$$
language plpgsql;

create or replace trigger trigger_insert before insert on instruments
    for each statement execute procedure handle_insert();

create or replace function handle_delete()
    returns trigger as
$$
begin
    update meta set meta_size = meta_size - 1;
    return new;
end;
$$
language plpgsql;

create or replace trigger trigger_delete before delete on instruments
    for each statement execute procedure handle_delete();
