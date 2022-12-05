from objs import *
from py_linq import *
from tabulate import tabulate


def req_1(brands):
    print("Запрос 1: Бренды основанные после 1990 года")
    return brands.where(lambda x: x['foundationyear'] > 1990).select(lambda x: [x['bid'], x['name'], x['foundationyear']])


def req_2(contracts, brands):
    print("Запрос 2: Кол-во диллеров у бренда")
    return brands.join(contracts, lambda s1: s1["bid"], lambda s2: s2["brand"]).group_by(key_names=['bid'],
                                                                                         key=lambda x: [x[0]]).select(
        lambda x: [x.key.bid['name'], x.count()])


def req_3(dealers):
    print("Запрос 3: Диллеры из Algeria")
    return dealers.where(lambda x: x['country'] == 'Algeria').order_by(lambda x: x['name']).select(
        lambda x: [x['name'], x['country']])


def req_4(contracts):
    print("Запрос 4: Union")
    brand = Enumerable([contracts.min(lambda x: [x['brand'], x['cid'], x['cost']])[1:],
                        contracts.max(lambda x: [x['brand'], x['cid'], x['cost']])[1:]])
    dealer = Enumerable([contracts.min(lambda x: [x['dealer'], x['cid'], x['cost']])[1:],
                         contracts.max(lambda x: [x['dealer'], x['cid'], x['cost']])[1:]])
    return brand.union(dealer, lambda x: x)


def req_5(dealers, contracts):
    print("Запрос 5: Диллеры оптимисты")
    return dealers.join(contracts, lambda s1: s1["did"], lambda s2: s2["dealer"]).where(
        lambda x: x[0]['salesperyear'] < x[1]['modelsperyear']).select(
        lambda x: [x[0]['name'], x[0]['salesperyear'], x[1]['modelsperyear']])


def print_request(req, headers):
    print(tabulate(req, headers))


def task_1():
    print("--------- Задание 1 ---------")

    contracts = Enumerable(createEnumerate(Contract, "contracts.csv"))
    brands = Enumerable(createEnumerate(Brand, "brands.csv"))
    dealers = Enumerable(createEnumerate(Dealer, "dealers.csv"))

    farr = [req_1, req_2, req_3, req_4, req_5]
    harr = [["id", "name"], ["name", "dealersNum"], ["name"], ["id", "cost"], ["name", "salesperyear", "modelsperyear"]]
    argarr = [[brands], [contracts, brands], [dealers], [contracts], [dealers, contracts]]

    while 1:
        print()
        print("1. Бренды основанные после 1990 года")
        print("2. Кол-во диллеров у бренда")
        print("3. Диллеры из Algeria")
        print("4. Union")
        print("5. Диллеры оптимисты")
        print("0. Выход")

        i = int(input("Выбор: "))

        if i == 0:
            break

        i -= 1
        print_request(farr[i](*argarr[i]), harr[i])


if __name__ == '__main__':
    task_1()
