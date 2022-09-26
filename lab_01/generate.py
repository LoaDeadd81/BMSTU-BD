import csv
import random
from faker import Faker
import faker.providers.company
import faker.providers.address
import faker.providers.date_time
from faker_vehicle import VehicleProvider
from mimesis import Datetime, Person

REC_NUM = 1001

fake = Faker()
vfake = Faker()
vfake.add_provider(VehicleProvider)

person = Person()
datetime = Datetime()
adrf = faker.providers.address.Provider(fake)
compf = faker.providers.company.Provider(fake)
dtf = faker.providers.date_time.Provider(fake)


def engines():
    with open('./csv/engines.csv', 'w', newline='') as csvfile:
        ow_writer = csv.writer(csvfile, delimiter=';')
        for i in range(REC_NUM):
            hp = random.randint(10, 200)
            torque = random.randint(20, 160)
            volume = random.randint(50, 1200)
            cylinder_num = random.randint(2, 4)
            cycle_num = random.choice([2, 4])
            fuel = random.choice([80, 92, 95, 98])
            fact_id = random.randint(1, REC_NUM)
            ow_writer.writerow([hp] + [torque] + [volume] + [cylinder_num] + [cycle_num] + [fuel] + [fact_id])


def get_vin():
    res = ""
    for i in range(17):
        res += str(random.randint(0, 9))
    return res


def model():
    with open('./csv/model.csv', 'w', newline='') as csvfile:
        ow_writer = csv.writer(csvfile, delimiter=';')
        vin_set = set()
        for i in range(REC_NUM):
            id = i
            name = vfake.vehicle_model()

            vin = get_vin()
            while vin in vin_set:
                vin = get_vin()
            vin_set.add(vin)

            cost = random.randint(10000, 250000)
            max_speed = random.randint(180, 290)
            acceleration = random.uniform(1, 5)
            start_year = random.randint(2000, 2018)
            gears_num = random.randint(4, 7)
            eng_id = random.randint(1, REC_NUM)
            brand_id = random.randint(1, REC_NUM)

            ow_writer.writerow(
                [name] + [vin] + [cost] + [max_speed] + [acceleration] + [start_year] + [
                    gears_num] + [eng_id] + [brand_id])


def brands():
    with open('./csv/brands.csv', 'w', newline='') as csvfile:
        ow_writer = csv.writer(csvfile, delimiter=';')
        set_name = set()
        for i in range(REC_NUM):
            id = i

            name = compf.bs()
            while name in set_name:
                name = compf.bs()
            set_name.add(name)

            country = adrf.country(max_length=10)
            founder = person.full_name()
            foundation_year = random.randint(1950, 2000)
            renue = random.randint(100, 1500)
            ow_writer.writerow([name] + [country] + [founder] + [foundation_year] + [renue])


def dealer():
    with open('./csv/dealers.csv', 'w', newline='') as csvfile:
        ow_writer = csv.writer(csvfile, delimiter=';')
        set_name = set()
        for i in range(REC_NUM):
            id = i

            name = compf.bs()
            while name in set_name:
                name = compf.bs()
            set_name.add(name)

            country = adrf.country(max_length=10)
            sales_num_year = random.randint(500, 1500)
            sellers_nums = random.randint(15, 30)
            extra_charge = random.randint(5, 20)
            ow_writer.writerow([name] + [country] + [sales_num_year] + [sellers_nums] + [extra_charge])


def factory():
    with open('./csv/factories.csv', 'w', newline='') as csvfile:
        ow_writer = csv.writer(csvfile, delimiter=';')
        set_name = set()
        for i in range(REC_NUM):
            id = i

            name = compf.bs()
            while name in set_name:
                name = compf.bs()
            set_name.add(name)

            country = adrf.country(max_length=10)
            models_per_year = random.randint(5000, 20000)
            worker_nums = random.randint(15, 30)
            brand_id = random.randint(1, REC_NUM)

            ow_writer.writerow([name] + [country] + [models_per_year] + [worker_nums] + [brand_id])


def contracts():
    with open('./csv/contracts.csv', 'w', newline='') as csvfile:
        ow_writer = csv.writer(csvfile, delimiter=';')
        for i in range(REC_NUM):
            id = i
            brand_id = random.randint(1, REC_NUM)
            dealer_id = random.randint(1, REC_NUM)
            num_moto = random.randint(500, 1500)
            duration = random.randint(1, 5)
            cost = random.randint(1, 120)
            date = datetime.date(start=2018, end=2021)
            ow_writer.writerow(
                [brand_id] + [dealer_id] + [num_moto] + [duration] + [cost] + [date.strftime("%d/%m/%Y")])


def main():
    dealer()
    brands()
    engines()
    model()
    factory()
    contracts()


main()
