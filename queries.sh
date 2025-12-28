#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=worldcup --no-align --tuples-only -c"

# Do not change code above this line. Use the PSQL variable above to query your database.

: <<'INSTRUCTION'
You should correctly complete the queries in the queries.sh file. 
Fill in each empty echo command 
to get the output of what is suggested with the command above it. 
Only use a single line like the first query. 
The output should match what is in the expected_output.txt file exactly, 
take note of the number of decimal places in some of the query results
INSTRUCTION

echo -e "\nTotal number of goals in all games from winning teams:"
echo "$($PSQL "SELECT SUM(winner_goals) FROM games")"

echo -e "\nTotal number of goals in all games from both teams combined:"
echo "$($PSQL "SELECT SUM(winner_goals + opponent_goals) AS all_goals_sum FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams:"
echo "$($PSQL "SELECT AVG(winner_goals) AS avg_winner_goals FROM games")"

echo -e "\nAverage number of goals in all games from the winning teams rounded to two decimal places:"
echo "$($PSQL "SELECT ROUND(AVG(winner_goals), 2) as avg_winner_goals_round FROM games")"

echo -e "\nAverage number of goals in all games from both teams:"
echo "$($PSQL "SELECT AVG(winner_goals + opponent_goals) AS all_goals_avg FROM games")"

echo -e "\nMost goals scored in a single game by one team:"
echo "$($PSQL "WITH both_columns AS (SELECT winner_goals AS all_goals FROM games UNION ALL SELECT opponent_goals AS all_goals FROM games) SELECT MAX(all_goals) FROM both_columns")"

echo -e "\nNumber of games where the winning team scored more than two goals:"
echo "$($PSQL "SELECT COUNT(*) FROM games WHERE winner_goals > 2")"

echo -e "\nWinner of the 2018 tournament team name:"
: <<'DRAFT'
SELECT name
FROM teams
INNER (?) JOIN games
ON teams.team_id=games.winner_id
WHERE year=2018 
AND round='Final';
DRAFT
echo "$($PSQL "SELECT name FROM teams INNER JOIN games ON teams.team_id=games.winner_id WHERE year=2018 AND round='Final'")"

echo -e "\nList of teams who played in the 2014 'Eighth-Final' round:"
: <<'DRAFT'
WITH ef2014 
AS (
    SELECT winner_id
    AS team_id
    FROM games
    WHERE year=2014
    AND round='Eighth-Final'
    UNION
    SELECT opponent_id
    AS team_id
    FROM games
    WHERE year=2014
    AND round='Eighth-Final'
    )
SELECT name
FROM ef2014
JOIN teams 
USING(team_id)
ORDER BY name;
DRAFT
echo "$($PSQL "WITH ef2014 AS (SELECT winner_id AS team_id FROM games WHERE year=2014 AND round='Eighth-Final' UNION SELECT opponent_id AS team_id FROM games WHERE year=2014 AND round='Eighth-Final') SELECT name FROM ef2014 JOIN teams USING(team_id) ORDER BY name")"

echo -e "\nList of unique winning team names in the whole data set:"
echo "$($PSQL "SELECT DISTINCT name FROM teams INNER JOIN games ON teams.team_id=games.winner_id ORDER BY name")"

echo -e "\nYear and team name of all the champions:"
: <<'DRAFT'
SELECT year, name
FROM teams
INNER JOIN games
ON teams.team_id=games.winner_id
WHERE round='Final'
ORDER BY year;
DRAFT
echo "$($PSQL "SELECT year, name FROM teams INNER JOIN games ON teams.team_id=games.winner_id WHERE round='Final' ORDER BY year")"

echo -e "\nList of teams that start with 'Co':"
echo "$($PSQL "SELECT name FROM teams WHERE name LIKE 'Co%' ORDER BY name")"
