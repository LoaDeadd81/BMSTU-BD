# Семинар 6
    select *,
        lag(heroic_data) over(patition by ""NickName" order by heroic_dead),
        lead(heroic_data) over(patition by ""NickName" order by heroic_dead)
    from heroes.heroic_dead
Смортрим предыдущих и следующих героев по нику и отсортированы по смерти

## Транзакции хз
    create table kpp(
    id int
    type int,
    dattn time, // по хорошему разделять дату и время
    );

    insert into kpp value(1, 1, '9:00')
    insert into kpp value(1, 2, '10:15')
    insert into kpp value(1, 1, '10:40')
    insert into kpp value(1, 2, '19:00')
    insert into kpp value(2, 1, '9:00')
    insert into kpp value(2, 2, '19:00')

Удобно хранить таким образом для транзакции (не важна продолжительность, только время действия).
Хранит одно поле версионности СКД1. Для точечного события храним 1 время (OLTP) для транзакций.

Где сотрудник был в 10:30

    select case type
        when 1 "на работе"
        when 2 "не на работе" end as type
    from kpp
    where dttm <= 10:30 and id = 1
    order by dttm desc
    limit 1

Ещё пример (товарищей c собесов)

    select type
    from(
        select case type,
            row_date() over (partition by id order by dttm) as rn        
        from kpp
        where dttm <= 10:30 and id = 1
    )
    where tn = 1

3-Й вариант

    select type
    from(
        select case type,
            max(dttm) over (partition by id order by dttm) over() as m        
        from kpp
        where dttm <= 10:30 and id = 1
    )
    where dttm  = m

cost = 37.7 воробушков везде

4 вариант

    select
    from kpp
    where id = 1 and 
        dttm = (selct max(dttm)
                from kpp
                where dttm <= 10:30 and id = 1)

Запрос (карелированный) говно т.к. не праллелится воробьи(37, 69k)

СКД2 версионность по 2 атрибутам (интервальная) (from, to). Если пока нет данных для to обычно не
хранится null(не работает bettwen), обычно использют 5999 год (всему конец к этому времнени) и т.д.
(OLAP) на аналитику (быстрый select, долгий insert(поис и update 2 действия))

Делаем из СКД1 -> СКД2

    selct type
    from
        (slect id, type,
            dttm df
            lead (dttm, 1 -шаг-, '23:59' -тип коалеск вместо null вставит-) over (partition by id order by by dttm desc) - interval '1 second' dt
        from kpp
        where id = 1) dt
    where dttm <= 10:30 between df and dt

33 воробья

Для каждого героя последний подвиг
    
    alter table ... меняют тип столбца
    select *
    from
        (select h."Last Name", h."Name", 
            lead(dttm) over(patition by hd.Nicname order by hd.hheroic_date::date --приведение к типу или через to_date)
        from heroes h join heroic_deed hd on h.Nickname = hd.Nickname
        where hd.heroic_data is not null) t
    where dttm id null

### Вместо dead везде deed
