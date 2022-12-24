from typing import Optional, Union
from typing_extensions import Self

import csv

class Musician:
    def __init__(self, name: str, born: int, died: Optional[int] = None):
        self.name = name
        self.born = born
        self.died = died

    def __repr__(self) -> str:
        return f"Musician{self.dict()}"

    @classmethod
    def load_csv(cls, path: str) -> list[Self]:
        musicians = []

        with open(path) as file:
            reader = csv.reader(file)

            for row in reader:
                name = row[1]

                born = int(row[2])
                died = int(row[3]) if row[3] else None

                musicians.append(cls(name, born, died))

        return musicians

    def dict(self) -> dict[str, Union[str, int, Optional[int]]]:
        return dict(name=self.name, born=self.born, died=self.died)

    def __getitem__(self, item) -> Union[str, int, Optional[int]]:
        return self.dict()[item]

if __name__ == "__main__":
    from py_linq import Enumerable

    musicians = Enumerable(Musician.load_csv("../lab-01/musicians.csv"))

    print("\nЗапрос № 1:\n")

    query = musicians.select(lambda x: x["name"]
        ).take(10)
    
    for name in query:
        print(name)

    print("\nЗапрос № 2:\n")
    query = musicians.where(lambda x: 1960 < x["born"] < 1970
        ).take(10)
    
    for musician in query:
        print(musician)

    print("\nЗапрос № 3:\n")

    query = musicians.group_by(key_names=["born"], key=lambda x: x["born"]
        ).select(lambda x: {"born": x.key.born, "count": x.count()}
        ).take(10)

    for group in query:
        print(group)

    print("\nЗапрос № 4:\n")

    query = musicians.where(lambda x: x["name"].startswith("Marko")
        ).order_by(lambda x: x["born"]
        ).take(10)

    for musician in query:
        print(musician)

    print("\nЗапрос № 5:\n")

    query = musicians.group_by(key_names=["born"], key=lambda x: x["born"]
        ).where(lambda x: x.any(lambda x: x["name"].endswith("Pollonen"))
        ).select(lambda x: {"born": x.key.born, "count": x.count()}
        ).take(10)

    for group in query:
        print(group)
