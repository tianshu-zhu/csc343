-- Participate

SET SEARCH_PATH TO parlgov;
drop table if exists q3 cascade;

-- You must not change this table definition.

create table q3(
        countryName varchar(50),
        year int,
        participationRatio real
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS PR, nonDecreasing CASCADE;

-- Define views for your intermediate steps here.
create view PR as (
    select country_id, extract(year from e_date) as year,
        1.0*sum(votes_cast)/sum(electorate) as participationRatio
    from election
    where extract(year from e_date) <= 2016 and
        extract(year from e_date) >= 2001 and
        votes_cast is not null and
        electorate is not null
    group by country_id, extract(year from e_date)
);

create view nonDecreasing as (
    select *
    from PR
    where country_id not in (
        select distinct PR1.country_id
        from PR as PR1, PR as PR2
        where PR1.country_id = PR2.country_id and
            PR1.year > PR2.year and
            PR1.participationRatio < PR2.participationRatio
    )
);

-- the answer to the query
insert into q3 (
    select C.name as countryName, ND.year, ND.participationRatio
    from nonDecreasing as ND, country as C
    where ND.country_id = C.id
);
