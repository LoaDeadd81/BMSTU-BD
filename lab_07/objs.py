import inspect


class Dealer:
    did = int()
    name = str()
    country = str()
    salesperyear = int()
    sellersnumber = int()
    extracharge = int()

    def __init__(self, did, name, country, sales, sellers, extra):
        self.did = int(did)
        self.name = str(name)
        self.country = str(country)
        self.salesperyear = int(sales)
        self.sellersnumber = int(sellers)
        self.extracharge = int(extra)


class Brand:
    bid = int()
    name = str()
    country = str()
    founder = str()
    foundationyear = int()
    revenue = int()

    def __init__(self, bid, name, country, founder, foundationyear, revenue):
        self.bid = int(bid)
        self.name = str(name)
        self.country = str(country)
        self.founder = str(founder)
        self.foundationyear = int(foundationyear)
        self.revenue = int(revenue)


class Contract:
    cid = int()
    brand = int()
    dealer = int()
    modelsperyear = int()
    duration = int()
    cost = int()
    startdate = int()

    def __init__(self, cid, brand, dealer, modelsperyear, duration, cost, startdate):
        self.cid = int(cid)
        self.brand = int(brand)
        self.dealer = int(dealer)
        self.modelsperyear = int(modelsperyear)
        self.duration = int(duration)
        self.cost = int(cost)
        self.startdate = str(startdate)


def getEnumerate(obj):
    fields = dict()
    data = inspect.getmembers(obj, lambda a: not (inspect.isroutine(a)))
    return {a[0]: a[1] for a in data if not (a[0].startswith('__') and a[0].endswith('__'))}


def createEnumerate(constructor, csv_filename):
    res = list()
    i = 1

    with open(csv_filename, 'r') as file:
        for line in file:
            arr = line.split(';')
            res.append(getEnumerate(constructor(i, *arr)))
            i += 1

    return res
