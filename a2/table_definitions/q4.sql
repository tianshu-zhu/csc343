-- Left-right

SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

-- You must not change this table definition.


CREATE TABLE q4(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.

-- the answer to the query
INSERT INTO q4 (
    select C.name as countryName,
        count(case when 0<=PP.left_right and PP.left_right<2 then 1 else null end) as r0_2,
        count(case when 2<=PP.left_right and PP.left_right<4 then 1 else null end) as r2_4,
        count(case when 4<=PP.left_right and PP.left_right<6 then 1 else null end) as r4_6,
        count(case when 6<=PP.left_right and PP.left_right<8 then 1 else null end) as r6_8,
        count(case when 8<=PP.left_right and PP.left_right<=10 then 1 else null end) as r8_10
    from party_position as PP join party as P
        on PP.party_id = P.id
        right join country as C
        on P.country_id = C.id
    group by C.id, C.name
);
