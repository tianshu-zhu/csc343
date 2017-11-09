insert into election (id, country_id, e_date, seats_total, electorate, e_type)
    values (2020, 29, '2020-01-01', 300, 300000000, 'Parliamentary election');

insert into election_result (id, election_id, party_id, alliance_id) values
    (10001, 2020, 368, null),
    (10002, 2020, 1259, 10001),
    (10003, 2020, 2148, 10001),
    (10004, 2020, 296, null),
    (10005, 2020, 1255, 10004);
