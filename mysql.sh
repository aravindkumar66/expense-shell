#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
# #echo "User ID is: $USERID"
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R please run this script with root previliges $N" | tee -a $LOG_FILE
        exit 1
    fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
         echo "$2 command is failed" | tee -a $LOG_FILE
         exit 1
    else
         echo "$2 command is.. sucess" | tee -a $LOG_FILE
    fi 

}


echo "script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MYSQL server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "mysql enable server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "start mysql server"

mysql -h mysql.akdevops.site -u root  -pExpenseApp@1 -e 'show datadbases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "mysql root password not setup, setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "setting up root password"
else
    echo -e "mysql root password is already setup.. $Y skipping $N" | tee -a $LOG_FILE
fi

