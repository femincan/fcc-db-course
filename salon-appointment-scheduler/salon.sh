#!/bin/bash

echo -e "\n~~~ Barber Shop ~~~\n"

PSQL="psql -qAtX --username=freecodecamp --dbname=salon -c"

SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

if [[ !($SERVICES) ]]
then
  echo "We don't have any services available at the moment. Maybe we may have something for you in the future."
  exit 1
fi

SERVICE_IDS=()
while IFS="|" read -r SERVICE_ID SERVICE_NAME
do
  SERVICE_IDS+=("$SERVICE_ID")
done <<< "$SERVICES"

while [[ ! $SERVICE_ID_SELECTED || ! ${SERVICE_IDS[@]} =~ $SERVICE_ID_SELECTED ]]
do
  echo -e "\nPlease select the service you'd like to make an appointment for:"
  echo "$SERVICES" | while IFS="|" read -r SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
done

IS_PHONE_BLANK=false
echo -e "\nPlease enter your phone number":
while [[ ! $CUSTOMER_PHONE ]]
do
  if [[ $IS_PHONE_BLANK = false ]]
  then
    IS_PHONE_BLANK=true
  else
    echo -e "\nPhone number cannot be left blank. Please enter it."
  fi

  read CUSTOMER_PHONE
done

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ ! $CUSTOMER_ID ]]
then
  IS_NAME_BLANK=false
  echo -e "\nPlease enter your name:"
  while [[ ! $CUSTOMER_NAME ]]
  do
    if [[ $IS_NAME_BLANK = false ]]
    then
      IS_NAME_BLANK=true
    else
      echo -e "\nName cannot be left blank. Please enter it."
    fi
    read CUSTOMER_NAME
  done
  
  CUSTOMER_ID=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME') RETURNING customer_id")
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
fi

IS_TIME_BLANK=false
echo -e "\nPlease enter the time you'd like to make an appointment:"
while [[ ! $SERVICE_TIME ]]
do
  if [[ $IS_TIME_BLANK = false ]]
  then
    IS_TIME_BLANK=true
  else
    echo -e "\nAppointment time cannot be left blank. Please enter it."
  fi

  read SERVICE_TIME
done

($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."