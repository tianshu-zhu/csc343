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
DROP VIEW IF EXISTS allian_tuple CASCADE;
DROP VIEW IF EXISTS num_election_in_country CASCADE;
DROP VIEW IF EXISTS llian_percent CASCADE;

-- Define views for your intermediate steps here.

-- Find all allian_tuples where partyId1 < partyId2
CREATE VIEW allian_tuple as(
SELECT e.country_id, case
WHEN r1.party_id < r2.party_id THEN r1.party_id
ELSE r2.party_id
END as first_party, case
WHEN r1.party_id < r2.party_id THEN r2.party_id
ELSE r1.party_id
END as second_party
FROM election e, election_result r1, election_result r2
WHERE e.id = r1.election_id and e.id = r2.election_id and (r1.id = r2.alliance_id or (r1.alliance_id = r2.alliance_id and r1.party_id < r2.party_id))
);

-- Total number of elections in a country
CREATE VIEW num_election_in_country as(
SELECT country_id, count(*) as num_election
FROM election
GROUP BY country_id
);

-- Calculate the percentage of two parties form an allian
CREATE VIEW allian_percent as(
SELECT a.country_id, a.first_party, a.second_party, ((1.0*count(*)/n.num_election)*100) as percent
FROM allian_tuple a, num_election_in_country n
WHERE a.country_id = n.country_id
GROUP BY a.country_id, a.first_party, a.second_party, n.num_election
);

-- the answer to the query 
insert into q7 (
	SELECT a.country_id, a.first_party, a.second_party
	FROM allian_percent a
	WHERE a.percent >= 30);
