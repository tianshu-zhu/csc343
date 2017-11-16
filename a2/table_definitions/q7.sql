-- Alliances

SET SEARCH_PATH TO parlgov;
drop table if exists q7 cascade;

-- You must not change this table definition.

DROP TABLE IF EXISTS q7 CASCADE;
CREATE TABLE q7(
        countryId INT,
        alliedPartyId1 INT,
        alliedPartyId2 INT
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS allied_pairs,  num_elections, allied_percent CASCADE;

-- Define views for your intermediate steps here.

-- Get all pairs of parties that have been allies
create view allied_pairs as (
    select ER1.election_id,
        E.country_id as countryId,
        ER1.party_id as alliedPartyId1,
        ER2.party_id as alliedPartyId2
    from election_result as ER1, election_result as ER2, election as E
    where ER1.election_id = ER2.election_id and
        ER1.election_id = E.id and
        (ER1.id = ER2.alliance_id or ER1.alliance_id = ER2.alliance_id or ER2.id = ER1.alliance_id) and
        ER1.party_id < ER2.party_id
);

-- Get number of elections happened in all Countries
create view num_elections as (
    select country_id as countryId, count(id)
    from election
    group by country_id
);

-- Get percentage of each ally pair
create view allied_percent as (
    select 1.0*count(*)/NE.count as percent,
        AP.alliedPartyId1, AP.alliedPartyId2, AP.countryId
    from allied_pairs as AP, num_elections as NE
    where AP.countryId = NE.countryId
    group by AP.alliedPartyId1, AP.alliedPartyId2, AP.countryId, NE.count
);

-- the answer to the query
insert into q7 (
    select countryId, alliedPartyId1, alliedPartyId2
    from allied_percent as AP
    where AP.percent >= 0.3
);
