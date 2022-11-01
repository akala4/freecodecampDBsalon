#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon Appointments ~~~~~\n"
SERVICES=$($PSQL "SELECT service_id, name FROM services;")

CONFIRMED_SERVICE_ID=0
while [[ $CONFIRMED_SERVICE_ID -le 0 ]]
  do

  echo -e "\nChoose a service:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then 
      echo -e "\nPlease enter a number.\n"
    else
      SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id="$SERVICE_ID_SELECTED";")
      if [[ -z $SERVICE_AVAILABILITY ]]
      then
        echo -e "\nTry harder.\n"
      else
        CONFIRMED_SERVICE_ID=$SERVICE_AVAILABILITY
      fi
  fi
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
        
if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
fi
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$CONFIRMED_SERVICE_ID;")
echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g'), $(echo $CUSTOMER_NAME| sed -E 's/^ *| *$//g')?"
read SERVICE_TIME
APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(service_id,customer_id,time) VALUES( $CONFIRMED_SERVICE_ID ,$CUSTOMER_ID,'$SERVICE_TIME');")
echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME| sed -E 's/^ *| *$//g')."

