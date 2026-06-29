-- create
create table tranches (
		inn text,
	  credit_num text, 
    account text,
    operation_datetime timestamp,
    operation_sum numeric,
    doc_id numeric
);

create table transactions (
		inn int8,
    account text,
    operation_datetime timestamp,
    operation_sum numeric,
    ctrg_inn int8,
    ctrg_account text,
    doc_id text
);

-- insert
insert into tranches (inn, credit_num, account, operation_datetime, operation_sum, doc_id) values
	('1234567890', 'CREDIT001', '40817810000000000001', '2024-01-01 10:00:00', 1000.00, 1),
  ('1234567890', 'CREDIT002', '40817810000000000002', '2024-01-05 12:00:00', 1500.00, 2),
  ('1234567890', 'CREDIT003', '40817810000000000003', '2024-01-10 14:00:00', 2000.00, 3),
  ('2345678901', 'CREDIT004', '40817810000000000004', '2024-02-15 09:30:00', 3000.00, 4),
  ('3456789012', 'CREDIT005', '40817810000000000005', '2024-03-20 16:45:00', 5000.00, 5),
  ('4567890123', 'CREDIT006', '40817810000000000006', '2024-04-25 11:15:00', 7500.00, 6),
  ('5678901234', 'CREDIT007', '40817810000000000007', '2024-05-30 14:20:00', 10000.00, 7),
  ('6789012345', 'CREDIT008', '40817810000000000008', '2024-06-10 13:00:00', 12500.00, 8),
  ('7890123456', 'CREDIT009', '40817810000000000009', '2024-07-15 10:45:00', 15000.00, 9),
  ('8901234567', 'CREDIT010', '40817810000000000010', '2024-08-20 15:30:00', 20000.00, 10); 

insert into transactions (inn, account, operation_datetime, operation_sum, ctrg_inn, ctrg_account, doc_id) values
	(1234567890, '40817810000000000001', '2024-01-02 10:10:00', 900.00, 9876543210, '40817810000000000014', 'T1'),
  (2345678901, '40817810000000000004', '2024-02-17 11:20:00', 3500.00, 8765432109, '40817810000000000015', 'T2'),
  (1234567890, '40817810000000000003', '2024-01-15 14:05:00', 2500.00, 9876543210, '40817810000000000006', 'T3'),
  (2345678901, '40817810000000000004', '2024-02-16 10:10:00', 3200.00, 8765432109, '40817810000000000007', 'T4'),
  (7890123456, '40817810000000000009', '2024-07-18 10:15:00', 16000.00, 3210987654, '40817810000000000012', 'T5'),
  (1234567890, '40817810000000000002', '2024-01-06 12:05:00', 1500.00, 9876543210, '40817810000000000005', 'T6'),
  (5678901234, '40817810000000000007', '2024-06-01 14:40:00', 11000.00, 5432109876, '40817810000000000010', 'T7'),
  (6789012345, '40817810000000000008', '2024-06-12 13:50:00', 13000.00, 4321098765, '40817810000000000011', 'T8'),
  (3456789012, '40817810000000000005', '2024-03-22 15:20:00', 5500.00, 7654321098, '40817810000000000008', 'T9'),
  (8901234567, '40817810000000000010', '2024-08-22 15:25:00', 15000.00, 2109876543, '40817810000000000013', 'T10'), 
  (1234567890, '40817810000000000001', '2024-01-01 10:05:00', 1000.00, 9876543210, '40817810000000000004', 'T11'),
  (4567890123, '40817810000000000006', '2024-04-27 11:30:00', 8000.00, 6543210987, '40817810000000000009', 'T12'),
  (8901234567, '40817810000000000010', '2024-08-25 16:30:00', 5800.00, 7654321098, '40817810000000000016', 'T13');

-- fetch
WITH t1 AS (
  SELECT t.inn, t.account, t.operation_datetime, t.operation_sum, t.ctrg_inn, t.ctrg_account, t.doc_id 
  FROM transactions t
  JOIN tranches ON t.account = tranches.account 
  WHERE t.operation_sum = tranches.operation_sum 
  AND EXTRACT(DAY FROM t.operation_datetime) <= EXTRACT(DAY FROM tranches.operation_datetime) + 10
  AND EXTRACT(YEAR FROM t.operation_datetime) = '2024'
  ORDER BY t.inn, t.operation_datetime
), 
t2 AS (
  SELECT t.inn, t.account, t.operation_datetime, t.operation_sum, t.ctrg_inn, t.ctrg_account, t.doc_id 
  FROM transactions t
  JOIN tranches ON t.account = tranches.account 
  WHERE t.operation_sum > tranches.operation_sum
  AND EXTRACT(YEAR FROM t.operation_datetime) = '2024'
  ORDER BY t.inn, t.operation_datetime
) 

SELECT * FROM t1 
UNION ALL 
SELECT * FROM t2
WHERE NOT EXISTS (
  SELECT 1
  FROM t1
  WHERE t1.account = t2.account
);
