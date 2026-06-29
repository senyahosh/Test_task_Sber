create table clients (
  client_id serial primary key, 
  name varchar(100) not null, 
  age integer check (age >= 0), 
  registration_date date not null
);

create table accounts (
	account_id serial primary key,
  client_id integer references clients(client_id) on delete cascade,
  balance decimal(15, 2) not null check (balance >= 0),
  open_date date not null
);

create table transactions (
	transaction_id serial primary key,
  account_id integer references accounts(account_id) on delete cascade,
  amount decimal(15, 2) not null,
  transaction_date date not null,
  transaction_type varchar(50) not null check (transaction_type in ('deposit', 'withdrawal'))
);

insert into clients (name, age, registration_date) values
	('Иван Иванов', 30, '2019-05-15'),
  ('Мария Петрова', 25, '2020-01-10'),
  ('Алексей Сидоров', 40, '2021-03-22'),
  ('Елена Кузнецова', 35, '2020-07-19'),
  ('Дмитрий Смирнов', 28, '2022-11-05'),
  ('Ольга Васнецова', 50, '2018-12-30'),
  ('Сергей Козлов', 33, '2020-06-14'),
  ('Анна Морозова', 29, '2021-09-01'),
  ('Павел Новиков', 45, '2019-08-25'),
  ('Татьяна Павлова', 31, '2020-04-17');

insert into accounts (client_id, balance, open_date) values
	(1, 15000.00, '2019-05-20'),
  (1, 5000.00, '2020-02-10'),
  (2, 20000.00, '2020-01-15'),
  (3, 30000.00, '2021-03-25'),
  (4, 10000.00, '2020-07-25'),
  (5, 25000.00, '2022-11-10'),
  (6, 40000.00, '2019-01-05'),
  (7, 12000.00, '2020-06-20'),
  (8, 18000.00, '2021-09-05'),
  (9, 22000.00, '2019-09-01'),
  (10, 15000.00, '2020-04-20');

insert into transactions (account_id, amount, transaction_date, transaction_type) values
	(1, 1000.00, '2023-01-05', 'deposit'),
  (1, 500.00, '2023-01-10', 'withdrawal'),
  (2, 2000.00, '2023-02-15', 'deposit'),
  (2, 1000.00, '2023-02-20', 'withdrawal'),
  (3, 3000.00, '2023-03-25', 'deposit'),
  (3, 1500.00, '2023-03-30', 'withdrawal'),
  (4, 4000.00, '2023-04-05', 'deposit'),
  (4, 2000.00, '2023-04-10', 'withdrawal'),
  (5, 5000.00, '2023-05-15', 'deposit'),
  (5, 2500.00, '2023-05-20', 'withdrawal'),
  (6, 6000.00, '2023-06-25', 'deposit'),
  (6, 3000.00, '2023-06-30', 'withdrawal'),
  (7, 7000.00, '2023-07-05', 'deposit'),
  (7, 3500.00, '2023-07-10', 'withdrawal'),
  (8, 8000.00, '2023-08-15', 'deposit'),
  (8, 4000.00, '2023-08-20', 'withdrawal'),
  (9, 9000.00, '2023-09-25', 'deposit'),
  (9, 4500.00, '2023-09-30', 'withdrawal'),
  (10, 10000.00, '2023-10-05', 'deposit'),
  (10, 5000.00, '2023-10-10', 'withdrawal');

-- fetch
WITH trans_counts AS (
  SELECT a.client_id, count(CASE WHEN t.transaction_type = 'deposit' THEN 1 END) AS total_deposits, 
  count(CASE WHEN t.transaction_type = 'withdrawal' THEN 1 END) AS total_withdrawals
  FROM transactions t 
  RIGHT JOIN accounts a ON t.account_id=a.account_id
  GROUP BY a.client_id
)
SELECT c.client_id, c.name, c.age, 
count(a.account_id) AS total_accounts, 
sum(a.balance) AS total_balance, 
COALESCE(tc.total_deposits, 0) AS total_deposits, 
COALESCE(tc.total_withdrawals, 0) AS total_withdrawals
FROM accounts a
RIGHT JOIN clients c ON a.client_id=c.client_id
LEFT JOIN trans_counts tc ON tc.client_id=a.client_id
WHERE c.registration_date >= '2020-01-01'
GROUP BY c.client_id, c.name, c.age, tc.total_deposits, tc.total_withdrawals
ORDER BY total_balance desc;

/*
                                            Описание изменений 
                                                 
  Часть 1: вместо отдельных подзапросов для подсчёта количества счетов и общей суммы баланса клиента
           используется соединение двух таблиц (accounts и clients) с группировкой, причём используется именно 
           RIGHT JOIN, чтобы в конечную выборку входили и клиенты, которые существуют, но у которых нет счетов,
           так как в представленном изначальном запросе они в выборку попадают.   
  Часть 2: подсчёт количества транзакций также вместо отдельных подзапросов вынесен в CTE, причём подсчёт 
           ведется за один запрос сразу для обоих типов транзакций путём применения условий в функции COUNT.
           Для соединения используется RIGHT JOIN, чтобы в выборку попали и те клиенты, у кого есть счёт, но нет
           транзакций, так как в случае с изначальным запросом они представлены в выборке.
  Часть 3: результаты выполнения основного запроса и CTE соединяются при помощи LEFT JOIN, чтобы в конечную
           выборку попали и клиенты без счетов. Так как у них нет транзакций, то при соединении колонки 
           total_deposits и total_withdrawals становятся NULL, а в случае с изначальным запросом для таких 
           пользователей значения в этих колонках равны 0. Поэтому, чтобы оптимизированный запрос в полной мере
           соответствовал изначальному, применяемя функция COALESCE, которая заменяет NULL значение на 0.
    Итого: все эти изменения в совокупности дают уменьшение сложности и увеличение скорости вычислений за счёт
           того, что оптимизированный запрос обращается к таблицам по одному разу: один проход для вычисления
           количества счетов и общей суммы баланса всех клиентов, удовлетворяющих условию, один проход для 
           вычисления количества транзакций, а затем просто соединяет агрегированные данные. Тогда как в 
           изначальный запросе все 4 подзапроса выполняются для каждой строки основного запроса, то есть
           они дергают таблицы счетов и транзакций ровно столько раз, сколько клиентов в таблице clients. 
           А чем больше клиентов, тем сложнее становится запрос и медленнее происходит обработка. Мой же запрос
           позволяет избежать зависимости от количества клиентов.
*/
