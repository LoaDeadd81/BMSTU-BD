from models import *
from peewee import *
from models import database
from tabulate import tabulate


def query_1():
    query = Engines.select().where(Engines.hp > 150)
    selected = query.dicts().execute()

    print(tabulate(selected, headers="keys"))


def query_2():
    query = Brand.select(Brand.brandid, Dealer.dealerid, Contract.duration, Contract.cost).join(Contract).join(Dealer)
    selected = query.dicts().execute()

    print(tabulate(selected, headers="keys"))


def add_item(name, country, founder, foundationyear, revenue):
    query = Brand.insert({
        Brand.name: name,
        Brand.country: country,
        Brand.founder: founder,
        Brand.foundationyear: foundationyear,
        Brand.revenue: revenue
    }).execute()


def update_item(name):
    query = Brand.update(revenue=Brand.revenue * 2).where(Brand.name == name).execute()


def del_item(name):
    query = Brand.delete().where(Brand.name == name).execute()


def print_last_5():
    query = Brand.select().limit(5).order_by(Brand.brandid.desc())
    selected = query.dicts().execute()

    print(tabulate(selected, headers="keys"))


def query_3():
    name = 'testPW'
    country = 'AAAA'
    founder = 'BBBB'
    foundationyear = 2020
    revenue = 50

    print("ADD")
    add_item(name, country, founder, foundationyear, revenue)
    print_last_5()

    print("UPDATE")
    update_item(name)
    print_last_5()

    print("DELETE")
    del_item(name)
    print_last_5()


def print_4(country):
    query = ModelM.select(ModelM.name, ModelM.cost, Dealer.country).join(Brand).join(Contract).join(Dealer).where(
        Dealer.country == country)
    selected = query.dicts().execute()
    print(tabulate(selected, headers="keys"))


def query_4():
    country = "Bahamas"
    print("BEFORE")
    print_4(country)

    cursor = database.cursor()
    cursor.execute(f"call inflation('{country}');")
    database.commit()
    cursor.close()

    print("AFTER")
    print_4(country)


def task_3():

    farr = [query_1, query_2, query_3, query_4]
    while 1:
        print()
        print("1. Однотабличный запрос на выборку.")
        print("2. Многотабличный запрос на выборку. ")
        print("3. Три запроса на добавление, изменение и удаление данных в базе данных.")
        print("4. Получение доступа к данным, выполняя только хранимую процедуру")
        print("0. Выход")

        i = int(input("Выбор: "))

        if i == 0:
            break

        i -= 1
        farr[i]()

    database.close()


if __name__ == '__main__':
    task_3()
