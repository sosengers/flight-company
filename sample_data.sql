INSERT INTO flights (
    flight_id, 
    departure_airport_code, 
    arrival_airport_code, 
    cost, 
    departure_datetime, 
    arrival_datetime, 
    sold_tickets, 
    insertion_date
) VALUES (
    1,
    'ABC',
    'DEF',
    56.43,
    '2021-05-01T18:54',
    '2021-05-01T19:28',
    0,
    CURRENT_DATE
);

INSERT INTO flights (
    flight_id, 
    departure_airport_code, 
    arrival_airport_code, 
    cost, 
    departure_datetime, 
    arrival_datetime, 
    sold_tickets, 
    insertion_date
) VALUES (
    2,
    'DEF',
    'ABC',
    18.97,
    '2021-05-31T06:47',
    '2021-05-01T08:13',
    0,
    CURRENT_DATE
);
