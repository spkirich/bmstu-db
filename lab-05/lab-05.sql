copy (select row_to_json(b) from bands b)
    to '/json/bands.json';

copy (select row_to_json(e) from events e)
    to '/json/events.json';

copy (select row_to_json(i) from instruments i)
    to '/json/instruments.json';

copy (select row_to_json(r) from release r)
    to '/json/release.json';

copy (select row_to_json(m) from musicians m)
    to '/json/musicians.json';

copy (select row_to_json(mb) from musician_band mb)
    to '/json/musician_band.json';

copy (select row_to_json(me) from musician_event me)
    to '/json/musician_event.json';

copy (select row_to_json(mi) from musician_instrument mi)
    to '/json/musician_instrument.json';

copy (select row_to_json(mr) from musician_release mr)
    to '/json/musician_release.json';

drop table if exists json_musicians;
create table json_musicians(data json);

copy json_musicians(data)
    from '/json/musicians.json';

drop table if exists copy_musicians;

create table copy_musicians (
    musician_id int primary key generated always as identity,
    musician_name varchar(32) not null,
    musician_born int check (
        musician_born is not null and musician_born >= 1900),
    musician_died int check (
        musician_died is null or musician_died > musician_born)
);

insert into copy_musicians(
    musician_name, musician_born, musician_died
)

select data->>'musician_name' as musician_name,
    (data->>'musician_born')::int as musician_born,
    (data->>'musician_died')::int as musician_died
from json_musicians;

/*
alter table musicians
    add column info json;
*/

update musicians
    set info = '{"musician": true, "died": false}'
        where musician_died is null;

update musicians
    set info = '{"musician": true, "died": true}'
        where musician_died is not null;

drop table if exists ttbl;
create table ttbl (data json);

copy ttbl
    from '/json/bands.json';

select * from ttbl
    where data->>'title' like 'Dead%' limit 10;

select data::jsonb ? 'genre'
    from ttbl;

drop table if exists stbl;

create table stbl (
    title text,
    info json
);

insert into stbl(title, info)
values ('The Band', '[{"genre": "Metal"}, {"genre": "Rock"}]');

select title, json_array_elements(info)
    from stbl;
