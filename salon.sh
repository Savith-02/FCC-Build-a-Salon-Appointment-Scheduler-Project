#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~ Welcome to our Salon Appointment schedular ~~~\n"

APPOINTMENT_MENU() {

  if [[ ! -z $1 ]] 
  then
    echo -e "\n$1"
  fi

  echo -e "These are the services that we provide:\n"

  SERVICES_LIST=$($PSQL "SELECT * FROM services")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  echo -e "\nChoose the desired service and enter the number..."
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    APPOINTMENT_MENU "Invalid Input."
  fi

  PICKED_SERVICE_RESULT=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $PICKED_SERVICE_RESULT ]]
  then
    APPOINTMENT_MENU "NO service under that number."
  else
    echo "Enter your phone number:"
    read CUSTOMER_PHONE

    if [[ ! $CUSTOMER_PHONE =~ ^[0-9-]+$ ]]
    then
      APPOINTMENT_MENU "Invalid Phone Number"
    fi

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo Enter your name:
      read CUSTOMER_NAME
      if [[ ! $CUSTOMER_NAME =~ ^[a-zA-Z]+$ ]]
      then
        APPOINTMENT_MENU "Invalid Input"
      else
        INSERT_NEW_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    echo "Enter the time of appointment:"
    read SERVICE_TIME
    if [[ -z $SERVICE_TIME ]]
    then
      echo "Invalid format. Enter time in __:__ format."
    else
    MAKE_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    fi

  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  echo "I have put you down for a $SERVICE at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."  
  fi
  exit
  
}

APPOINTMENT_MENU
