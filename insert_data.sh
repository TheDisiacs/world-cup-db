#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE teams, games")"

#Add all of the teams to the teams table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ -z $WINNER ]]
  then
    echo Skipping this one because it is blank
  elif [[ $YEAR != year ]]
  then
    WIN_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT (name) DO NOTHING;")
    echo $WIN_RESULT
    if [[ $WIN_RESULT == "INSERT 0 1" ]]
    then
      echo Adding: $WINNER
    fi
    OPP_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT (name) DO NOTHING;")
    echo $OPP_RESULT
    if [[ $OPP_RESULT == "INSERT 0 1" ]]
    then
      echo Adding: $OPPONENT
    fi

  #Now add all of the data to the games table since the team_id is for sure populated
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")
  GAME_RESULT=$($PSQL "INSERT INTO games\
  (year, round, winner_id, opponent_id, winner_goals, opponent_goals)\
  values\
  ($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)") 
  else
    echo Skipping this line because it says $YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS
  fi
done
echo "$($PSQL "SELECT * from teams")"
