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
DROP VIEW IF EXISTS cabinet_past_20 CASCADE;
DROP VIEW IF EXISTS expected_combination CASCADE;
DROP VIEW IF EXISTS not_committed_party CASCADE;
DROP VIEW IF EXISTS committed_party CASCADE;
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS intermediate_step1 CASCADE;
DROP VIEW IF EXISTS intermediate_step2 CASCADE;




CREATE VIEW cabinet_past_20 AS
SELECT *
FROM cabinet
WHERE 1996 <= EXTRACT(YEAR FROM start_date) AND EXTRACT(YEAR FROM start_date) <= 2016;

CREATE VIEW expected_combination AS
SELECT party.id AS party_id, cabinet_past_20.id AS cabinet_id
FROM party, cabinet_past_20
WHERE party.country_id = cabinet_past_20.country_id;

CREATE VIEW not_committed_party AS
(SELECT party_id, cabinet_id
FROM expected_combination)
EXCEPT
(SELECT party_id, cabinet_id
FROM cabinet_party);

CREATE VIEW committed_party AS
(SELECT id AS party_id FROM party)
EXCEPT
(SELECT party_id FROM not_committed_party);

-- Define views for your intermediate steps here.
-- Get all the committed parties 
CREATE VIEW intermediate_step AS (
SELECT country.name AS countryName, party.name AS partyName, committed_party.party_id
FROM  country, committed_party, party
WHERE committed_party.party_id = party.id
	AND party.country_id = country.id
);

-- Get their partyFamily information from party_family table
CREATE VIEW intermediate_step1 AS (
SELECT countryName, partyName, party_family.family AS partyFamily, intermediate_step.party_id
FROM intermediate_step LEFT JOIN party_family ON intermediate_step.party_id = party_family.party_id
);

-- Get their stateMarket information from party_position table
CREATE VIEW intermediate_step2 AS (
SELECT countryName, partyName, partyFamily, party_position.state_market AS stateMarket
FROM intermediate_step1 LEFT JOIN party_position ON intermediate_step1.party_id = party_position.party_id
);


-- the answer to the query 
insert into q5 (SELECT DISTINCT * FROM intermediate_step2);
