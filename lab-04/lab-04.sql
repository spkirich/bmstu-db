create or replace function py_age(born int, died int)
returns int as
$$
return 2022 - born if died is None else died - born
$$
language plpython3u;

create or replace function py_avg_died(born int)
returns int as
$$
request = """
select musician_died
from musicians
where musician_born = $1
and musician_died is not null
"""

response = plpy.execute(plpy.prepare(request, ["int"]), [born])

if response is not None:
    n = 0
    d = 0

    for row in response:
        n += row["musician_died"]
        d += 1

    return int(n / d)

else:
    return 0
$$
language plpython3u;

create or replace function py_name_age()
returns table (name text, age int) as
$$
request = """
select musician_name, musician_born
from musicians
"""

response = plpy.execute(plpy.prepare(request, []), [])

if response is not None:
    table = []

    for row in response:
        table.append((row["musician_name"], 2022 - row["musician_born"]))

    return table

else:
    return []
$$
language plpython3u;

create or replace procedure py_kill_old_musicians(born int)
as
$$
request = """
update musicians
set musician_died = 2022
where musician_born < $1
"""

plpy.execute(plpy.prepare(request, ["int"]), [born])
$$
language plpython3u;

create or replace function py_musician_update_handler()
returns trigger as
$$
plpy.notice(f"Old: {TD['old']}")
plpy.notice(f"New: {TD['new']}")
$$
language plpython3u;

create or replace trigger py_musician_update_trigger
after update on musicians
for each row
execute procedure py_musician_update_handler();

drop type if exists performer cascade;

create type performer as
(
    name text,
    kind text
);

create or replace function py_performers()
returns setof performer as
$$
request = """
select musician_name as name, kind
from musicians m join
(
    musician_instrument mi join instruments i
        on i.id = mi.instrument
)
on m.musician_id = mi.musician
"""

return plpy.execute(plpy.prepare(request, []), [])
$$
language plpython3u;
