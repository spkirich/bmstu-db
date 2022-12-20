import datetime, psycopg2

connection = psycopg2.connect(host="127.0.0.1", port="5432", dbname="rk_03",
                              user="postgres", password="qwerty314")

cursor = connection.cursor()

query_1 = """
select empl_dep, count(empl_eid) from empl
    group by empl_dep having count(empl_eid) > 10;
"""

cursor.execute(query_1)

for row in cursor:
    print(row[0])

def lambda_1():
    cursor.execute("select * from empl")
    empl = list(cursor.fetchall())

    m = {d: 0 for d in set(map(lambda e: e[3], empl))}

    for e in empl:
        m[e[3]] += 1

    return [d for d, c in m.items() if c > 10]

for row in lambda_1():
    print(row)

print()

query_2 = """
select empl_nam from empl
    where not exists (
        select * from tabl
            where (date_part('hour', tabl_tim) between 9 and 18)
                and (tabl_eid = empl_eid)
                and (tabl_typ =        2)
    );
"""

cursor.execute(query_2)

for row in cursor:
    print(row[0])

def lamdba_2():
    cursor.execute("select * from empl")
    empl = list(cursor.fetchall())

    cursor.execute("select * from tabl")
    tabl = list(cursor.fetchall())

    for i, e in enumerate(empl):
        if list(filter(lambda t: 9 <= t[4].hour <= 18 and t[1] == e[0] and t[5] == 2, tabl)):
            del empl[i]

    return empl

for row in lamdba_2():
    print(row[1])

print()

date = datetime.datetime.strptime(input("Введите дату (ГГГГ-ММ-ДД): "),
                                  "%Y-%m-%d")

query_3 = """
select distinct empl_dep from empl as e
    where exists (
        select * from empl
            where (empl_dep = e.empl_dep)
                and not exists (
                    select * from tabl
                        where (tabl_eid = empl_eid)
                            and (date_part('hour', tabl_tim) < 9)
                )
    );
"""

cursor.execute(query_3)

for row in cursor:
    print(row[0])

def lambda_3():
    cursor.execute("select * from empl")
    empl = list(cursor.fetchall())

    cursor.execute("select * from tabl")
    tabl = list(cursor.fetchall())

    m = {d: 0 for d in set(map(lambda e: e[3], empl))}

    for e in empl:
        if not [t for t in tabl if t[1] == e[0] and t[4].hour < 9]:
            m[e[3]] += 1

    return [d for d, c in m.items() if c > 0]

for row in lambda_3():
    print(row)
