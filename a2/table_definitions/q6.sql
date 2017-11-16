-- Sequences

SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

-- You must not change this table definition.

CREATE TABLE q6(
        countryName VARCHAR(50),
        cabinetId INT,
        startDate DATE,
        endDate DATE,
        pmParty VARCHAR(100)
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS start_end_date, cabinet_pm CASCADE;

-- find startDate AND endDate of each cabinet
create view start_end_date as (
    select C1.country_id,
        C1.id as cabinetId,
        C1.start_date as startDate, C2.start_date as endDate
    from cabinet as C1 left join cabinet as C2
        on C1.id = C2.previous_cabinet_id
);

-- find pm party id of each cabinet
create view cabinet_pm as (
    select SED.country_id, SED.cabinetId, SED.startDate, SED.endDate, CP.party_id
    from start_end_date as SED left join cabinet_party as CP
        on SED.cabinetId = CP.cabinet_id
    where CP.pm = true
);

-- the answer to the query
insert into q6 (
    select C.name as countryName,
        CP.cabinetId, CP.startDate, CP.endDate,
        P.name as partyName
    from cabinet_pm as CP join country as C
        on CP.country_id = C.id
        left join party as P
        on CP.party_id = P.id
);
