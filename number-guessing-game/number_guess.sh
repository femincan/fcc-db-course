#!/bin/bash

psql="psql -qAtX --username=freecodecamp --dbname=number_guess -c"

echo "Enter your username:"
read username

user_info=$($psql "SELECT games_played, best_game FROM users WHERE username='$username'")

if [[ -n $user_info ]]
then
  IFS="|" read -r games_played best_game <<< $user_info

  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
else
  user_info=$($psql "INSERT INTO users(username) VALUES('$username') RETURNING games_played, best_game")

  IFS="|" read -r games_played best_game <<< $user_info

  echo "Welcome, $username! It looks like this is your first time here."
fi

secret_number=$((($RANDOM % 1000) + 1))
echo "Guess the secret number between 1 and 1000:"

tries=0
while [[ true ]]
do
  read guess
  ((tries++))

  if [[ ! $guess =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  if [[ $guess -gt $secret_number ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $guess -lt $secret_number ]]
  then
    echo "It's higher than that, guess again:"
  else
    break
  fi
done

echo "You guessed it in $tries tries. The secret number was $secret_number. Nice job!"

((games_played++))
if [[ -z $best_game || $tries < $best_game ]]
then
  ($psql "UPDATE users SET games_played = $games_played, best_game = $tries WHERE username='$username'")
else
  ($psql "UPDATE users SET games_played = $games_played WHERE username='$username'")
fi