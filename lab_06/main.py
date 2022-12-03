import psycopg2
from psycopg2 import Error
from tabulate import tabulate


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


def task1(cursor):
    print("-- Средний объём двигателей --")

    cursor.execute("select avg(volume) as avgVolumeOnCylinder "
                   "from engines;")
    headers = [desc[0] for desc in cursor.description]
    record = cursor.fetchall()

    return tabulate(record, headers)


def task2(cursor):
    print("-- Список мотор и бредов, выпускабщих их --")

    cursor.execute("select b.name, em.engineid, em.hp, em.volume "
                   "from (engines e join model m on e.engineid = m.engine) em join brand b on em.brand = b.brandid")
    headers = [desc[0] for desc in cursor.description]
    record = cursor.fetchall()

    return tabulate(record, headers)


def task3(cursor):
    print("-- Cведения о диллерах по странам --")

    cursor.execute("select country, minextra, avgextra, maxextra "
                   "from (select country, "
                   " min(extracharge) over (partition by country) as minextra, "
                   "avg(extracharge) over (partition by country) as avgextra, "
                   "max(extracharge) over (partition by country) as maxextra, "
                   "row_number() over (partition by country)     as num "
                   "from dealer) as d "
                   "where num = 1; ")
    headers = [desc[0] for desc in cursor.description]
    record = cursor.fetchall()

    return tabulate(record, headers)


def task4(cursor):
    print("-- Информация о столбах --")

    cursor.execute("select ist.table_catalog   db, "
                   "ist.table_schema as sheme, "
                   "ist.table_name   as tb, "
                   "column_name, "
                   "data_type as type "
                   "from information_schema.tables ist join information_schema.columns isc on ist.table_name = isc.table_name "
                   "where ist.table_schema = 'public' ")
    headers = [desc[0] for desc in cursor.description]
    record = cursor.fetchall()

    return tabulate(record, headers)


def task5(cursor):
    print("-- Список диллера по ID бренда --")

    n = int(input("Введите ID бренда: "))

    cursor.execute("select * "
                   "from get_dealers({}); ".format(n))
    headers = [desc[0] for desc in cursor.description]
    record = cursor.fetchall()

    return tabulate(record, headers)


def task6(cursor):
    print("-- Двигатель по топливу или кол-ву цилиндров --")

    fuel = int(input("Введите топливо (92, 95, 98): "))
    cnum = int(input("Введите кол-во цилиндров: "))

    cursor.execute("select * "
                   "from get_eng({}, {}); ".format(fuel, cnum))
    headers = [desc[0] for desc in cursor.description]
    record = cursor.fetchall()

    return tabulate(record, headers)


# Bahamas
def task7(cursor):
    print("-- Удвоение цен в определённой стране --")

    country = int(input("Введите страну: "))

    cursor.execute("call inflation('{}');".format(country))
    return ""


def task8(cursor):
    print("-- Имя текущей ДБ --")

    cursor.execute("select * "
                   "from current_database(); ")
    headers = [desc[0] for desc in cursor.description]
    record = cursor.fetchall()

    return tabulate(record, headers)


def task9(cursor):
    print("-- Таблица с информацие о выступления брендов в разных гоночных сериях --")

    cursor.execute("create table if not exists Champs "
                   "( "
                   "Brand int references brand (brandid), "
                   "place int, "
                   "racing_series varchar "
                   ");")

    return ""


def task10(cursor):
    print("-- Ввод в таблицу с информацие о выступления брендов в разных гоночных сериях --")

    brand = int(input("Введите ID бренда: "))
    place = int(input("Введите место в чемпионате: "))
    series = input("Введите названии гоночной серии: ")

    cursor.execute("insert into Champs "
                   "values ({}, {}, '{}'); "
                   "SELECT * from Champs".format(brand, place, series))

    headers = [desc[0] for desc in cursor.description]
    record = cursor.fetchall()

    return tabulate(record, headers)


def menu(connection):
    cursor = connection.cursor()

    task_arr = [task1, task2, task3, task4, task5, task6, task7, task8, task9, task10]

    while 1:
        print("1. Выполнить скалярный запрос; \n"
              "2. Выполнить запрос с несколькими соединениями (JOIN);\n"
              "3. Выполнить запрос с ОТВ(CTE) и оконными функциями; \n"
              "4. Выполнить запрос к метаданным; \n"
              "5. Вызвать скалярную функцию (написанную в третьей лабораторной работе); \n"
              "6. Вызвать многооператорную или табличную функцию (написанную в третьей лабораторной работе); \n"
              "7. Вызвать хранимую процедуру (написанную в третьей лабораторной работе); \n"
              "8. Вызвать системную функцию или процедуру; \n"
              "9. Создать таблицу в базе данных, соответствующую тематике БД; \n"
              "10. Выполнить вставку данных в созданную таблицу с использованием инструкции INSERT или COPY. \n"
              "0. Выход  \n")
        n = int(input("Выберите пунк меню: "))

        if n == 0:
            break
        if n < 0 or n > 10:
            print("Нет такого пункта меню \n")
            continue

        try:
            res = task_arr[n - 1](cursor)
        except (Exception, Error) as error:
            connection.rollback()
            print("\nОшибка: ", error, '\n', sep='')
        else:
            connection.commit()
            print("\nРезультат\n", res, '\n', sep='')

    cursor.close()


def main():
    connection = connect()
    if not connection:
        return

    menu(connection)

    connection.close()


if __name__ == '__main__':
    main()
