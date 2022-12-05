from peewee import *
from playhouse.postgres_ext import *

database = PostgresqlDatabase('lab', **{'host': '127.0.0.1', 'port': 5432, 'user': 'loadeadd', 'password': 'pass_sql'})


class UnknownField(object):
    def __init__(self, *_, **__): pass


class BaseModel(Model):
    class Meta:
        database = database


class Brand(BaseModel):
    brandid = AutoField()
    country = CharField(null=True)
    foundationyear = IntegerField(null=True)
    founder = CharField(null=True)
    name = CharField(null=True)
    revenue = IntegerField(null=True)

    class Meta:
        table_name = 'brand'


class Car(BaseModel):
    data = BinaryJSONField(null=True)

    class Meta:
        table_name = 'car'
        primary_key = False


class Champs(BaseModel):
    brand = ForeignKeyField(column_name='brand', field='brandid', model=Brand, null=True)
    place = IntegerField(null=True)
    racing_series = CharField(null=True)

    class Meta:
        table_name = 'champs'
        primary_key = False


class Dealer(BaseModel):
    country = CharField(null=True)
    dealerid = AutoField()
    extracharge = IntegerField(null=True)
    name = CharField(null=True)
    salesperyear = IntegerField(null=True)
    sellersnumber = IntegerField(null=True)

    class Meta:
        table_name = 'dealer'


class Contract(BaseModel):
    brand = ForeignKeyField(column_name='brand', field='brandid', model=Brand)
    contractid = AutoField()
    cost = IntegerField(null=True)
    dealer = ForeignKeyField(column_name='dealer', field='dealerid', model=Dealer)
    duration = IntegerField(null=True)
    modelsperyear = IntegerField(null=True)
    startdate = DateField(null=True)

    class Meta:
        table_name = 'contract'


class DIdName(BaseModel):
    dealerid = IntegerField(null=True)
    name = CharField(null=True)

    class Meta:
        table_name = 'd_id_name'
        primary_key = False


class Factory(BaseModel):
    brand = ForeignKeyField(column_name='brand', field='brandid', model=Brand)
    country = CharField(null=True)
    factoryid = AutoField()
    modelsperyear = IntegerField(null=True)
    name = CharField(null=True)
    workernumber = IntegerField(null=True)

    class Meta:
        table_name = 'factory'


class Engines(BaseModel):
    cyclesnumber = IntegerField(null=True)
    cylindersnumber = IntegerField(null=True)
    engineid = AutoField()
    factory = ForeignKeyField(column_name='factory', field='factoryid', model=Factory, null=True)
    fuel = IntegerField(null=True)
    hp = IntegerField(null=True)
    torque = IntegerField(null=True)
    volume = IntegerField(null=True)

    class Meta:
        table_name = 'engines'


class ModelM(BaseModel):
    acceleration = DecimalField(null=True)
    brand = ForeignKeyField(column_name='brand', field='brandid', model=Brand)
    cost = IntegerField(null=True)
    engine = ForeignKeyField(column_name='engine', field='engineid', model=Engines)
    gearsnumber = IntegerField(null=True)
    maxspeed = IntegerField(null=True)
    modelid = AutoField()
    name = CharField(null=True)
    releaseyear = IntegerField(null=True)
    vin = CharField(null=True)

    class Meta:
        table_name = 'model'
