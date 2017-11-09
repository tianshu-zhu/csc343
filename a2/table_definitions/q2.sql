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
DROP VIEW IF EXISTS avgWinning, winningParty, threeAvgParty, mostRecentWon CASCADE;

-- Define views for your intermediate steps here.

-- Find average number of winning election for each country
create view avgWinning as (
    select 1.0*count(E.id)/count(distinct ER.party_id) as avgNumWinningElections,
        E.country_id
    from election as E, election_result as ER
    where E.id = ER.election_id
    group by E.country_id
);

-- find winning party of each election
create view winningParty as (
    select ER.party_id, ER.election_id, E.country_id, E.e_date
    from election_result as ER, election as E
    where ER.election_id = E.id and
        ER.votes = (
        select max(votes)
        from election_result as subER
        where ER.election_id = subER.election_id
        )
);

-- find number of winning election of each party
-- find party who have won > 3*average
create view threeAvgParty as (
    select party_id, country_id, count(election_id) as wonElections
    from winningParty as WP
    group by party_id, country_id
    having count(election_id) > (
        select avgNUmWinningElections*3
        from avgWinning as AW, party
        where WP.party_id = party.id and
            party.country_id = AW.country_id
        )
);

-- for each wining party
-- find most recent won election id and year
create view mostRecentWon as (
    select party_id, election_id as mostRecentlyWonElectionId,
        extract(year from e_date) as mostRecentlyWonElectionYear
    from winningParty as WP
    where e_date = (
        select max(e_date)
        from winningParty as subWP
        where WP.party_id = subWP.party_id
        )
);

-- the answer to the query 
insert into q2 (
    select country.name as countryName,
        party.name as partyName,
        PF.family as partyFamily,
        TAP.wonElections as wonElections,
        MRW.mostRecentlyWonElectionId as mostRecentlyWonElectionId,
        MRW.mostRecentlyWonElectionYear as mostRecentlyWonElectionYear
    from threeAvgParty as TAP inner join mostRecentWon as MRW
        on TAP.party_id = MRW.party_id
        inner join party
        on TAP.party_id = Party.id
        inner join country
        on TAP.country_id = country.id
        left join party_family as PF
        on TAP.party_id = PF.party_id
);  

