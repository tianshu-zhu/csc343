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
DROP VIEW IF EXISTS won_parties, num_wons, num_parties, num_elections,
    average_wons, major_won_parties, most_recent_wons CASCADE;

-- Define views for your intermediate steps here.

-- Find all parties that have won some elections
create view won_parties as (
    select election_id, party_id
    from election_result as E1
    where votes = (
        select max(votes)
        from election_result as E2
        where E1.election_id = E2.election_id
    )
);

-- Find number of wins of each party who have won
-- Find the most recent won election date of each party
create view num_wons as (
    select WP.party_id, count(*) as num_won, max(E.e_date) as most_recent_e_date
    from won_parties as WP, election as E
    where WP.election_id = E.id
    group by WP.party_id
);

-- Find number of parties in each country
create view num_parties as (
    select count(*) as num_party, country_id
    from party
    group by country_id
);

-- Find the total number of won elections of each country
create view num_elections as (
    select P.country_id, sum(NW.num_won) as num_election
    from party as P, num_wons as NW
    where NW.party_id = P.id
    group by P.country_id
);

-- Find 3 times the average number of won elections of each country
create view average_wons as (
    select NP.country_id, ((3.0*NE.num_election)/NP.num_party) as three_average
    from num_parties as NP, num_elections as NE
    where NP.country_id = NE.country_id
);

-- Find all parties that have won more than three times the average
create view major_won_parties as (
    select P.country_id, P.id as party_id, NW.num_won, NW.most_recent_e_date
    from num_wons as NW, party as P, average_wons as A
    where p.ID = NW.party_id and
        P.country_id = A.country_id and
        NW.num_won > A.three_average
);

-- Find most recent election id and year of each major won party
create view most_recent_wons as (
    select MWP.country_id, MWP.party_id, MWP.num_won,
        E.id as mostRecentlyWonElectionId,
        extract(year from E.e_date) as mostRecentlyWonElectionYear
    from major_won_parties as MWP, election_result as ER, election as E
    where MWP.party_id = ER.party_id and
        ER.election_id = E.id and
        E.e_date = MWP.most_recent_e_date
);

-- the answer to the query
insert into q2 (
    select C.name as countryName,
        P.name as partyName,
        PF.family as partyFamily,
        MRW.num_won as wonElections,
        MRW.mostRecentlyWonElectionId,
        MRW.mostRecentlyWonElectionYear
    from most_recent_wons as MRW inner join country as C
        on MRW.country_id = C.id
        inner join party as P
        on MRW.party_id = P.id
        left join party_family as PF
        on MRW.party_id = PF.party_id
);
