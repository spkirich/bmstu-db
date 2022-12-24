from peewee import PostgresqlDatabase, Model
from peewee import PrimaryKeyField, ForeignKeyField, CharField, IntegerField

import random

db = PostgresqlDatabase(host="localhost", port="5432", database="musicians",
    user="postgres", password="qwerty314")

class BaseModel(Model):
    class Meta:
        database = db

class Musician(BaseModel):
    id = PrimaryKeyField(column_name="musician_id")
    name = CharField(column_name="musician_name")

    born = IntegerField(column_name="musician_born")
    died = IntegerField(column_name="musician_died")

    class Meta:
        table_name = "musicians"

class Instrument(BaseModel):
    id = PrimaryKeyField(column_name="id")
    kind = CharField(column_name="kind")
    manufacturer = CharField(column_name="manufacturer")
    model = CharField(column_name="model")

    class Meta:
        table_name = "instruments"

class MusicianInstrument(BaseModel):
    id = PrimaryKeyField(column_name="id")

    musician = ForeignKeyField(Musician,
        column_name="musician")

    instrument = ForeignKeyField(Instrument,
        column_name="instrument")

    class Meta:
        table_name = "musician_instrument"

print("\nЗапрос № 1:\n")

result = Musician.select(Musician.name, Musician.born
    ).where(Musician.born == 1966)

for row in result.namedtuples():
    print(row)

print("\nЗапрос № 2:\n")

result = Musician.select(Musician.name, Instrument.manufacturer
    ).join(MusicianInstrument, on=(Musician.id == MusicianInstrument.musician)
    ).join(Instrument, on=(Instrument.id == MusicianInstrument.instrument))

for row in result.namedtuples():
    print(row)

print("\nЗапрос № 3:\n")

names = ("Bjorn", "Olav", "Emil", "Aksel")
newid = []

for i in range(3):
    try:
        id = random.randint(10000, 20000)

        name = random.choice(names) + " " + random.choice(names) + "son"
        born = random.randint(1950, 2000)

        Musician.create(id=id, name=name, born=born)

    except Exception as exception:
        print(exception)

    else:
        newid.append(id)

for id in newid:
    try:
        musician = Musician.get(id=id)
        musician.died = 2022
        musician.save()

        print(f"{musician.name}\t{musician.born}-{musician.died}")

    except Exception as exception:
        print(exception)

for id in newid:
    try:
        musician = Musician.get(id=id)
        musician.delete_instance()

    except Exception as exception:
        print(exception)

print("\nЗапрос № 4:\n")

cursor = db.cursor()
cursor.execute("call insert_data_in_release(424242, 'AAAGH!!!', 2022, 'album')")
cursor.execute("delete from release where id = 424242")
