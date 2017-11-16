-- Winners

SET SEARCH_PATH TO parlgov;
drop table if exists q2 cascade;

-- You must not change this table definition.

create table q2(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps.  (But give them better names!)
DROP VIEW IF EXISTS all_won_party CASCADE;
DROP VIEW IF EXISTS won_party CASCADE;
DROP VIEW IF EXISTS num_party_in_country CASCADE;
DROP VIEW IF EXISTS num_election CASCADE;
DROP VIEW IF EXISTS average_election CASCADE;
DROP VIEW IF EXISTS outstanding_party CASCADE;
DROP VIEW IF EXISTS most_recent_won_election CASCADE;
DROP VIEW IF EXISTS result CASCADE;

-- Define views for your intermediate steps here.

-- Find all the party which won an election.
CREATE VIEW all_won_party as( 
SELECT  e1.id, e1.election_id, e1.party_id, e1.votes
FROM election_result e1
WHERE votes = (
	SELECT  max(votes)
	FROM election_result e2
	WHERE e1.election_id = e2.election_id)
);

-- Calculate haw mamy time each party won.
-- Include the date of most recent election.
CREATE VIEW won_party as(
SELECT a.party_id, count(*) as num_won, max(e.e_date) as e_date
FROM all_won_party a, election e
WHERE e.id = a.election_id
GROUP BY a.party_id
);

-- Count the number of parties in each country.
CREATE VIEW num_party_in_country as(
SELECT country_id, count(*) as num_of_party
FROM party
GROUP BY country_id
);

-- Count the total number of won in each country.
CREATE VIEW num_election as(
SELECT country_id, sum(w.num_won) as num_of_win
FROM party p, won_party w
WHERE w.party_id = p.id
GROUP BY p.country_id
);

-- Calculate the 3 times the average number of winning elections of parties of the same country.
CREATE VIEW average_election as(
SELECT c.country_id, ((3.0*e.num_of_win)/c.num_of_party) as average
FROM num_party_in_country c, num_election e
WHERE c.country_id = e.country_id
);

-- Find all parties achieve the requirement
CREATE VIEW outstanding_party as(
SELECT p.country_id, p.id as party_id, w.num_won
FROM won_party w, party p, average_election a
WHERE p.id = w.party_id and p.country_id = a.country_id and w.num_won > a.average
);

-- Include the information of the most recent won election
CREATE VIEW most_recent_won_election as(
SELECT r1.party_id, e1.id as mostRecentlyWonElectionId, EXTRACT(YEAR FROM e1.e_date) as mostRecentlyWonElectionYear
FROM outstanding_party o, election_result r1, election e1,
	(SELECT w.party_id, w.e_date
	FROM won_party w, outstanding_party p
	WHERE w.party_id = p.party_id) d
WHERE d.party_id = o.party_id and o.party_id = r1.party_id and e1.id = r1.election_id and e1.e_date = d.e_date
);

-- Include other information needed.
CREATE VIEW result as(
SELECT c.name as countryName, p.name as partyName, f.family as partyFamily, o.num_won as wonElections, m.mostRecentlyWonElectionId, m.mostRecentlyWonElectionYear
FROM most_recent_won_election m, country c, party p, (outstanding_party o LEFT JOIN party_family f ON f.party_id = o.party_id)
WHERE o.party_id = m.party_id and c.id = o.country_id and p.id = o.party_id
);


-- the answer to the query 
insert into q2 (SELECT * FROM result);


