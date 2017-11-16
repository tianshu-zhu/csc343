-- Committed

SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- You must not change this table definition.

CREATE TABLE q5(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(50),
        stateMarket REAL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS twenty_years_cabinet, all_combinations,
    not_committed_parties, committed_parties CASCADE;

-- Define views for your intermediate steps here.

-- Find all cabinets in the past 20 years
create view twenty_years_cabinet as (
    select *
    from cabinet
    where 1996 <= extract(year from start_date) and
        extract(year from start_date) <= 2016
);

-- Find all possible combinations of parties and cabinets in the last 20 years
create view all_combinations as (
    select P.id AS party_id, TYC.id as cabinet_id
    from party as P, twenty_years_cabinet as TYC
    where P.country_id = TYC.country_id
);

-- Find parties that are not committed by taking exception
create view not_committed_parties as (
    (select party_id, cabinet_id
    from all_combinations)
    except
    (select party_id, cabinet_id
    from cabinet_party)
);

-- Find parties that are committed by taking exception
create view committed_parties as (
    (select id as party_id
    from party)
    except
    (select party_id
    from not_committed_parties)
);

-- the answer to the query
insert into q5 (
    select C.name as countryName,
        P.name as PartyName,
        PF.family as partyFamily,
        PP.state_market as stateMarket
    from committed_parties as CP inner join party as P
        on CP.party_id = P.id
        inner join country as C
        on P.country_id = C.id
        left join party_family as PF
        on CP.party_id = PF.party_id
        left join party_position as PP
        on CP.party_id = PP.party_id
);
