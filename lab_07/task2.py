import psycopg2
from psycopg2 import Error
import json
from py_linq import *
from objs import *


def connect():
    try:
        connection = psycopg2.connect(user="loadeadd",
                                      password="pass_sql",
                                      host="127.0.0.1",
                                      port="5432",
                                      database="lab")
        return connection
    except (Exception, Error) as error:
        print("Ошибка при работе с PostgreSQL", error)


def print_json(dealers):
    for it in dealers:
        print(json.dumps(getEnumerate(it)))


def read_json():
    connection = connect()
    if not connection:
        return
    cursor = connection.cursor()

    query = "create temp table if not exists dc_import( data json); \
                copy dc_import from '/docker-entrypoint-initdb.d/lab_05/dealer.json'; \
                select * from dc_import;"
    cursor.execute(query)
    json_data = cursor.fetchall()

    cursor.close()
    connection.close()

    dealers = list()
    for elem in json_data:
        dealers.append(Dealer(*list(elem[0].values())))

    return dealers


def update_json(dealers, did):
    for it in dealers:
        if it.did == did:
            it.extracharge /= 2


def add_to_json(dealers):
    did = len(dealers) + 1
    name = input("Имя: ")
    country = input("Страна: ")
    salesperyear = int(input("Продажи в год: "))
    sellersnumber = int(input("Кол-во продавцов: "))
    extracharge = int(input("Наценка: "))

    dealers.append(Dealer(did, name, country, salesperyear, sellersnumber, extracharge))


def task_2():
    print("1.Чтение из XML/JSON документа:")
    dealers = read_json()
    print_json(dealers)

    print("2.Обновление XML/JSON документа:")
    did = int(input("Id диллера со скидками: "))
    update_json(dealers, did)
    print_json(dealers)

    print("3.Запись (Добавление) в XML/JSON документ:")
    add_to_json(dealers)
    print_json(dealers)


if __name__ == '__main__':
    task_2()
