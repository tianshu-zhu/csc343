SET SEARCH_PATH TO parlgov;

select *
from q2
order by countryName, wonElections, partyName desc;
