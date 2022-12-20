import psycopg

connection = psycopg.connect(host="127.0.0.1", port="5432", dbname="musicians",
                             user="postgres", password="qwerty314")

connection.autocommit = True
cursor = connection.cursor()

def action_01():
    global cursor

    query = """
select current_date;
"""

    print(f"\nЗапрос:{query}\nОтвет:")
    cursor.execute(query)

    for row in cursor.fetchmany(10):
        print(*row)

def action_02():
    global cursor

    query = """
select musician_name, title from
    musicians join (
        musician_band join bands
            on bands.id = musician_band.band
        ) on musicians.musician_id = musician_band.musician;
"""

    print(f"\nЗапрос:{query}\nОтвет:")
    cursor.execute(query)

    for row in cursor.fetchmany(10):
        print(*row)

def action_03():
    global cursor

    query = """
with born_in_20th_century as (
    select *
        from musicians
            where musician_born between 1900 and 2000
)

select musician_born, avg(musician_died) over (
    partition by musician_id, musician_born
) from born_in_20th_century;
"""

    print(f"\nЗапрос:{query}\nОтвет:")
    cursor.execute(query)

    for row in cursor.fetchmany(10):
        print(*row)

def action_04():
    global cursor

    query = """
select table_name
    from information_schema.tables;
"""

    print(f"\nЗапрос:{query}\nОтвет:")
    cursor.execute(query)

    for row in cursor.fetchmany(10):
        print(*row)

def action_05():
    global cursor

    query = """
select musician_name, Musicians_Age(musician_born, musician_died)
    from musicians;
"""

    print(f"\nЗапрос:{query}\nОтвет:")
    cursor.execute(query)

    for row in cursor.fetchmany(10):
        print(*row)

def action_06():
    global cursor

    query = """
select *
    from Musician_name_and_age();
"""

    print(f"\nЗапрос:{query}\nОтвет:")
    cursor.execute(query)

    for row in cursor.fetchmany(10):
        print(*row)

def action_07():
    global cursor

    query = """
call insert_data_in_release(4142, 'Bloody Garden', 1999, 'album');
"""

    print(f"\nЗапрос:{query}", end="")
    cursor.execute(query)

    query = """
select title, kind
    from release
        where id = 4142;
"""

    print(f"\nЗапрос:{query}\nОтвет:")
    cursor.execute(query)

    for row in cursor.fetchmany(10):
        print(*row)

    query = """
delete
    from release
        where id = 4142;
"""

    print(f"\nЗапрос:{query}", end="")
    cursor.execute(query)

def action_08():
    global cursor

    query = """
select current_database();
"""

    print(f"\nЗапрос:{query}\nОтвет:")
    cursor.execute(query)

    for row in cursor.fetchmany(10):
        print(*row)

def action_09():
    global cursor

    query = """
drop table if exists club_twenty_seven;
"""

    print(f"\nЗапрос:{query}")
    cursor.execute(query)

    query = """
create table club_twenty_seven (
    club_memb_cmid int primary key generated always as identity,
    club_memb_name text
);
"""

    print(f"\nЗапрос:{query}")
    cursor.execute(query)

def action_10():
    global cursor

    query = """
insert into club_twenty_seven(club_memb_name) (
    select musician_name as club_memb_name
        from musician_name_and_age()
            where musician_age = 27
);
"""

    print(f"\nЗапрос:{query}")
    cursor.execute(query)

menu = {
     1: (action_01, "Выполнить скалярный запрос"),
     2: (action_02, "Выполнить запрос с несколькими соединениями"),
     3: (action_03, "Выполнить запрос с ОТВ и оконными функциями"),
     4: (action_04, "Выполнить запрос к метаданным"),
     5: (action_05, "Вызвать скалярную функцию"),
     6: (action_06, "Вызвать многооператорную или табличную функцию"),
     7: (action_07, "Вызвать хранимую процедуру"),
     8: (action_08, "Вызвать системную функцию или процедуру"),
     9: (action_09, "Создать таблицу в базе данных"),
    10: (action_10, "Выполнить вставку данных в созданную таблицу"),
}

mainloop = True

while mainloop:
    print()

    for option, (action, description) in menu.items():
        print(f"{option:>2}. {description}")

    userloop = True

    while userloop:
        userloop = False

        try:
            option = int(input("\nВведите номер выбранного действия: "))

            if option not in menu.keys():
                raise ValueError

        except ValueError:
            userloop = True

        except KeyboardInterrupt:
            print("\n\nBye!\n")
            mainloop = False

        else:
            action, description = menu[option]
            action()
