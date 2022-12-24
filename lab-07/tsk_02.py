import json
import psycopg2

class Driver:
    path = "musicians.json"

    def __init__(self, host, port, database, user, password):
        query = "select row_to_json(m) from musicians m"

        connection = psycopg2.connect(host=host, port=port, database=database,
            user=user, password=password)

        musicians = []

        with connection.cursor() as cursor:
            cursor.execute(query)

            for row in cursor.fetchall():
                musicians.append(row[0])

        self.musicians = musicians

    @property
    def musicians(self):
        with open(self.path, "r") as file:
            musicians = json.load(file)

        return musicians

    @musicians.setter
    def musicians(self, musicians):
        with open(self.path, "w") as file:
            json.dump(musicians, file)

    def read(self):
        for musician in self.musicians[:10]:
            print(musician)

    def update(self, name):
        musicians = self.musicians

        for musician in musicians:
            if musician["musician_name"].startswith(name):
                musician["info"] = None

        self.musicians = musicians

    def write(self, name, born):
        musicians = self.musicians

        musicians.append({
            "musician_name": name,
            "musician_born": born,
        })

        self.musicians = musicians

if __name__ == "__main__":
    driver = Driver("localhost", "5432", "musicians", "postgres", "qwerty314")

    # 1. Чтение.
    driver.read()

    # 2. Обновление.
    driver.update("Marko")

    # 3. Запись.
    driver.write("John Doe", 1988)
