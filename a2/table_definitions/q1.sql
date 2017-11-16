-- VoteRange

SET SEARCH_PATH TO parlgov;
drop table if exists q1 cascade;

-- You must not change this table definition.

create table q1(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS votePercent, voteRange CASCADE;

-- find vote percentage for each party in each election, each country, each year
create view votePercent as (
    select E.country_id, ER.party_id,
        extract(year from E.e_date) as year,
        1.0*ER.votes/E.votes_valid as percent
    from election as E, election_result as ER
    where E.id = ER.election_id and
        ER.votes is not null and
        E.votes_valid is not null and
        extract(year from E.e_date) >= 1996 and
        extract(year from E.e_date) <= 2016
);

-- for each party in each country, each year, find average vote percentage
-- and voteRange
create view voteRange as (
    select country_id, party_id, year,
        case
        when 0 <= 1.0*sum(percent)/count(percent) and 1.0*sum(percent)/count(percent) <= 0.05
        Then '(0-5]'
        when 0.05 < 1.0*sum(percent)/count(percent) and 1.0*sum(percent)/count(percent) <= 0.1
        Then '(5-10]'
        when 0.1 < 1.0*sum(percent)/count(percent) and 1.0*sum(percent)/count(percent) <= 0.2
        Then '(10-20]'
        when 0.2 < 1.0*sum(percent)/count(percent) and 1.0*sum(percent)/count(percent) <= 0.3
        Then '(20-30]'
        when 0.3 < 1.0*sum(percent)/count(percent) and 1.0*sum(percent)/count(percent) <= 0.4
        Then '(30-40]'
        when 0.4 < 1.0*sum(percent)/count(percent) and 1.0*sum(percent)/count(percent) <= 1
        Then '(40-100]'
        end as voteRange
    from votePercent
    group by country_id, party_id, year
);

-- the answer to the query
insert into q1 (
    select year, C.name as countryName, voteRange, P.name_short as partyName
    from voteRange as VR, party as P, country as C
    where VR.country_id = C.id and
        VR.party_id = P.id
);
