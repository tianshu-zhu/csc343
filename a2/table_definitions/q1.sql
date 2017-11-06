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
DROP VIEW IF EXISTS intermediate_step CASCADE;

-- Define views for your intermediate steps here.
create view year_countryName as(
    select election.id as election_id,
        extract(year from election.e_date) as year,
        country.name as countryName
    from country, election
    where country.id = election.country_id and
        extract(year from election.edate) >= 1996 and
        extract(year from election.edate) <= 2016
);

create view voteRange_partyName as(
    select election.id as election_id, party.name as partyName,
        case
        when 0 <= election_result.votes/elction.votes_valid and election_result.votes/elction.votes_valid <= 5
        Then '(0,5]'
        when 5 < election_result.votes/elction.votes_valid and election_result.votes/elction.votes_valid <= 10
        Then '(5,10]'
        when 10 < election_result.votes/elction.votes_valid and election_result.votes/elction.votes_valid <= 20
        Then '(10,20]'
        when 20 < election_result.votes/elction.votes_valid and election_result.votes/elction.votes_valid <= 30
        Then '(20,30]'
        when 30 < election_result.votes/elction.votes_valid and election_result.votes/elction.votes_valid <= 40
        Then '(30,40]'
        when 40 < election_result.votes/elction.votes_valid and election_result.votes/elction.votes_valid <= 100
        Then '(40,100]'
        end as voteRange
    from election, election_result, party
    where election.id = election_result.election_id and
        election_result.party_id = party.id
);

-- the answer to the query
insert into q1 (
    select year, countryName, voteRange, partyName
    from year_countryName, voteRange_partyName
    where voteRange_partyName.election_id = year_countryName.election_id
);
