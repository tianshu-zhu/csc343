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
DROP VIEW IF EXISTS year_countryName, voteRange_partyName CASCADE;

-- Define views for your intermediate steps here.
create view year_countryName as(
    select election.id as election_id,
        extract(year from election.e_date) as year,
        country.name as countryName
    from country, election
    where country.id = election.country_id and
        extract(year from election.e_date) >= 1996 and
        extract(year from election.e_date) <= 2016
);

create view voteRange_partyName as(
    select election.id as election_id, party.name_short as partyName,
        case
        when 0 <= 1.0*election_result.votes/election.votes_valid and 1.0*election_result.votes/election.votes_valid <= 0.05
        Then '(0,5]'
        when 0.05 < 1.0*election_result.votes/election.votes_valid and 1.0*election_result.votes/election.votes_valid <= 0.1
        Then '(5,10]'
        when 0.1 < 1.0*election_result.votes/election.votes_valid and 1.0*election_result.votes/election.votes_valid <= 0.2
        Then '(10,20]'
        when 0.2 < 1.0*election_result.votes/election.votes_valid and 1.0*election_result.votes/election.votes_valid <= 0.3
        Then '(20,30]'
        when 0.3 < 1.0*election_result.votes/election.votes_valid and 1.0*election_result.votes/election.votes_valid <= 0.4
        Then '(30,40]'
        when 0.4 < 1.0*election_result.votes/election.votes_valid and 1.0*election_result.votes/election.votes_valid <= 1
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
