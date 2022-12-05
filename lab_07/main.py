from task1 import task_1
from task2 import task_2
from task3 import task_3


def main():
    farr = [task_1, task_2, task_3]

    while 1:
        print("Лаба 7")
        print("1. Задание 1")
        print("2. Задание 2")
        print("3. Задание 3")
        print("0. Выход")

        i = int(input("Выбор: "))

        if i == 0:
            break

        i -= 1
        farr[i]()


if __name__ == '__main__':
    main()
