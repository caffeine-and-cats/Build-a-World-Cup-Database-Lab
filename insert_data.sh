#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# lil clean-up before inserting data
echo "$($PSQL "TRUNCATE teams CASCADE; TRUNCATE games CASCADE;")"

: <<'INSTRUCTION'
When you run your insert_data.sh script, 
it should add each unique team to the teams table. 
There should be 24 rows
~~~ ✅ DONE ~~~
INSTRUCTION

TEAM=()
# get teams
while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # skip titles
  if [[ $WINNER == "winner" ]]
  then
    continue
  fi

  # collect unique teams from winners
  if [[ ! " ${TEAM[@]} " =~ " ${WINNER} " ]]
  then
    TEAM+=("$WINNER")
  fi

  # collect unique teams from opponents
  if [[ ! " ${TEAM[@]} " =~ " ${OPPONENT} " ]]
  then
    TEAM+=("$OPPONENT")
  fi
done < games.csv
# insert unique teams
# printf "%s\n" "${TEAM[@]}" | xargs -I {} $PSQL "INSERT INTO teams(name) VALUES ('{}');"
printf "%s\n" "${TEAM[@]}" | xargs -I {} bash -c "$PSQL \"INSERT INTO teams(name) VALUES ('{}');\" | sed 's/INSERT 0 1/Successfully inserted {}/'"

: <<'INSTRUCTION'
When you run your insert_data.sh script, 
it should insert a row for each line in the games.csv file 
(other than the top line of the file). 
There should be 32 rows. 
Each row should have every column filled in with the appropriate info. 
Make sure to add the correct ID's from the teams table 
(you cannot hard-code the values)
~~~ ✅ DONE ~~~
INSTRUCTION

# get everything for the games table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 
  # skip titles
  if [[ $WINNER == "winner" ]]
  then
    continue
  fi

  # get winner_id
  WINNER_ID="$($PSQL "select team_id from teams where name='$WINNER';")"

  # get opponent_id
  OPPONENT_ID="$($PSQL "select team_id from teams where name='$OPPONENT';")"

  # insert games table
  echo "$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")" | sed "s/INSERT 0 1/Successfully inserted $YEAR, $ROUND, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS/"
done
