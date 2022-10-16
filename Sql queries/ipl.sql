create table ball_by_ball(
    id int,
    innings int,
    overs int,
    ballnumber int,
    batter varchar,
    bowler varchar,
    non_striker varchar,
    extra_type varchar,
    batsman_run int,
    extras_run int,
    total_run int,
    non_boundary int,
    isWicketDelivery int,
    player_out varchar,
    kind varchar,
    fielders_involved varchar,
    battingteam varchar
);

copy ball_by_ball from 'D:\summer internship\live project\IPL_Ball_by_Ball_2008_2022.csv' with (format 'csv', header true);

select * from ball_by_ball limit 10;

select count(*) as number_of_rows from ball_by_ball;
select count(*) as number_of_columns from information_schema.columns where table_name = 'ball_by_ball';

--Highest total runs scored record belongs to
select batter,sum(total_run) as "total runs scored" from ball_by_ball group by batter
order by sum(total_run) desc limit 5;
--Ans - V kohli

--Highest wicket taker record belongs to
select bowler,sum(isWicketDelivery) as "Wickets taken" from ball_by_ball group by bowler
order by sum(isWicketDelivery) desc limit 5;
--Ans - DJ Bravo

--Teams with highest and lowest score
select battingteam, sum(total_run) as "total runs by team" from ball_by_ball group by battingteam
order by sum(total_run) desc limit 1;
--Ans - Mumbai Indians
select battingteam, sum(total_run) as "total runs by team" from ball_by_ball group by battingteam
order by sum(total_run) asc limit 1;
--Ans - Kochi Tuskers kerala

--Total Number of matches played 
select count(distinct id) as "Number of matches" from ball_by_ball;

--Average of all Batsman and batsman with highest average
select batter,(sum(total_run)/count(distinct id)) as "Average of Batsman"
from ball_by_ball group by batter
order by (sum(total_run)/count(distinct id)) desc;
--Ans - KL Rahul

select bowler,(sum(total_run)/count(distinct id)) as "Average of Bowlers"
from ball_by_ball group by bowler
order by (sum(total_run)/count(distinct id)) desc;
--Ans - MG Nesser

--Return a column with comment based on total runs as howzthat.
select batter, total_run,
case when total_run = 1 then 'single'
when total_run = 4 then 'four'
when total_run = 6 then 'six'
when total_run = 0 then 'duck'
end as Howzthat
from ball_by_ball;

--Batsman with highest strike rate
select batter, batsman_runs,((batsman_runs*1.0)/total_balls)*100 as strike_rate from
(select batter,sum(batsman_run) as batsman_runs, count(batter) as total_balls
from ball_by_ball group by batter) as x order by strike_rate desc limit 5;

create table matches(
  id int,
    city varchar,
    match_date date,
    season varchar,
    match_number varchar,
    team1 varchar,
    team2 varchar,
    venure varchar,
    toss_winner varchar,
    toss_decision varchar,
    superover varchar,
    winning_team varchar,
    wonby varchar,
    margin varchar,
    method varchar,
    player_of_match varchar,
    team1_player varchar,
    team2_player varchar,
    umpire1 varchar,
    umpire2 varchar
);

copy matches from 'D:\summer internship\live project\IPL_Matches_2008_2022.csv' with (format 'csv', header true);

--total number of matches played in a season
select yr,count(distinct id) as number_of_matches from
(select extract(year from match_date) as yr, id from matches) as A group by yr;

--player with number of player of matches award
select player_of_match, count(player_of_match) from matches group by player_of_match order by count(player_of_match) desc;

--which player has won highest player of match per season
select player_of_match,yr,mom,rank() over (partition by yr order by mom desc)as Rank_of_player from (
select player_of_match, extract(year from match_date) as yr,count(player_of_match) as mom from matches
group by player_of_match, extract(year from match_date) order by count(player_of_match) desc) as X;

--team that has won highest number of matches per year
select winning_team,count(winning_team) from matches group by winning_team order by count(winning_team) desc;

--top 5 venues where the match has been played
select venure, count(venure) as "number of matches played" from matches 
group by venure order by count(venure) desc limit 5; 

--percentage of total runs scored by all batsman in all of ipl history
select *,total_runs/sum(total_runs) over(order by total_runs rows between unbounded preceding and unbounded following)
as runs from 
(select batter,sum(total_run) as total_runs from ball_by_ball group by batter) as a order by total_runs desc;

--total number of Six's by each batsman
select batter,count(batter) from
(select * from ball_by_ball where batsman_run = 6) as x group by batter;

--3000 runs club with the highest strike rate
select batter,batsman_runs,strike_rate from
(select batter, batsman_runs,((batsman_runs*1.0)/total_balls)*100 as strike_rate from
(select batter,sum(batsman_run) as batsman_runs, count(batter) as total_balls
from ball_by_ball group by batter) as x order by strike_rate desc) as b
where batsman_runs>=3000 order by strike_rate desc limit 1;

--lowest economy rate for bowler who has who has bowled atleast 50 overs
select bowler,total_runs_conceeded/(total_balls*1.0) as economy_rate from
(select bowler, count(bowler) as total_balls, sum(total_run) as total_runs_conceeded
from ball_by_ball group by bowler) as x
where total_balls > 300 order by economy_rate asc;

--matches played in the month of May
select count(*) from matches where extract(month from match_date) = 5;

--Create a third table as a materialised view which contains columns from both the tables
create materialized view IPL_Complete_Dataset as 
select a.id, a.batter,a.bowler,a.battingteam, b.city,b.season,b.toss_winner from
ball_by_ball a join matches b 
on a.id = b.id;

select * from ipl_complete_dataset;

--batsman with names starting with S
select count(Distinct batter) from ball_by_ball where batter like 'S%';

