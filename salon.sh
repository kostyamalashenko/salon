#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
MAIN_MENU() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi



SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
echo "$SERVICE_ID) $NAME"
done

read SERVICE_ID_SELECTED

AVAILABLE_SERVICES=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")


if [[ -z $AVAILABLE_SERVICES ]]
then
MAIN_MENU "I could not find that service. What would you like today?"
else
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

if [[ -z $CUSTOMER_NAME ]]
then
echo -e "\nI don't have a record for that phone number, what's your name?"
read CUSTOMER_NAME

echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
read SERVICE_TIME

INSERT_CUSTOMERS=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
INSERT_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

SERVICE_NAME=$($PSQL "SELECT name FROM services INNER JOIN appointments USING(service_id) WHERE customer_id = '$CUSTOMER_ID'")
SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^[ \t]*//;s/[ \t]*$//')
echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
else
CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^[ \t]*//;s/[ \t]*$//')
echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME_FORMATTED?"
read SERVICE_TIME
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
INSERT_APPOINTMENTS=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
# get new appointment_id
NEW_APPOINTMENT_ID=$($PSQL "SELECT appointment_id FROM appointments WHERE time = '$SERVICE_TIME' AND customer_id = '$CUSTOMER_ID'")
NEW_SERVICE_NAME=$($PSQL "SELECT name FROM services INNER JOIN appointments USING(service_id) WHERE appointment_id = '$NEW_APPOINTMENT_ID'")


NEW_SERVICE_NAME_FORMATTED=$(echo $NEW_SERVICE_NAME | sed 's/^[ \t]*//;s/[ \t]*$//')
echo -e "\nI have put you down for a $NEW_SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
fi

fi

}
MAIN_MENU
