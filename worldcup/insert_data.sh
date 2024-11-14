#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams")


while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
  winner_id=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  
  if [[ -z "$winner_id" ]]
  then
    winner_id=$($PSQL "INSERT INTO teams(name) VALUES('$winner') RETURNING team_id" | head -n 1)
  fi
  opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  
  if [[ -z "$opponent_id" ]]
  then
    opponent_id=$($PSQL "INSERT INTO teams(name) VALUES('$opponent') RETURNING team_id" | head -n 1)
  fi
  echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)")
done < <(tail -n +2 games.csv)