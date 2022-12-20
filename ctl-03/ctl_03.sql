drop table if exists empl cascade;

create table empl (
    empl_eid int primary key generated always as identity,

    empl_nam text not null,
    empl_bor date not null,
    empl_dep text not null
);

insert into empl(empl_nam, empl_bor, empl_dep)
    values ('Иванов Иван Иванович', '1990-09-25', 'ИТ');

insert into empl(empl_nam, empl_bor, empl_dep)
    values ('Петров Пётр Петрович', '1987-11-12', 'Бухгалтерия');

insert into empl(empl_nam, empl_bor, empl_dep)
    values ('Сидоров Сидор Сидорович', '1987-11-12', 'Бухгалтерия');

drop table if exists tabl cascade;

create table tabl (
    tabl_tid int primary key generated always as identity,
    tabl_eid int,

    tabl_dat date not null,
    tabl_day text not null,
    tabl_tim time not null,
    tabl_typ int  not null,

    constraint fk_tabl_eid foreign key(tabl_eid) references empl(empl_eid)
);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:00', 1);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:20', 2);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:25', 1);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:30', 2);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:35', 1);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:40', 2);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:45', 1);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:50', 2);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (1, '2018-12-14', 'Суббота', '9:55', 1);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (2, '2018-12-14', 'Суббота', '9:05', 1);

insert into tabl(tabl_eid, tabl_dat, tabl_day, tabl_tim, tabl_typ)
    values (3, '2018-12-14', 'Суббота', '8:05', 1);

create or replace function young_nervous_employee_count()
    returns int
    language plpgsql
    as
$$
declare
    the_count int;
begin
    select count(*) into the_count from empl
    where (date_part('year', age(current_date, empl_bor)) between 18 and 40)
        and (
            select count(*) from tabl
            where (tabl_eid = empl_eid)
                and (tabl_typ = 2)
        ) > 3;

    return the_count;
end;
$$
